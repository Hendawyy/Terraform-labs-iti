# Create DynamoDB Table
resource "aws_dynamodb_table" "terraform-db" {
  name         = "exisitng-terraform-db"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# Configure Terraform Remote Backend with DynamoDB State Locking
terraform {
  backend "s3" {
    bucket  = "my-s3-bkt-tf"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    # dynamodb_table = "exisitng-terraform-db"
  }
}

