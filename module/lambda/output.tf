output "invoke_arn" {
    value = aws_lambda_function.techx-lambda-function.invoke_arn
}

output "ingest-lambda-arn" {
    value = aws_lambda_function.techx-tf-ingestor-lambda.arn
}