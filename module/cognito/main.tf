resource "aws_cognito_user_pool" "techx-tf-user-pool" {
    name = "techx-tf-user-pool"

    auto_verified_attributes = ["email"]

    password_policy {
        minimum_length    = 8
        require_uppercase = true
        require_numbers   = true
    }
}

resource "aws_cognito_user_pool_client" "techx-tf-user-pool-client" {
    name         = "techx-tf-user-pool-client"
    user_pool_id = aws_cognito_user_pool.techx-tf-user-pool.id
    generate_secret = false

    explicit_auth_flows = [
        "ALLOW_USER_PASSWORD_AUTH",   # allows username/password login
        "ALLOW_USER_SRP_AUTH",        # allows SRP login
        "ALLOW_REFRESH_TOKEN_AUTH"    # allows token refresh
    ]
}