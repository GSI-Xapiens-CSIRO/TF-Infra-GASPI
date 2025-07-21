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
enable-inspector = true
hub_name         = "RSJPD"
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
    "SLCO1B1",
  ]
  DRUGS = [
    "simvastatin",
    "rosuvastatin",
    "pravastatin",
    "pitavastatin",
    "lovastatin",
    "fluvastatin",
    "atorvastatin"
  ]
}

lookup_configuration = {
  assoc_matrix_filename = "RSJPD_association_matrix.csv"
  chr_header            = "chr"
  start_header          = "start"
  end_header            = "end"
}