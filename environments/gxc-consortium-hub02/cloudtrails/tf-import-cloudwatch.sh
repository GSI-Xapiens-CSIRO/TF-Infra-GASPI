#!/bin/bash

# sBeacon Functions
sbeacon_functions=(
  "admin"
  "dataPortal"
  "getAnalyses"
  "getBiosamples"
  "getConfiguration"
  "getDatasets"
  "getEntryTypes"
  "getFilteringTerms"
  "getGenomicVariants"
  "getIndividuals"
  "getInfo"
  "getMap"
  "getProjects"
  "getRuns"
  "indexer"
  "logEmailDelivery"
  "performQuery"
  "splitQuery"
  "submitDataset"
  "updateFiles"
)

# sVEP Functions
svep_functions=(
  "queryGTF"
  "initQuery"
  "getResultsURL"
  "queryVCF"
  "pluginConsequence"
  "concatStarter"
)

# Import sBeacon Log Groups
for func in "${sbeacon_functions[@]}"; do
  echo "Importing sBeacon log group for $func..."
  terraform import "module.cloudtrail.aws_cloudwatch_log_group.sbeacon_functions[\"backend-${func}\"]" "/aws/lambda/sbeacon-backend-${func}"
done

# Import sVEP Log Groups
for func in "${svep_functions[@]}"; do
  echo "Importing sVEP log group for $func..."
  terraform import "module.cloudtrail.aws_cloudwatch_log_group.svep_functions[\"backend-${func}\"]" "/aws/lambda/svep-backend-${func}"
done