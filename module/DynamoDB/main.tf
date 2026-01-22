resource "aws_dynamodb_table" "techx-main-table"{
    name           = "techx-tf-main-table"
    billing_mode   = "PAY_PER_REQUEST" //Billing mode is set to pay per request and provisioned

    // defining the attributes or primary key
    hash_key       = "PK"
    range_key = "SK"
    

    // Attributes are defined here because dynamodb has to know what data types hashkey and rangekey are.
    attribute {
        name = "PK"
        type = "S"
    }

    attribute {
        name = "SK"
        type = "S" 
    }
    

    tags = {
        Environment = "dev"
        Project     = "TechX"
    }
}

