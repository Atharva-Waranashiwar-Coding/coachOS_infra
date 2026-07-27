terraform {
  # Supply bucket, key, region, and DynamoDB lock table through backend config
  # or `terraform init -backend-config=...`; never commit state credentials.
  backend "s3" {}
}
