resource "aws_s3_bucket" "techx-tf-state-bucket" {
    bucket = "techx-tf-state-bucket"
    
    // Find out what this actually does.
    lifecycle {
        prevent_destroy = true
    }
}

resource "aws_s3_bucket_versioning" "techx-tf-state-bucket-versioning" {
    bucket = aws_s3_bucket.techx-tf-state-bucket.id

    versioning_configuration {
      status = "Enabled"
    }
}

resource "aws_dynamodb_table" "techx-tf-state-lock-table" {
  name         = "techx-tf-state-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  
  //Defining the attributes or primary key
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}