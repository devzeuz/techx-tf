resource "aws_cognito_user_pool" "techx-tf-cognito-user-pool" {
    name = "techx-tf-cognito-user-pool"
    username_attributes = ["email"]
    auto_verified_attributes = ["email"]
}

resource "aws_cognito_user_pool_client" "techx-tf-cognito-user-pool-client" {
    name         = "techx-tf-cognito-user-pool-client"
    user_pool_id = aws_cognito_user_pool.techx-tf-cognito-user-pool.id
}