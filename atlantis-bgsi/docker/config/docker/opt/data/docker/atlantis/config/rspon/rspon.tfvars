region = "ap-southeast-3"
common-tags = {
  "Owner"       = "bgsi"
  "Environment" = "prod"
  "Workflow"    = "RSPON"
}

# cognito users
gaspi-guest-username = "guest@example.com"
gaspi-guest-password = "Guest@Example123!"
gaspi-admin-username = "admin@example.com"
gaspi-admin-password = "Admin@Example123!"

# buckets
variants-bucket-prefix      = "gaspi-variants-"
metadata-bucket-prefix      = "gaspi-metadata-"
lambda-layers-bucket-prefix = "gaspi-lambda-layers-"
dataportal-bucket-prefix    = "gaspi-dataportal-"

# notification recipient (lambda notification)
gaspi-admin-email = "platform-infra@binomika.kemkes.go.id"
# operation email (`noreply`)
ses-source-email = "notification@binomika.kemkes.go.id"
enable-inspector = true

hub_name = "RSPON"

clinic-warning-thresholds = {
  dp     = 10
  filter = "PASS"
  gq     = 15
  mq     = 30
  qd     = 20
  qual   = 20
}

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
