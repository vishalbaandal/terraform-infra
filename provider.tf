# Configure the AWS Provider
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile_name
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.2"
    }
  }
}


provider "http" {}

