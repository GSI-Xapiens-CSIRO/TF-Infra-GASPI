region = "ap-southeast-3"
common-tags = {
  "Owner"       = "gaspi"
  "Environment" = "uat"
}

# cognito users
gaspi-guest-username = "guest@example.com"
gaspi-guest-password = "Guest@Example123!"
gaspi-admin-username = "admin@example.com"
gaspi-admin-password = "Admin@Example123!"
gaspi-admin-email    = "devops@example.com"

# buckets
variants-bucket-prefix      = "gasi-variants-"
metadata-bucket-prefix      = "gasi-metadata-"
lambda-layers-bucket-prefix = "gasi-lambda-layers-"
dataportal-bucket-prefix    = "gasi-dataportal-"

max-request-rate-per-5mins      = 1000
sbeacon-method-queue-size       = 100
sbeacon-method-max-request-rate = 10
svep-method-max-request-rate    = 10
svep-method-queue-size          = 100

ses-source-email = "devops@example.com"
enable-inspector = false
hub_name         = "RSIGNG"
lookup_configuration = {
  assoc_matrix_filename = "RSIGNG_association_matrix.csv"
  chr_header            = "chr"
  start_header          = "start"
  end_header            = "end"
}