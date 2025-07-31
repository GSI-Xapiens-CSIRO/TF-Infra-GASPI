#!/bin/bash

# sBeacon Functions
sbeacon_functions=(
  "admin"
  "backend-admin"
  "backend-dataPortal"
  "backend-deidentifyFiles"
  "backend-generateCohortVCfs"
  "backend-generateReports"
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
  "backend-batchStarter"
  "backend-batchSubmit"
  "backend-clearTempAndRegions"
  "backend-concat"
  "backend-concatPages"
  "backend-concatStarter"
  "backend-createPages"
  "backend-deleteClinicalWorkflow"
  "backend-formatOutput"
  "backend-getResultsURL"
  "backend-initQuery"
  "backend-pluginClinvar"
  "backend-pluginConsequence"
  "backend-pluginGnomad"
  "backend-pluginGnomadConstraint"
  "backend-pluginGnomadOneKG"
  "backend-qcFigures"
  "backend-qcNotes"
  "backend-queryGTF"
  "backend-queryVCF"
  "backend-sendJobEmail"
  "backend-updateReferenceFiles"
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