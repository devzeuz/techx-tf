resource "aws_cognito_user_pool" "techx-tf-cognito-user-pool" {
    name = "techx-tf-cognito-user-pool"
    alias_attributes = ["email"] // I justchnaged this so the next step is to push and run. remeber to change the ids on the frontend code.
}

resource "aws_cognito_user_pool_client" "techx-tf-cognito-user-pool-client" {
    name         = "techx-tf-cognito-user-pool-client"
    user_pool_id = aws_cognito_user_pool.techx-tf-cognito-user-pool.id
}