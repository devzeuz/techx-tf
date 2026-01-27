variable "dynamodb-table-name" {
    type = string
    description = "my dynamodb name for techx-tf"
}

variable "dynamodb-arn" {
    type = string
    description = "my dynamodb arn for techx-tf"
}

variable "api-gateway-source-arn" {
    type = string
}

variable "lambda-function-filename" {
    default = "lambda-techx-function"
}