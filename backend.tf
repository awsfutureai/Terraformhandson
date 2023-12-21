provider "aws" {
  region  = "eu-central-1" # Frankfurt region
  profile = "Terraform_demo"
}

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}