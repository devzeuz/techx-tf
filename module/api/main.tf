resource "aws_api_gateway_rest_api" "techx-tf-api-gateway" {
    name        = "techx-tf-api-gateway"
    description = "API Gateway for TechX Terraform project"
    endpoint_configuration {
        types = ["REGIONAL"]
    }
}

// API Gateway Resource
resource "aws_api_gateway_resource" "techx-tf-courses-resource" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    parent_id   = aws_api_gateway_rest_api.techx-tf-api-gateway.root_resource_id // root resource id represent the / part of the rest api
    path_part   = "courses"
}

resource "aws_api_gateway_resource" "techx-tf-id-resource" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    parent_id   = aws_api_gateway_resource.techx-tf-courses-resource.id
    path_part   = "{id}"
}

resource "aws_api_gateway_resource" "techx-tf-user-resource" {
    rest_api_id  = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    parent_id = aws_api_gateway_rest_api.techx-tf-api-gateway.root_resource_id
    path_part = "user"
}
// API Gateway Resource

// API resource Methods
resource "aws_api_gateway_method" "techx-tf-courses-method" {
    rest_api_id   = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id   = aws_api_gateway_resource.techx-tf-courses-resource.id
    http_method   = "GET"
    authorization  = "NONE"
}

resource "aws_api_gateway_method" "techx-tf-id-method" {
    rest_api_id   = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id   = aws_api_gateway_resource.techx-tf-id-resource.id
    http_method = "GET"
    authorization = "NONE"
}

// USER Resource Methods
resource "aws_api_gateway_method" "techx-tf-user-post-method" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-user-resource.id
    http_method = "POST"
    authorization = "COGNITO_USER_POOLS"
    authorizer_id = aws_api_gateway_authorizer.techx-tf-authorizers.id
}

resource "aws_api_gateway_method" "techx-tf-user-get-method" {
     rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
     resource_id = aws_api_gateway_resource.techx-tf-user-resource.id
     http_method ="GET"
     authorization = "COGNITO_USER_POOLS"
    authorizer_id = aws_api_gateway_authorizer.techx-tf-authorizers.id
}

// OPTIONS method for /user resource
resource "aws_api_gateway_method" "techx-tf-user-options-method" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
     resource_id = aws_api_gateway_resource.techx-tf-user-resource.id
     http_method = "OPTIONS"
     authorization = "NONE"
}

// OPTIONS method for /courses/{id} resource
resource "aws_api_gateway_method" "techx-tf-id-options-method" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-id-resource.id
    http_method = "OPTIONS"
    authorization = "NONE"
}

// OPTIONS method for /courses resource
resource "aws_api_gateway_method" "techx-tf-courses-options-method" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-courses-resource.id
    http_method = "OPTIONS"
    authorization = "NONE"
}
// API Resource Methods


// API Method Integration 
resource "aws_api_gateway_integration" "techx-tf-courses-integration" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-courses-resource.id
    http_method = aws_api_gateway_method.techx-tf-courses-method.http_method
    integration_http_method = "POST" // API gateway POST the frontend request to lambda therefor invoking it in the process, this is why integration HTTP method is set to post
    type                    = "AWS_PROXY"
    uri                     = var.lambda-invoke-arn
}

resource "aws_api_gateway_integration" "techx-tf-id-integration" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-id-resource.id
    http_method = aws_api_gateway_method.techx-tf-id-method.http_method
    integration_http_method = "POST"
    type                    = "AWS_PROXY"
    uri                     = var.lambda-invoke-arn
}

               // User resource integration for GET and POST method
resource "aws_api_gateway_integration" "techx-tf-user-get-integration" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-user-resource.id
    http_method = aws_api_gateway_method.techx-tf-user-get-method.http_method
    integration_http_method = "POST"
    type                    = "AWS_PROXY"
    uri                     = var.lambda-invoke-arn
}

resource "aws_api_gateway_integration" "techx-tf-user-post-integration" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-user-resource.id
    http_method = aws_api_gateway_method.techx-tf-user-post-method.http_method
    integration_http_method = "POST"
    type                    = "AWS_PROXY"
    uri                     = var.lambda-invoke-arn
}

// OPTIONS method integratiion for /user resource
resource "aws_api_gateway_integration" "techx-tf-user-options-integration" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-user-resource.id
    http_method = aws_api_gateway_method.techx-tf-user-options-method.http_method
    type                    = "MOCK"
}

// OPTIONS method integratiion for /courses resource
resource "aws_api_gateway_integration" "techx-tf-courses-options-integration" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-courses-resource.id
    http_method = aws_api_gateway_method.techx-tf-courses-options-method.http_method
    type = "MOCK"

    request_templates = {
        "application/json" = jsonencode({"statusCode": 200})
    }
}

// OPTIONS method integratiion for /id resource
resource "aws_api_gateway_integration" "techx-tf-id-options-integration" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-id-resource.id
    http_method = aws_api_gateway_method.techx-tf-id-options-method.http_method
    type = "MOCK"
}
// API Method Integration

// API gateway METHOD responses
// /user OPTIONS method-response
resource "aws_api_gateway_method_response" "techx-tf-user-options-method-response" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-user-resource.id
    http_method = aws_api_gateway_method.techx-tf-user-options-method.http_method
    status_code = "200"

    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true,
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Origin"  = true,
    }

    response_models = {
      "application/json" = "Empty"
    }
}


