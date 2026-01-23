data "archive_file" "techx-lambda-zip" {
  type        = "zip"
  source_file = "${path.module}/src/lambda-techx-function.py" //Concatenation here was done correctly.
  output_path = "${path.module}/src/lambda-techx-function.zip"
}

// AWS IAM role and trust policy for the for lambda

resource "aws_iam_role" "techx-lambda-assume-role-policy" {
    name = "techx-lambda-arp" 
   
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


// My managed policy

resource "aws_iam_role_policy" "dynamodb-policy" {
    name = "techx-lambda-dynamodb-policy"
    role = aws_iam_role.techx-lambda-assume-role-policy.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                    "dynamodb:Scan",
                    "dynamodb:Query",
                    "dynamodb:PutItem",
                    "dynamodb:UpdateItem",
                    "dynamodb:DeleteItem",
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

resource "aws_lambda_permission" "techxApi-lambda-permission" {
    statement_id  = "AllowAPIGatewayInvoke"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.techx-lambda-function.function_name
    principal     = "apigateway.amazonaws.com"
    source_arn    = var.api-gateway-source-arn // I will be getting the source ARN from this method, that goes in the lambda permission.
}

// Lambda function 
resource "aws_lambda_function" "techx-lambda-function" {
  filename      = data.archive_file.techx-lambda-zip.output_path // Been getting error that .output_path does not exist. The reason is simple "" should not be used for terraform attribute reference.
  function_name = "techx-tf-lambda-function"
  role          = aws_iam_role.techx-lambda-assume-role-policy.arn
  handler       = "lambda_handler"
  runtime       = "python3.9"
    //What if i dont define the other configuration?

  tags = {
    Environment = "dev"
    Project     = "TechX"
  }
}




