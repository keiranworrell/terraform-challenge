terraform {
  backend "s3" {
    bucket         = "terraform-states"
    key            = "prod/terraform.tfstate"
    region         = "eu-west-1"
  }
}