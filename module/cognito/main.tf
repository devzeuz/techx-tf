resource "aws_cognito_user_pool" "techx-tf-user-pool" {
    name = "techx-tf-user-pool"
    alias_attributes = ["preferred_username"] // I justchnaged this so the next step is to push and run. remeber to change the ids on the frontend code.
    # auto_verified_attributes = ["email"]
}

resource "aws_cognito_user_pool_client" "techx-tf-user-pool-client" {
    name         = "techx-tf-user-pool-client"
    user_pool_id = aws_cognito_user_pool.techx-tf-user-pool.id
}