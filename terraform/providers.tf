terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0" # Add this!
    }
  }
  backend "s3" {
    bucket         = "terraform-state-bucket"             # Name of your S3 bucket
    key            = "dev/terraform.tfstate"              # Path within the bucket
    region         = "us-east-1"                          # Region of the bucket
  }
}