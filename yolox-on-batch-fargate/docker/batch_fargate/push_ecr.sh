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

# # Activeなジョブ定義を確認
# aws --profile $ProfileName batch describe-job-definitions --job-definition-name "${ProjectPrefix}-job-definition" --status ACTIVE | jq -r ".jobDefinitions[] | .jobDefinitionArn"
# echo -n "ジョブ定義数が単数かどうか確認してEnterを入力して先に進んでください: "
# read input

# # コンテナプロパティをJSONに出力
# JobDefinitionArn=$(aws --profile $ProfileName batch describe-job-definitions --job-definition-name "sample-yolox-fargate-job-definition" --status ACTIVE | jq -r ".jobDefinitions[0] | .jobDefinitionArn")
# echo "Current job definition: $JobDefinitionArn"
# aws --profile $ProfileName batch describe-job-definitions --job-definition-name "${ProjectPrefix}-job-definition" --status ACTIVE | jq -r ".jobDefinitions[0] | .containerProperties" >container_properties.json

# # 新しいジョブ定義を作成
# NewJobDefinitionArn=$(aws --profile $ProfileName batch register-job-definition --job-definition-name "${ProjectPrefix}-job-definition" --type container --container-properties file://container_properties.json | jq -r ".jobDefinitionArn")
# echo "New job definition: $NewJobDefinitionArn"

# # 古いジョブ定義を登録解除
# aws --profile $ProfileName batch deregister-job-definition --job-definition $JobDefinitionArn
# echo "Reregister job definition: $JobDefinitionArn"

# # EventBridgeのtargetのジョブ定義を更新
# aws --profile $ProfileName events list-targets-by-rule --rule "${ProjectPrefix}-event-rule" | jq -r ".Targets[] | .BatchParameters.JobDefinition" >/dev/null
# aws --profile $ProfileName events list-targets-by-rule --rule "${ProjectPrefix}-event-rule" | jq -r ".Targets[0].BatchParameters.JobDefinition|=\"${NewJobDefinitionArn}\"" >target.json
# aws --profile $ProfileName events put-targets --rule "${ProjectPrefix}-event-rule" --cli-input-json file://target.json >/dev/null
# aws --profile $ProfileName events list-targets-by-rule --rule "${ProjectPrefix}-event-rule" | jq -r ".Targets[] | .BatchParameters.JobDefinition" >/dev/null