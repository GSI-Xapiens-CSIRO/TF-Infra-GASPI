region = "ap-southeast-3"
common-tags = {
  "Owner"       = "bgsi"
  "Environment" = "uat"
  "Workflow"    = "RSPON"
}

# cognito users
gaspi-guest-username = "guest@example.com"
gaspi-guest-password = "Guest@Example123!"
gaspi-admin-username = "admin@example.com"
gaspi-admin-password = "Admin@Example123!"
gaspi-admin-email    = "devops@example.com"

# buckets
variants-bucket-prefix      = "gaspi-variants-"
metadata-bucket-prefix      = "gaspi-metadata-"
lambda-layers-bucket-prefix = "gaspi-lambda-layers-"
dataportal-bucket-prefix    = "gaspi-dataportal-"

max-request-rate-per-5mins      = 1000
sbeacon-method-queue-size       = 100
sbeacon-method-max-request-rate = 10
svep-method-max-request-rate    = 10
svep-method-queue-size          = 100

ses-source-email = "devops@example.com"
enable-inspector = true

hub_name = "RSPON"
pharmcat_configuration = {
  ORGANISATIONS = [
    {
      "gene" = "CPIC"
      "drug" = "CPIC Guideline Annotation"
    },
    {
      "gene" = "DPWG"
      "drug" = "DPWG Guideline Annotation"
    },
    {
      "gene" = "CPIC"
      "drug" = "FDA Label Annotation"
    },
    {
      "gene" = "CPIC"
      "drug" = "FDA PGx Association"
    }
  ]
  GENES = [
    "CYP2C19",
  ]
  DRUGS = [
    "clopidogrel",
  ]
}
