module "dynamodb" {
  source = "./module/DynamoDB"
}

module "lambda" {
  source              = "./module/lambda"
  dynamodb-table-name = module.dynamodb.dynamodb-table-name
  dynamodb-arn        = module.dynamodb.dynamodb-arn
}

