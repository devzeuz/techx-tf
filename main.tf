module "dynamodb"{
    source = "./modules/DynamoDB"
}

module "lambda"{
    source = "./modules/lambda"
    dynamodb-table-name = module.dynamodb.dynamodb-table-name
    dynamodb-arn = module.dynamodb.dynamodb-arn
}

