#!/bin/bash

source variables.inc

# Before you Begin
# https://cloud.google.com/retail/docs/movie-rec-tutorial#before-you-begin

# Create Project
gcloud projects create $PROJECT
gcloud config set project $PROJECT 

# Attach Billing
gcloud beta billing projects link $PROJECT --billing-account=$BILLING_ACCOUNT

PROJECT_ID=`gcloud config get-value project`

echo "Project named ${PROJECT} created with project ID of ${PROJECT_ID}"