// /courses/{id} options method-response
resource "aws_api_gateway_method_response" "techx-tf-id-options-method-response" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-id-resource.id
    http_method = aws_api_gateway_method.techx-tf-id-options-method.http_method
    status_code = "200"

    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true,
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Origin"  = true,
    }
}

// /courses options method-response
resource "aws_api_gateway_method_response" "techx-tf-courses-options-method-response" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-courses-resource.id
    http_method = aws_api_gateway_method.techx-tf-courses-options-method.http_method
    status_code = "200"

    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true, 
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Origin"  = true,
    }
    
    response_models = {
      "application/json" = "Empty"
    }
}
// API gateway METHOD responses


//API gateway INTEGRATION responses
//user resource OPTIONS method integration-response
resource "aws_api_gateway_integration_response" "techx-tf-user-options-integration-response" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-user-resource.id
    http_method = aws_api_gateway_integration.techx-tf-user-options-integration.http_method
    status_code = aws_api_gateway_method_response.techx-tf-user-options-method-response.status_code

    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
        "method.response.header.Access-Control-Allow-Methods" = "'GET,POST','OPTIONS'",
        "method.response.header.Access-Control-Allow-Origin"  = "'*'",
    }
}

// /courses/{id} resource OPTIONS method integration-response
resource "aws_api_gateway_integration_response" "techx-tf-id-options-integration-response" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-id-resource.id
    http_method = aws_api_gateway_integration.techx-tf-id-options-integration.http_method
    status_code = aws_api_gateway_method_response.techx-tf-id-options-method-response.status_code

    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
        "method.response.header.Access-Control-Allow-Methods" = "'GET','OPTIONS'",
        "method.response.header.Access-Control-Allow-Origin"  = "'*'",
    }
}
// /course OPTIONS method integration-response
resource "aws_api_gateway_integration_response" "techx-tf-courses-options-integration-response" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    resource_id = aws_api_gateway_resource.techx-tf-courses-resource.id
    http_method = aws_api_gateway_integration.techx-tf-courses-options-integration.http_method
    status_code = aws_api_gateway_method_response.techx-tf-courses-options-method-response.status_code

    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
        "method.response.header.Access-Control-Allow-Methods" = "'GET','OPTIONS'",
        "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    }
}
//API gateway INTEGRATION responses


// API Deployment => Stage
resource "aws_api_gateway_deployment" "techx-tf-api-deploment" {
    rest_api_id = aws_api_gateway_rest_api.techx-tf-api-gateway.id
    
        triggers = {
        redeployment = sha1(jsonencode([
                // /courses resource deployment trigger
                aws_api_gateway_resource.techx-tf-courses-resource.id,
                aws_api_gateway_method.techx-tf-courses-method.id,
                aws_api_gateway_method.techx-tf-courses-options-method.id,
                aws_api_gateway_integration.techx-tf-courses-integration.id,
                aws_api_gateway_integration.techx-tf-courses-options-integration.id,
                aws_api_gateway_method_response.techx-tf-courses-options-method-response.id,
                aws_api_gateway_integration_response.techx-tf-courses-options-integration-response.id,


                // /courses/{id} resource deployment trigger
                aws_api_gateway_resource.techx-tf-id-resource.id,
                aws_api_gateway_method.techx-tf-id-method.id,
                aws_api_gateway_method.techx-tf-id-options-method.id,
                aws_api_gateway_integration.techx-tf-id-integration.id,
                aws_api_gateway_integration.techx-tf-id-options-integration.id,
                aws_api_gateway_method_response.techx-tf-id-options-method-response.id,
                aws_api_gateway_integration_response.techx-tf-id-options-integration-response.id,


                // /user resource deployment trigger
                aws_api_gateway_resource.techx-tf-user-resource.id,
                aws_api_gateway_method.techx-tf-user-post-method.id,
                aws_api_gateway_method.techx-tf-user-get-method.id,
                aws_api_gateway_method.techx-tf-user-options-method.id,
                aws_api_gateway_integration.techx-tf-user-get-integration.id,
                aws_api_gateway_integration.techx-tf-user-post-integration.id,
                aws_api_gateway_integration.techx-tf-user-options-integration.id,
                aws_api_gateway_method_response.techx-tf-user-options-method-response.id,
                aws_api_gateway_integration_response.techx-tf-user-options-integration-response.id,

                // /admin resource deployment trigger 
                aws_api_gateway_resource.techx-tf-admin-resource.id,
                aws_api_gateway_resource.techx-tf-ingest-resource.id,
                aws_api_gateway_method.techx-tf-ingest-post-method.id,
                aws_api_gateway_integration.techx-tf-ingest-post-integration.id,
                aws_api_gateway_method.techx-tf-ingest-options-method.id,
                aws_api_gateway_integration.techx-tf-ingest-options-integration.id,
                aws_api_gateway_integration_response.techx-tf-ingest-options-integration-response.id,
                aws_api_gateway_method_response.techx-tf-ingest-options-method-response.id
            ]))
        }

    lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "techx-tf-api-stage" {
 deployment_id = aws_api_gateway_deployment.techx-tf-api-deploment.id
  rest_api_id   = aws_api_gateway_rest_api.techx-tf-api-gateway.id
  stage_name    = "development"
}