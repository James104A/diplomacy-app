# Uncomment after creating the S3 bucket and DynamoDB table:
#   aws s3api create-bucket --bucket diplomacy-app-terraform-state --region us-east-1
#   aws s3api put-bucket-versioning --bucket diplomacy-app-terraform-state \
#     --versioning-configuration Status=Enabled
#   aws dynamodb create-table --table-name diplomacy-app-terraform-locks \
#     --attribute-definitions AttributeName=LockID,AttributeType=S \
#     --key-schema AttributeName=LockID,KeyType=HASH \
#     --billing-mode PAY_PER_REQUEST

# terraform {
#   backend "s3" {
#     bucket         = "diplomacy-app-terraform-state"
#     key            = "staging/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "diplomacy-app-terraform-locks"
#     encrypt        = true
#   }
# }
