#!/bin/bash

# sBeacon Functions
sbeacon_functions=(
  "admin"
  "backend-admin"
  "backend-dataPortal"
  "backend-deidentifyFiles"
  "backend-getAnalyses"
  "backend-getBiosamples"
  "backend-getConfiguration"
  "backend-getDatasets"
  "backend-getEntryTypes"
  "backend-getFilteringTerms"
  "backend-getGenomicVariants"
  "backend-getIndividuals"
  "backend-getInfo"
  "backend-getMap"
  "backend-getProjects"
  "backend-getRuns"
  "backend-indexer"
  "backend-logEmailDelivery"
  "backend-performQuery"
  "backend-splitQuery"
  "backend-submitDataset"
  "backend-updateFiles"
)

# sVEP Functions
svep_functions=(
  "backend-concatStarter"
  "backend-getResultsURL"
  "backend-initQuery"
  "backend-pluginConsequence"
  "backend-queryGTF"
  "backend-queryVCF"
  "concat"
  "concatPages"
  "concatStarter"
  "createPages"
  "getResultsURL"
  "initQuery"
  "pluginConsequence"
  "pluginUpdownstream"
  "queryGTF"
  "queryVCF"
)

# Import sBeacon Log Groups
for func in "${sbeacon_functions[@]}"; do
  echo "Importing sBeacon log group for $func..."
  terraform import "module.cloudtrail.aws_cloudwatch_log_group.sbeacon_functions[\"${func}\"]" "/aws/lambda/sbeacon-${func}"
done

# Import sVEP Log Groups
for func in "${svep_functions[@]}"; do
  echo "Importing sVEP log group for $func..."
  terraform import "module.cloudtrail.aws_cloudwatch_log_group.svep_functions[\"${func}\"]" "/aws/lambda/svep-${func}"
done

echo "-- ALL DONE --"