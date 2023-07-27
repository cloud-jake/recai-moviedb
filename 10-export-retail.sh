#!/bin/bash

source variables.inc

#Temp fix
PROJECT_ID=$PROJECT

# Generate Project Number
# gcloud command to get the Project_Number from a know PROJECT_ID
PROJECT_NUM=`gcloud projects describe $PROJECT_ID --format="value(projectNumber)"`

# Create BQ Dataset
# bq command to create a dataset ${EXPORT_DATASET} in Project $PROJECT_ID
bq mk --project_id ${PROJECT_ID} --dataset ${EXPORT_DATASET} 



# Create request.json

echo '{
  "outputConfig":
  {
    "bigqueryDestination":
    {
      "datasetId": "'${EXPORT_DATASET}'",
        "tableIdPrefix": "'${EXPORT_PREFIX}'",
        "tableType": "view"
    }
  }
}' > request.json


curl -X POST \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -H "Content-Type: application/json; charset=utf-8" \
    -H "x-goog-user-project: ${PROJECT_ID}" \
    -d @request.json \
    "https://retail.googleapis.com/v2alpha/projects/${PROJECT_ID}/locations/global/catalogs/default_catalog/userEvents:export"

curl -X POST \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -H "Content-Type: application/json; charset=utf-8" \
    -H "x-goog-user-project: ${PROJECT_ID}" \
    -d @request.json \
    "https://retail.googleapis.com/v2alpha/projects/${PROJECT_ID}/locations/global/catalogs/default_catalog/branches/0/products:export"

