terraform {
  backend "s3" {
    bucket = "pppavancharypppww"
    key = "terraform.tfstate"
    region = "us-east-1"
  }
}