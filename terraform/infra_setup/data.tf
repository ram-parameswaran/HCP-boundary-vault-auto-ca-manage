data "hcp_packer_artifact" "packer-github-actions-boundary" {
  bucket_name   = var.HCP_BUCKET_NAME
  version_fingerprint = var.HCP_VERSIONFINGERPRINT
  platform      = "aws"
  region        = var.AWS_REGION
}