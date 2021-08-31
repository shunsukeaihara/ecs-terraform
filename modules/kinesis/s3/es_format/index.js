'use strict';

const zlib = require('zlib');
const AWS = require('aws-sdk');

function transformLogEvent(payload, logEvent) {
  var source = buildSource(logEvent.message, logEvent.extractedFields);
  source['@id'] = logEvent.id;
  source['@timestamp'] = new Date(1 * logEvent.timestamp).toISOString();
  source['@message'] = logEvent.message;
  source['@owner'] = payload.owner;
  source['@log_group'] = payload.logGroup;
  source['@log_stream'] = payload.logStream;
  return Promise.resolve(`${JSON.stringify(source)}\n`);
}

function buildSource(message, extractedFields) {
  if (extractedFields) {
    var source = {};

    for (var key in extractedFields) {
      if (extractedFields.hasOwnProperty(key) && extractedFields[key]) {
        var value = extractedFields[key];

        if (isNumeric(value)) {
          source[key] = 1 * value;
          continue;
        }

        var jsonSubString = extractJson(value);
        if (jsonSubString !== null) {
          source['$' + key] = JSON.parse(jsonSubString);
        }

        source[key] = value;
      }
    }
    return source;
  }

  var jsonSubString = extractJson(message);
  if (jsonSubString !== null) {
    return JSON.parse(jsonSubString);
  }

  return {};
}

function extractJson(message) {
  var jsonStart = message.indexOf('{');
  if (jsonStart < 0) return null;
  var jsonSubString = message.substring(jsonStart);
  return isValidJson(jsonSubString) ? jsonSubString : null;
}

function isValidJson(message) {
  try {
    JSON.parse(message);
  } catch (e) { return false; }
  return true;
}

function isNumeric(n) {
  return !isNaN(parseFloat(n)) && isFinite(n);
}

function putRecords(streamName, records, client, resolve, reject, attemptsMade, maxAttempts) {
  client.putRecordBatch({
    DeliveryStreamName: streamName,
    Records: records,
  }, (err, data) => {
    const codes = [];
    let failed = [];
    let errMsg = err;

    if (err) {
      failed = records;
    } else {
      for (let i = 0; i < data.RequestResponses.length; i += 1) {
        const code = data.RequestResponses[i].ErrorCode;
        if (code) {
          codes.push(code);
          failed.push(records[i]);
        }
      }
      errMsg = `Individual error codes: ${codes}`;
    }

    if (failed.length > 0) {
      if (attemptsMade + 1 < maxAttempts) {
        console.log('Some records failed while calling PutRecords, retrying. %s', errMsg);
        putRecords(streamName, failed, client, resolve, reject, attemptsMade + 1, maxAttempts);
      } else {
        reject(`Could not put records after ${maxAttempts} attempts. ${errMsg}`);
      }
    } else {
      resolve('');
    }
  });
}

exports.handler = (event, context, callback) => {
  Promise.all(event.records.map((r) => {
    const buffer = new Buffer(r.data, 'base64');
    const decompressed = zlib.gunzipSync(buffer);
    const data = JSON.parse(decompressed);
    if (data.messageType !== 'DATA_MESSAGE') {
      return Promise.resolve({
        recordId: r.recordId,
        result: 'ProcessingFailed',
      });
    } else {
      let transformFunc = transformLogEvent.bind(null, data);
      const promises = data.logEvents.map(transformFunc);
      return Promise.all(promises)
      .then((transformed) => {
        const payload = transformed.reduce((a, v) => a + v, '');
        const encoded = new Buffer(payload).toString('base64');
        return {
          recordId: r.recordId,
          result: 'Ok',
          data: encoded,
        };
      });
    }
  })).then((recs) => {
    const streamARN = event.deliveryStreamArn;
    const region = streamARN.split(':')[3];
    const streamName = streamARN.split('/')[1];
    const result = { records: recs };
    const recordsToReingest = [];
    const inputDataByRecId = {};
    event.records.forEach(r => inputDataByRecId[r.recordId] = new Buffer(r.data, 'base64'));

    let projectedSize = recs.filter(rec => rec.result !== 'ProcessingFailed')
    .map(r => r.recordId.length + r.data.length)
    .reduce((a, b) => a + b);
    // 4000000 instead of 6291456 to leave ample headroom for the stuff we didn't account for
    for (let idx = 0; idx < event.records.length && projectedSize > 4000000; idx += 1) {
      const rec = result.records[idx];
      if (rec.result !== 'ProcessingFailed') {
        recordsToReingest.push({ Data: inputDataByRecId[rec.recordId] });
        projectedSize -= rec.data.length;
        delete rec.data;
        result.records[idx].result = 'Dropped';
      }
    }

    if (recordsToReingest.length > 0) {
      const firehose = new AWS.Firehose({ region });
      new Promise((resolve, reject) => {
        putRecords(streamName, recordsToReingest, firehose, resolve, reject, 0, 20);
      }).then(
        () => {
          console.log('Reingested %s records out of %s', recordsToReingest.length, event.records.length);
          callback(null, result);
        },
        (failed) => {
          console.log('Failed to reingest records. %s', failed);
          callback(failed, null);
        });
      } else {
        console.log('No records needed to be reingested.');
        callback(null, result);
      }
    }).catch((ex) => {
      console.log('Error: ', ex);
      callback(ex, null);
    });
  };
