terraform {
  backend "s3" {
    bucket = "devsecops-tetris-moula-111" # Replace with your actual S3 bucket name
    key    = "EKS/terraform.tfstate"
    region = "us-east-1"
  }
}
