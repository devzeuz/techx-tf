resource "aws_dynamodb_table" "techx-main-table"{
    name           = "techx-main-table"
    billing_mode   = "ON_DEMAND"

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

