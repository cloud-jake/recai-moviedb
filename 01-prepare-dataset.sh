#!/bin/bash

source variables.inc

gcloud config set project $PROJECT 
PROJECT_ID=`gcloud config get-value project`

# Prepare the Dataset
# https://cloud.google.com/retail/docs/movie-rec-tutorial#prepare_the_dataset

# Import the Dataset

wget https://files.grouplens.org/datasets/movielens/ml-latest.zip
unzip ml-latest.zip

gsutil mb gs://${PROJECT}-movielens-data
gsutil cp ml-latest/movies.csv ml-latest/ratings.csv ml-latest/links.csv \
          gs://${PROJECT}-movielens-data

bq --location=$LOCATION mk --project_id=${PROJECT} --dataset "movielens"

bq load --skip_leading_rows=1 "${PROJECT}:movielens.movies" \
  gs://${PROJECT}-movielens-data/movies.csv \
  movieId:integer,title,genres

bq load --skip_leading_rows=1 "${PROJECT}:movielens.ratings" \
  gs://${PROJECT}-movielens-data/ratings.csv \
  userId:integer,movieId:integer,rating:float,time:timestamp

bq load  --skip_leading_rows=1 "${PROJECT}:movielens.links" \
  gs://${PROJECT}-movielens-data/links.csv \
  movieId:integer,imdbId:string,tmdbId:integer