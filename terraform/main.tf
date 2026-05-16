provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "us-east-1"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true 
  s3_use_path_style           = true 

  endpoints {
    s3 = "http://localstack.local" 
  }
}
resource "aws_s3_bucket" "postgres-result" {
  bucket = "postgres-pdf"
  force_destroy = true
}