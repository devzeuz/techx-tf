module "dynamodb"{
    source = "./modules/dynamodb"
}

module "lambda"{
    source = "./modules/lambda"
    dynamodb-table-name = module.dynamodb.dynamodb-table-name
}