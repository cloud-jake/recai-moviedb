#!/bin/bash

source variables.inc

# Create Bigquery Tables for Event Data for Retail API

# add-to-cart
# https://cloud.google.com/retail/docs/user-events#add-to-cart-min


bq mk -t ${PROJECT}:movielens.user_events_add-to-cart ./schema/add-to-cart.json

bq mk -t ${PROJECT}:movielens.user_events_autocomplete ./schema/autocomplete.json

bq mk -t ${PROJECT}:movielens.user_events_category-page-view ./schema/category-page-view.json

bq mk -t ${PROJECT}:movielens.user_events_detail-page-view ./schema/detail-page-view.json

bq mk -t ${PROJECT}:movielens.user_events_home-page-view ./schema/home-page-view.json

bq mk -t ${PROJECT}:movielens.user_events_purchase-complete ./schema/purchase-complete.json

bq mk -t ${PROJECT}:movielens.user_events_search ./schema/search.json

bq mk -t ${PROJECT}:movielens.user_events_shopping-cart-page-view ./schema/shopping-cart-page-view.json