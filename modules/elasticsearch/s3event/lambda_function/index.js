'use strict';

const http = require('http');
const zlib = require('zlib');
const crypto = require('crypto');
const AWS = require('aws-sdk');
const s3 = new AWS.S3();

const ENV = process.env;

const ENDPOINT = ENV.ES_ENDPOINT;
const DEST_BUCKET = ENV.DEST_BUCKET;

function buildRequest(endpoint, body) {
  const request = {
    host: endpoint,
    method: 'POST',
    path: '/_bulk',
    headers: {
      'Content-Type': 'application/json',
      Host: endpoint,
      'Content-Length': Buffer.byteLength(body),
      // 'X-Amz-Security-Token': process.env.AWS_SESSION_TOKEN,
      // 'X-Amz-Date': datetime
    },
    body,
  };
  return request;
}

function buildEsRequest(data) {
  const payload = data.split('\n').filter((line) => !!line).map((line) => {
    const obj = JSON.parse(line);
    const timestamp = new Date(obj['@timestamp']);
    const indexName = [
      `cwl-${timestamp.getUTCFullYear()}`, // year
      `0${timestamp.getUTCMonth() + 1}`.slice(-2),
      `0${timestamp .getUTCDate()}`.slice(-2)
    ].join('.');
    const action = { 'index': {} };
    action.index._index = indexName;
    action.index._type = obj['@log_group'];
    action.index._id = obj['@id'];
    return `${JSON.stringify(action)}\n${line}`;
  }).join('\n');
  return buildRequest(ENDPOINT, `${payload}\n`);
}

function postPromise(requestObj, object) {
  return new Promise((resolve, reject) => {
    const request = http.request(requestObj, (response) => {
      let responseBody = '';
      response.on('data', (chunk) => {
        responseBody += chunk;
      });
      response.on('end', () => {
        const info = JSON.parse(responseBody);
        let failedItems = [];
        if (response.statusCode >= 200 && response.statusCode < 299) {
          failedItems = info.items.filter(x => x.index.status >= 300);
        }
        const error = response.statusCode !== 200 || info.errors === true ? {
          statusCode: response.statusCode,
          successfulItems: info.items.length - failedItems.length,
          failedItems: failedItems.length,
          key: object.Key,
          responseBody,
        } : null;
        if (error) {
          console.log(error);
          reject(error);
        } else {
          resolve({
            successfulItems: info.items.length - failedItems.length,
            failedItems: failedItems.length,
          });
        }
      });
    });
    request.on('error', err => reject(err));
    request.write(requestObj.body);
    request.end();
  });
}

async function insertToEsAndMove(srcBucket, object) {
  try {
    if (object.Key.indexOf("processing-failed") !== -1) {
      return null;
    }
    const params = { Bucket: srcBucket, Key: object.Key };
    const response = await s3.getObject(params).promise();
    const unzipped = zlib.gunzipSync(response.Body).toString('utf-8');
    const request = buildEsRequest(unzipped);
    const result = await postPromise(request, object);
    const putResponse = await s3.putObject({
      Bucket: DEST_BUCKET,
      Key: object.Key,
      Body: response.Body,
      ContentEncoding: 'gzip',
      ContentType: 'application/octet-stream',
    }).promise();
    const delResut = await s3.deleteObject({ Bucket: srcBucket, Key: object.Key }).promise();
  } catch (err) {
    return err;
  }
  return null;
}

exports.handler = async (event, context, callback) => {
  // deco de input from base64
  const srcBucket = event.Records[0].s3.bucket.name;
  const mapFunc = insertToEsAndMove.bind(null, srcBucket);
  try {
    const objects = await s3.listObjectsV2({ Bucket: srcBucket, Prefix: 'succeeded', MaxKeys: 15 }).promise();
    const errors = await Promise.all(objects.Contents.map(mapFunc))
    const filtered = errors.filter(e => !!e);
    filtered.forEach(e => console.log(`[Error]: ${JSON.stringify(e)}`));
    if (filtered.length > 0) {
      callback('errors');
    } else {
      console.log(objects.Contents.length - filtered.length);
      callback(null);
    }
  } catch (err) {
    console.error(`[Error]: ${JSON.stringify(err)}`);
    callback(err);
  }
};
