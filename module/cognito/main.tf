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
    generate_secret            = false

    allowed_oauth_flows_user_pool_client = true
    allowed_oauth_flows                  = ["code"]       # initial code flow
    allowed_oauth_scopes                 = ["openid", "email"]
    supported_identity_providers         = ["COGNITO"]

    explicit_auth_flows = [
        "ALLOW_USER_PASSWORD_AUTH",        # allows password login
        "ALLOW_USER_SRP_AUTH",             # allows SRP (secure remote password)
        "ALLOW_REFRESH_TOKEN_AUTH"         # allows token refresh
    ]
}