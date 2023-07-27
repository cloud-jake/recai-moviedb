#!/bin/bash

# create table and materialized views from exported data
# Get dashboards that show key performance indicators
# https://cloud.google.com/retail/docs/get-dashboards-that-show-kpis

#TODO: 
# - update the export commands to use a Service Account
# - scheduler for BQ view to table with SA
# - further tune materialized view parameters


source variables.inc

# Convert your user event BigQuery view to a table
# https://cloud.google.com/retail/docs/get-dashboards-that-show-kpis#convert-your-user-event-bigquery-view-to-a-website-table


bq query --use_legacy_sql=false \
'CREATE OR REPLACE TABLE `'${PROJECT_ID}':'${EXPORT_DATASET}'.table_retail_user_events` 
AS SELECT * FROM `'${PROJECT_ID}':'${EXPORT_DATASET}'.'${EXPORT_PREFIX}'_retail_user_events`'




# Create a materialized view for sales
# https://cloud.google.com/retail/docs/get-dashboards-that-show-kpis#create-a-materialized-view-for-sales


bq query --use_legacy_sql=false \
'CREATE MATERIALIZED VIEW `'${PROJECT_ID}':'${EXPORT_DATASET}'.mv_sales` 
OPTIONS(
  friendly_name="Sales View",
  description="View of Sales Data",
  labels=[("team", "cloud_retail_solutions"), ("environment", "development")]
)
AS
SELECT
  EXTRACT(DATE FROM event_time) as day,
  session_id as session,
  ANY_VALUE(TRIM(UPPER(visitor_id))) as visitor,
  ANY_VALUE(TRIM(UPPER(user_info.user_id))) as user,
  ANY_VALUE(TRIM(UPPER(purchase_transaction.id))) as tx_id,
  MAX(purchase_transaction.revenue) as tx_total,
  MAX(purchase_transaction.tax) as tx_tax,
  MAX(purchase_transaction.cost) as tx_cost,
  MAX(purchase_transaction.currency_code) as tx_cur,
  SUM(d.quantity*d.product.price_info.price) as product_total,
  COUNT(d) AS basket_size
FROM `'${PROJECT_ID}':'${EXPORT_DATASET}'.table_retail_user_events`, UNNEST(product_details) d
WHERE event_type = 'purchase-complete'
GROUP BY EXTRACT(DATE FROM event_time), session_id;




echo "Bigquery installation complete."
echo ""
echo "Install the Looker Block"
echo "https://cloud.google.com/retail/docs/get-dashboards-that-show-kpis#install-the-looker-block"

echo ""

echo "Set the Configuration dialog:"
echo ""
echo "In the Events Table box, enter the project, dataset, and table IDs of the user event table that you exported to BigQuery. The format is project_id.dataset_id.table_id."
echo ""
echo "In the Products Table box, enter the project, dataset, and table IDs of the Retail product table that you exported to BigQuery. The format is project_id.dataset_id.table_id."
echo ""
echo "In the Sales Materialized View box, enter the project, dataset, and table IDs of the materialized view for sales that you created in Create a materialized view for sales. The format is project_id.dataset_id.table_id."