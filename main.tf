module "dynamodb" {
  source = "./module/DynamoDB"
}

module "lambda" {
  source              = "./module/lambda"
  dynamodb-table-name = module.dynamodb.dynamodb-table-name
  dynamodb-arn        = module.dynamodb.dynamodb-arn
  api-gateway-source-arn = module.api.apiExecutionArn
}

module "api" {
  source = "./module/api"
  lambda-invoke-arn = module.lambda.invoke_arn
}