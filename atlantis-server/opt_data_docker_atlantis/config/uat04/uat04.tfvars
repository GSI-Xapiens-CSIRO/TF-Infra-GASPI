region = "ap-southeast-3"
common-tags = {
  "Owner"       = "gaspi"
  "Environment" = "uat"
}

# cognito users
gaspi-guest-username = "guest@example.com"
gaspi-guest-password = "guest1234"
gaspi-admin-username = "admin@example.com"
gaspi-admin-password = "admin1234"
gaspi-admin-email    = "devops@example.com"

# buckets
variants-bucket-prefix      = "gasi-variants-"
metadata-bucket-prefix      = "gasi-metadata-"
lambda-layers-bucket-prefix = "gasi-lambda-layers-"
dataportal-bucket-prefix    = "gasi-dataportal-"

ses-source-email = "devops@example.com"
