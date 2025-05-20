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

enable-inspector = false

hub_name = "RSCM"

svep-filters = {
  clinvar_exclude = [
    "Benign",
    "Benign/Likely benign",
    "Likely benign",
    "not provided",
  ]
  consequence_rank = 14
  max_maf          = 0.05
  min_qual         = 10
  genes = [
    "APOB",
    "LDLR",
    "PCSK9",
  ]
}