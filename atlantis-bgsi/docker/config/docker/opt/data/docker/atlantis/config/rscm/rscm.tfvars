region = "ap-southeast-3"
common-tags = {
  "Owner"       = "bgsi"
  "Environment" = "prod"
  "Workflow"    = "RSCM"
}

# cognito users
gaspi-guest-username = "guest@example.com"
gaspi-guest-password = "Guest@Example123!"
gaspi-admin-username = "admin@example.com"
gaspi-admin-password = "Admin@Example123!"

# notification recipient (lambda notification)
gaspi-admin-email = "platform-infra@binomika.kemkes.go.id"

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

# operation email (`noreply`)
ses-source-email = "notification@binomika.kemkes.go.id"
enable-inspector = true

hub_name = "RSCM"
clinic-warning-thresholds = {
  dp     = 10
  filter = "PASS"
  gq     = 15
  mq     = 30
  qd     = 20
  qual   = 20
}

svep-filters = {
  clinvar_exclude = [
    "Benign",
    "Benign/Likely benign",
    "Likely benign",
    "not provided",
  ]
  consequence_rank = 14
  max_maf          = 0.05
  genes = [
    "APOB",
    "LDLR",
    "PCSK9",
  ]
}
