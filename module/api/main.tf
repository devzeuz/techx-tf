resource "aws_api_gateway_rest_api" "techx-tf-api-gateway" {
    name        = "techx-tf-api-gateway"
    description = "API Gateway for TechX Terraform project"
    endpoint_configuration {
        types = ["REGIONAL"]
    }
}

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
                aws_api_gateway_method.techx-tf-admin-options-method.id,
                aws_api_gateway_integration.techx-tf-ingest-options-integration.id,
                aws_api_gateway_integration.techx-tf-admin-options-integration.id,
                aws_api_gateway_integration_response.techx-tf-ingest-options-integration-response.id,
                aws_api_gateway_integration_response.techx-tf-admin-options-integration-response.id,
                aws_api_gateway_method_response.techx-tf-ingest-options-method-response.id,
                aws_api_gateway_method_response.techx-tf-admin-options-method-response.id
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