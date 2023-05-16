#!/bin/bash

source variables.inc

gcloud config set project $PROJECT 
PROJECT_ID=`gcloud config get-value project`


# Create Bigquery Views
# https://cloud.google.com/retail/docs/movie-rec-tutorial#create_views

bq mk --project_id=${PROJECT} \
 --use_legacy_sql=false \
 --view '
 SELECT
   CAST(movies.movieId AS string) AS id,
   SUBSTR(title, 0, 128) AS title,
   SPLIT(genres, "|") AS categories,
   CONCAT("https://www.imdb.com/title/tt",links.imdbId) AS uri
 FROM `'${PROJECT}'.movielens.movies` movies
 LEFT JOIN `'${PROJECT}'.movielens.links` links
 ON movies.movieID = links.movieid' \
movielens.products

bq mk --project_id=${PROJECT} \
 --use_legacy_sql=false \
 --view '
 WITH t AS (
   SELECT
     MIN(UNIX_SECONDS(time)) AS old_start,
     MAX(UNIX_SECONDS(time)) AS old_end,
     UNIX_SECONDS(TIMESTAMP_SUB(
       CURRENT_TIMESTAMP(), INTERVAL 90 DAY)) AS new_start,
     UNIX_SECONDS(CURRENT_TIMESTAMP()) AS new_end
   FROM `'${PROJECT}'.movielens.ratings`)
 SELECT
   CAST(userId AS STRING) AS visitorId,
   "detail-page-view" AS eventType,
   FORMAT_TIMESTAMP(
     "%Y-%m-%dT%X%Ez",
     TIMESTAMP_SECONDS(CAST(
       (t.new_start + (UNIX_SECONDS(time) - t.old_start) *
         (t.new_end - t.new_start) / (t.old_end - t.old_start))
     AS int64))) AS eventTime,
   [STRUCT(STRUCT(movieId AS id) AS product)] AS productDetails,
 FROM `'${PROJECT}'.movielens.ratings`, t
 WHERE rating >= 4' \
movielens.user_event

# create add-to-cart for >= 4.5
bq mk --project_id=${PROJECT} \
 --use_legacy_sql=false \
 --view '
 WITH t AS (
   SELECT
     MIN(UNIX_SECONDS(time)) AS old_start,
     MAX(UNIX_SECONDS(time)) AS old_end,
     UNIX_SECONDS(TIMESTAMP_SUB(
       CURRENT_TIMESTAMP(), INTERVAL 90 DAY)) AS new_start,
     UNIX_SECONDS(CURRENT_TIMESTAMP()) AS new_end
   FROM `'${PROJECT}'.movielens.ratings`)
 SELECT
   CAST(userId AS STRING) AS visitorId,
   "add-to-cart" AS eventType,
   FORMAT_TIMESTAMP(
     "%Y-%m-%dT%X%Ez",
     TIMESTAMP_SECONDS(CAST(
       (t.new_start + (UNIX_SECONDS(time) - t.old_start) *
         (t.new_end - t.new_start) / (t.old_end - t.old_start))
     AS int64))) AS eventTime,
   [STRUCT(STRUCT(movieId AS id) AS product,1 as quantity)] AS productDetails,
 FROM `'${PROJECT}'.movielens.ratings`, t
 WHERE rating >= 4.5' \
movielens.user_events_addtocart

# purchase-complete >=5

bq mk --project_id=${PROJECT} \
 --use_legacy_sql=false \
 --view '
 WITH t AS (
   SELECT
     MIN(UNIX_SECONDS(time)) AS old_start,
     MAX(UNIX_SECONDS(time)) AS old_end,
     UNIX_SECONDS(TIMESTAMP_SUB(
       CURRENT_TIMESTAMP(), INTERVAL 90 DAY)) AS new_start,
     UNIX_SECONDS(CURRENT_TIMESTAMP()) AS new_end
   FROM `'${PROJECT}'.movielens.ratings`)
 SELECT
   CAST(userId AS STRING) AS visitorId,
   "purchase-complete" AS eventType,
   FORMAT_TIMESTAMP(
     "%Y-%m-%dT%X%Ez",
     TIMESTAMP_SECONDS(CAST(
       (t.new_start + (UNIX_SECONDS(time) - t.old_start) *
         (t.new_end - t.new_start) / (t.old_end - t.old_start))
     AS int64))) AS eventTime,
   [STRUCT(STRUCT(movieId AS id,STRUCT(1 as price,"USD" as currencyCode) AS priceInfo) AS product,1 as quantity)] AS productDetails,
   STRUCT(
    movieId as id,
    1 as revenue,
    null as tax,
    null as cost,
    "USD" as currencyCode ) AS purchaseTransaction
 FROM `'${PROJECT}'.movielens.ratings`, t
 WHERE rating >= 5' \
movielens.user_events_purchasecomplete