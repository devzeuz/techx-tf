resource "aws_cognito_user_pool" "techx-tf-user-pool" {
    name = "techx-tf-user-pool"
    # alias_attributes = ["email"]
    auto_verified_attributes = ["email"]
}

resource "aws_cognito_user_pool_client" "techx-tf-user-pool-client" {
    name         = "techx-tf-user-pool-client"
    user_pool_id = aws_cognito_user_pool.techx-tf-user-pool.id
}