## 手順

### TerraformでECRのみ構築

まずはECRのみを構築します。理由はECRレポジトリが先に無いとコンテナイメージを`push`できないためです。

またコンテナイメージが無いとTerraformでLambdaを作成することができないため、先にECRレポジトリを作成します。

```shell
# 作業フォルダ: terraform/environments/dev/
terraform init # 初回のみでOK
aws-vault exec {プロファイル名} -- terraform apply -target="module.ecr" -var 'project_prefix={任意のプレフィックス}' # aws-vault経由で実行
```

工夫すればこの辺りの依存関係を自動化できる可能性もありますが、今回は手動でやっています。

### イメージのビルド

まず`docker/lambda/.env`というファイルを作成して、環境変数を入力しておきます。

```
PROJECT_PREFIX="{任意のプレフィックス}"
```

{任意のプレフィックス}は、`terraform apply`の際に指定したものと合致するようにしておいてください。

その後は以下でビルドができます。

```shell
# 作業フォルダ: docker/lambda/
docker compose build
```

ビルドには時間がかかりました。PyTorchをインストールしているためと考えられます。

またイメージの容量もかなり大きいためご注意ください。

```shell
# 確認
docker images

# REPOSITORY             TAG       IMAGE ID       CREATED         SIZE
# sample-yolox-lambda    latest    b0b91c72e91d   2 hours ago     9.81GB
```

### ECRへコンテナイメージをpush

`push_ecr.ps1`というスクリプトを準備していますのでそちらを実行してください。

```powershell
.\push_ecr.ps1 -ProfileName {プロファイル名} -ProjectPrefix {任意のプレフィックス}
```

{任意のプレフィックス}は、`terraform apply`の際に指定したものと合致するようにしておいてください。

`push_ecr.ps1`の内容は以下です。

```powershell
param(
    [Parameter(Mandatory)]
    [string]$ProfileName,
    [Parameter(Mandatory)]
    [string]$ProjectPrefix
)

$REGION = $(aws configure get region --profile $ProfileName)
$ACCOUNT_ID = $(aws sts get-caller-identity --query 'Account' --output text --profile $ProfileName)

$REPOSITORY_NAME = $ProjectPrefix
$ECR_BASE_URL = "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
$ECR_IMAGE_URI = "${ECR_BASE_URL}/${REPOSITORY_NAME}"

Write-Output "ECR_BASE_URL: ${ECR_BASE_URL}"
Write-Output "ECR_IMAGE_URI: ${ECR_IMAGE_URI}"

# ECRへのログイン
aws ecr get-login-password --region ${REGION} --profile $ProfileName | docker login --username AWS --password-stdin ${ECR_BASE_URL}

# tagの付け替え
docker tag "${REPOSITORY_NAME}:latest" "${ECR_IMAGE_URI}:latest"

# ECRへのpush
docker push "${ECR_IMAGE_URI}:latest"

# Lambdaを更新
aws lambda update-function-code --function-name $ProjectPrefix --image-uri "${ECR_IMAGE_URI}:latest" --profile $ProfileName | Out-Null
```

なお、この時点では`push_ecr.ps1`スクリプトの最後の`aws lambda update-function-code`のみ失敗します。リソースがまだ作られてないためです。

こちらは、更新を兼ねているためこのようなスクリプトとなっています。

また同様のことが可能なシェルも`push_ecr.sh`として置いてありますのでご活用ください。

```shell
push_ecr.sh {プロファイル名} {任意のプレフィックス}
```

`push_ecr.sh`の内容は以下となっています。

```shell
ProfileName=$1
ProjectPrefix=$2

REGION=$(aws configure get region --profile $ProfileName)
ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text --profile $ProfileName)

REPOSITORY_NAME=$ProjectPrefix
ECR_BASE_URL="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
ECR_IMAGE_URI="${ECR_BASE_URL}/${REPOSITORY_NAME}"

echo "ECR_BASE_URL: ${ECR_BASE_URL}"
echo "ECR_IMAGE_URI: ${ECR_IMAGE_URI}"

# ECRへのログイン
aws ecr get-login-password --region ${REGION} --profile $ProfileName | docker login --username AWS --password-stdin ${ECR_BASE_URL}

# tagの付け替え
docker tag "${REPOSITORY_NAME}:latest" "${ECR_IMAGE_URI}:latest"

# ECRへのpush
docker push "${ECR_IMAGE_URI}:latest"

# Lambdaを更新
aws lambda update-function-code --function-name $ProjectPrefix --image-uri "${ECR_IMAGE_URI}:latest" --profile $ProfileName > /dev/null
```

### Terraformでリソースを全て構築

最後にECR以外のリソースを作成します。

```shell
# 作業フォルダ: terraform/environments/dev/
aws-vault exec {プロファイル名} -- terraform apply -var 'project_prefix={任意のプレフィックス}' # aws-vault経由で実行