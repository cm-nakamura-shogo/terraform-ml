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
