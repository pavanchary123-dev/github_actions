terraform {
  backend "s3" {
    bucket = "pppavancharypppww"
    key = "terraform.tfstate"
    region = "eu-north-1"
  }
}