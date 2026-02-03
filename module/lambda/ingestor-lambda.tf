data "archive_file" "techx-lambda-zip" {
  type        = "zip"
  source_file = "${path.module}/src/lambda-techx-ingestor-logic.py" //Concatenation here was done correctly.
  output_path = "${path.module}/src/lambda-techx-ingestor-logic.zip"
}

resource "aws_iam_role" "techx-tf-lambda-assume-role-policy" {
    name = "techx-tf-lambda-assume-role-policy" 
   
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "lambda.amazonaws.com"
                }
            }
        ]
    })
}

resource "aws_iam_role_policy" "techx-tf-dynamodb-policy" {
    name = "techx-tf-lambda-dynamodb-policy"
    role = aws_iam_role.techx-tf-lambda-assume-role-policy.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                    "dynamodb:PutItem",
                    "dynamodb:BatchWriteItem"
                ]
                Effect   = "Allow"
                Resource = var.dynamodb-arn
            },
            {
                Action = [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ]
                Effect   = "Allow"
                Resource = "*"
            }
        ]
    })
}

resource "aws_lambda_function" "techx-tf-ingestor-lambda" {
    filename = data.archive_file.techx-lambda-zip.output_path
    name = "techx-tf-ingestor-lambda"
    role = aws_iam_role.techx-tf-lambda-assume-role-policy.arn
    runtime = "python3.9"
    handler = "lambda-techx-ingestor-logic.lambda_handler"
    timeout = 60
}