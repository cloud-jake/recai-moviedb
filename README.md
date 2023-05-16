# recai-moviedb
## Create personalized movie recommendations

### Prerequisites:
- GCP billing account
- terminal with Google Cloud SDK installed (Cloud Shell is fine)

### How to get started:

1 - In a terminal, clone git repo:
    git clone https://github.com/cloud-jake/recai-moviedb.git

2 - cd into the new directory: 
    cd recai-moviedb 

3 - Update variables.inc
    - PROJECT
    - BILLING_ACCOUNT

4 - Run the provisioning scripts:
    - 00-project-setup.sh - Creates project, assigns billing, and enables services
    - 01a-prepare-dataset.sh - load movielens data to Bigquery
    - 01b-create-views.sh - create user_event views in Bigquery
    
    The remaining scripts are optional

5 - Access the Retail API to complete the tutorial below.
    - https://console.cloud.google.com/ai/retail

## Based on tutorial here:
https://cloud.google.com/retail/docs/movie-rec-tutorial

Customizations added for user_events: search, home-page-view, add-to-cart, purchase-complete