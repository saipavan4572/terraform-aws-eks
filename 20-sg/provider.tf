terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.51.1"
    }
  }

  backend "s3" {
    bucket = "pspkdevops-terraform-remote-state"    #bucketname created in aws
    key    = "expense-eks-sg"     #key we can give any name but should be unique to application/project
    region = "us-east-1"
    dynamodb_table = "pspkdevops-terraform-lock"    # Dynamo db table name in aws
  }

}
# to provide authentication.
provider "aws" {
  region = "us-east-1"
}
