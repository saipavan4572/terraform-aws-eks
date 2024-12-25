terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.48.0"
    }
  }
  backend "s3" {
    bucket = "pspkdevops-terraform-remote-state"
    key    = "expense-eks-ingress"
    region = "us-east-1"
    dynamodb_table = "pspkdevops-terraform-lock"
  }
}

#provide authentication here
provider "aws" {
  region = "us-east-1"
}