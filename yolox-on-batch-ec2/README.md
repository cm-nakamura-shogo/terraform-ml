## 手順

### Terraformでリソースを全て構築

最初にリソースをすべて作成します。

```shell
# 作業フォルダ: terraform/environments/dev/
aws-vault exec {プロファイル名} -- terraform apply -var 'project_prefix={任意のプレフィックス}' # aws-vault経由で実行
```

Lambdaの時と異なり、ECRレポジトリにimageがpushされていなくてもBatchのジョブ定義は作成できますので、最初にすべて作ることが可能です。

### イメージのビルド

まず`docker/lambda/.env`というファイルを作成して、環境変数を入力しておきます。

```
PROJECT_PREFIX="{任意のプレフィックス}"
```

{任意のプレフィックス}は、後述の`terraform apply`の際に指定したものと合致するようにしておいてください。

その後は以下でビルドができます。

```shell
# 作業フォルダ: docker/lambda/
docker compose build
```

### ECRへコンテナイメージをpush

`push_ecr.sh`というスクリプトを準備していますのでそちらを実行してください。

```shell
.\push_ecr.sh {プロファイル名} {任意のプレフィックス}
```

{任意のプレフィックス}は、後述の`terraform apply`の際に指定したものと合致するようにしておいてください。

`push_ecr.sh`の内容は以下です。

```shell
ProfileName=$1
ProjectPrefix=$2

REGION=$(aws --profile $ProfileName configure get region)
ACCOUNT_ID=$(aws --profile $ProfileName sts get-caller-identity --query 'Account' --output text )

REPOSITORY_NAME=$ProjectPrefix
ECR_BASE_URL="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
ECR_IMAGE_URI="${ECR_BASE_URL}/${REPOSITORY_NAME}"

echo "ECR_BASE_URL: ${ECR_BASE_URL}"
echo "ECR_IMAGE_URI: ${ECR_IMAGE_URI}"

# ECRへのログイン
aws --profile $ProfileName ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_BASE_URL}

# tagの付け替え
docker tag "${REPOSITORY_NAME}:latest" "${ECR_IMAGE_URI}:latest"

# ECRへのpush
docker push "${ECR_IMAGE_URI}:latest"
```

今回からPowershellではなくGit Bashなどからshellを使う形にしています。

以上で構築の準備が完了しました。

## 動作確認

AWS CLIでjpgファイルをアップロードしてみます。

前回同様に`asset/demo.jpg`にサンプル画像を配置してありますので良ければお試しください。

（今回はオブジェクトキーは時刻情報が付与するようにしています）

```shell
aws s3 cp asset/demo.jpg s3://{バケット名}/input/$(date "+%Y%m%d-%H%M%S").jpg --profile {プロファイル名}
```

処理が終わると、`output/`に結果が配置されます。

```shell
aws s3 ls s3://{バケット名}/output/ --profile {プロファイル名}
```