// here i am defining the providers (aws, terraform)
provider "aws" {
  region = "us-east-1"
}

terraform {
  cloud {
    organization = "practice-lab-"

    workspaces {
      name = "techx-tf"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100.0"
    }
  }

  required_version = ">= 1.3.0"
}
