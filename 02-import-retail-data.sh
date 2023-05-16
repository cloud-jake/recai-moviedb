#!/bin/bash

source variables.inc

# Import Catalog Data

gcloud scheduler --project ${PROJECT} \
jobs create http import_catalog_wpjt7ydcq9sq \
--time-zone='America/Los_Angeles' \
--schedule='0 0 * * *' \
--uri='https://retail.googleapis.com/v2alpha/projects/'${PROJECT_ID}'/locations/global/catalogs/default_catalog/branches/0/products:import' \
--description='Import Retail catalog data' \
--headers='Content-Type: application/json; charset=utf-8' \
--http-method='POST' \
--message-body='{"inputConfig":{"bigQuerySource":{"projectId":"${PROJECT}","datasetId":"movielens","tableId":"products","dataSchema":"product"}},"reconciliationMode":"INCREMENTAL"}' \
--oauth-service-account-email='<<insert SA here>>'

# Import User Event Data

gcloud scheduler --project ${PROJECT} \
jobs create http import_event_g1djq3938t54 \
--time-zone='America/Los_Angeles' \
--schedule='0 0 * * *' \
--uri='https://retail.googleapis.com/v2alpha/projects/'${PROJECT_ID}'/locations/global/catalogs/default_catalog/userEvents:import' \
--description='Import Retail event data' \
--headers='Content-Type: application/json; charset=utf-8' \
--http-method='POST' \
--message-body='{"inputConfig":{"bigQuerySource":{"projectId":"${PROJECT}","datasetId":"movielens","tableId":"user_events","dataSchema":"user_event"}}}' \
--oauth-service-account-email='<<Insert SA here>>'