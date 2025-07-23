terraform {
  backend "s3" {
    bucket         = "terraform-states"
    key            = "dev/terraform.tfstate"
    region         = "eu-west-1"
  }
}