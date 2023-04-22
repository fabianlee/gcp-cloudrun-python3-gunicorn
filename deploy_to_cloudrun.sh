#!/bin/bash
# Deploys to GCP CloudRun


# enable GCP project level services
export PYTHONWARNINGS="ignore:Unverified HTTPS request"
gcloud services enable cloudbuild.googleapis.com artifactregistry.googleapis.com

# setup variables
app_name="${PWD##*/}"
region=$(gcloud config get compute/region)
project_id=$(gcloud config get project)
[[ (-n "$region") && (-n "$project_id") ]] || { echo "ERROR could not pull region or project id"; exit 1; }

set -x

# deploy to CloudRun
gcloud run deploy $app_name --source=. --region=$region --ingress=all --allow-unauthenticated --execution-environment=gen2 --no-use-http2 --update-env-vars "MAINTENANCE_MESSAGE=This is the Cloud Run maintenance message" --quiet

# show details of deployment
gcloud run services list
gcloud run services describe $app_name --region=$region

set +x

# test pull of content
run_url=$(gcloud run services describe $app_name --region=$region --format='value(status.url)')
echo "Cloud Run URL: $run_url"
curl $run_url
