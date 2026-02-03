data "archive_file" "techx-tf-lambda-zip" {
  type        = "zip"
  source_file = "${path.module}/src/lambda-techx-tf-ingestor-logic.py" //Concatenation here was done correctly.
  output_path = "${path.module}/src/lambda-techx-tf-ingestor-logic.zip"
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
                    "dynamodb:BatchWriteItem",
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
            },

            {
                Action = [
                    "secretsmanager:GetSecretValue"
                ]
                Effect = "Allow"
                Resource = "*" //I still have to reduce the scope of this to a single resource.
            }
        ]
    })
}

resource "aws_lambda_permission" "techx-tf-lambda-api-gateway-permission" {
    statement_id  = "admin-ingest-AllowAPIGatewayInvoke" //* Subject to change, i have to use random hex numbers*
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.techx-tf-ingestor-lambda.function_name
    principal     = "apigateway.amazonaws.com"
    source_arn    = "arn:aws:execute-api:us-east-1:522814725174:ffrcc98352/*/POST/admin/ingest" // The source ARN must match Executions ARN coming from API gateway. 
}

resource "aws_lambda_function" "techx-tf-ingestor-lambda" {
    filename      = data.archive_file.techx-tf-lambda-zip.output_path
    function_name = "techx-tf-ingestor-lambda"
    role         = aws_iam_role.techx-tf-lambda-assume-role-policy.arn
    runtime      = "python3.9"
    handler      = "lambda-techx-ingestor-logic.lambda_handler"
    timeout      = 60
}