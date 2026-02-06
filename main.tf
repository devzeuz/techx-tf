module "dynamodb" {
  source = "./module/DynamoDB"
}

module "lambda" {
  source              = "./module/lambda"
  dynamodb-table-name = module.dynamodb.dynamodb-table-name
  dynamodb-arn        = module.dynamodb.dynamodb-arn
  api-gateway-execution-arn = module.api.apiExecutionArn
}

module "api" {
  source = "./module/api"
  lambda-invoke-arn = module.lambda.invoke_arn
  cognito-user-pool-arn = module.cognito.cognito-arn-output
  ingest-lambda-invoke-arn = module.lambda.ingest-lambda-invoke-arn
}

module "cognito" {
  source = "./module/cognito"
}

module "cors-resource" {
  source = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = module.api.rest-api-id
  api_resource_id = module.api.courses-resource-id
}

module "cors-id-resource" {
  source = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = module.api.rest-api-id
  api_resource_id = module.api.id-courses-id
}

module "cors-user-resource" {
  source = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = module.api.rest-api-id
  api_resource_id = module.api.user-resource-id
}

