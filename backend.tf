terraform {
  backend "s3" {
    bucket         = "pavanchary-learning-tf-state"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "learning-terraform-lock"
    encrypt        = true
  }
}