region = "ap-southeast-3"
common-tags = {
  "Owner"       = "bgsi"
  "Environment" = "prod"
  "Workflow"    = "IGNG"
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

hub_name = "RSIGNG"
clinic-warning-thresholds = {
  dp     = 10
  filter = "PASS"
  gq     = 15
  mq     = 30
  qd     = 20
  qual   = 20
}

lookup_configuration = {
  assoc_matrix_filename = "RSIGNG_association_matrix.csv"
  chr_header            = "chr"
  start_header          = "start"
  end_header            = "end"
}