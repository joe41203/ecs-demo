provider "aws" {
  region                  = local.region
  shared_credentials_file = local.credential_path
  profile                 = local.profile
  version                 = ">= 2.33.0"
}
