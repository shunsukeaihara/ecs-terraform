# ecs 用 terraform

ECSに上にwebサービスを入れつつ、cloudwatch logsにログを送ったり、そこからkinesis data firehoseつかってelasticsearchに入れてkibanaで見たりs3に保存してathenaでログ分析したりするところまでを自動化している

アプリとnginxのログはjsonnlで出力されていることが前提。

# 前準備

direnv 等で環境変数に aws の credential を書き込み(staging, production でアカウントも分ける場合はそれぞれのディレクトリに記載)

```
cd /path/to/workingDirectory
git clone git@github.com:shunsukeaihara/ecs-terraform.git
cd ecs-terraform
direnv edit .
```

以下の様に env を記述。credential は基本に admin 権限を持ったユーザが良い。

```
export AWS_DEFAULT_REGION=ap-northeast-1
export AWS_ACCESS_KEY_ID=KEY
export AWS_SECRET_ACCESS_KEY=SECRET
```

# sample


