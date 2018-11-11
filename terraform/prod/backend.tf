terraform {
  backend "gcs" {
    bucket = "storage-bucket-infra-219212-prod"
    prefix = "prod"
  }
}
