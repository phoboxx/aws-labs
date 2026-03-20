provider "aws" {
  region = "us-east-2"
}
module "artifact_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "artifact-bucket-aosidjfaosdijfqewklksd"
}
