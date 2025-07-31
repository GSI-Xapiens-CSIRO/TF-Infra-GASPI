# variables-mapping.tf
# ==========================================================================
#  Module Audit Activity-Logs: variables-mapping.tf
# --------------------------------------------------------------------------
#  Description:
#    Variables Mapping for Different Environments
# ==========================================================================

# --------------------------------------------------------------------------
#  Local Variables
# --------------------------------------------------------------------------
locals {
  # Environment mapping for resource naming
  environment_suffix = {
    lab     = "rnd"
    staging = "stg"
    prod    = "prd"
    default = "def"
  }

  # Resource prefix based on environment
  resource_prefix = {
    lab     = "gxc-rnd"
    staging = "gxc-stg"
    prod    = "gxc-prd"
    default = "gxc-def"
  }

  # CloudWatch configuration by environment
  cloudwatch_retention = {
    lab     = 30
    staging = 90
    prod    = 365
    default = 30
  }

  # S3 lifecycle configuration by environment
  s3_lifecycle = {
    lab = {
      transition_days = 30
      expiration_days = 90
    }
    staging = {
      transition_days = 60
      expiration_days = 180
    }
    prod = {
      transition_days = 90
      expiration_days = 365
    }
    default = {
      transition_days = 30
      expiration_days = 90
    }
  }

  # Alert thresholds by environment
  alert_thresholds = {
    lab = {
      error_count    = 10
      latency_ms     = 2000
      throttle_count = 5
    }
    staging = {
      error_count    = 5
      latency_ms     = 1500
      throttle_count = 3
    }
    prod = {
      error_count    = 3
      latency_ms     = 1000
      throttle_count = 1
    }
    default = {
      error_count    = 10
      latency_ms     = 2000
      throttle_count = 5
    }
  }

  # Genomic services configuration
  genomic_services = {
    sbeacon = {
      functions = [
        "admin",
        "backend-admin",
        "backend-dataPortal",
        "backend-deidentifyFiles",
        "backend-generateCohortVCfs",
        "backend-generateReports",
        "backend-getAnalyses",
        "backend-getBiosamples",
        "backend-getConfiguration",
        "backend-getDatasets",
        "backend-getEntryTypes",
        "backend-getFilteringTerms",
        "backend-getGenomicVariants",
        "backend-getIndividuals",
        "backend-getInfo",
        "backend-getMap",
        "backend-getProjects",
        "backend-getRuns",
        "backend-indexer",
        "backend-logEmailDelivery",
        "backend-performQuery",
        "backend-splitQuery",
        "backend-submitDataset",
        "backend-updateFiles"
      ]
      log_group_prefix = "/aws/lambda/sbeacon-"
    }
    svep = {
      functions = [
        "backend-batchStarter",
        "backend-batchSubmit",
        "backend-clearTempAndRegions",
        "backend-concat",
        "backend-concatPages",
        "backend-concatStarter",
        "backend-createPages",
        "backend-deleteClinicalWorkflow",
        "backend-formatOutput",
        "backend-getResultsURL",
        "backend-initQuery",
        "backend-pluginClinvar",
        "backend-pluginConsequence",
        "backend-pluginGnomad",
        "backend-pluginGnomadConstraint",
        "backend-pluginGnomadOneKG",
        "backend-qcFigures",
        "backend-qcNotes",
        "backend-queryGTF",
        "backend-queryVCF",
        "backend-sendJobEmail",
        "backend-updateReferenceFiles"
      ]
      log_group_prefix = "/aws/lambda/svep-"
    }
  }

  # Build resource names with environment context
  resource_names = {
    log_bucket = "${local.resource_prefix[local.env]}-genomic-event-${var.aws_account_id_destination}"
    firehose   = "${local.resource_prefix[local.env]}-genomic-event-delivery"
    lambda     = "${local.resource_prefix[local.env]}-genomic-event-trails"
    athena_db  = "${local.resource_prefix[local.env]}_genomic-event"
  }
}