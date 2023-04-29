## gcp-cloudrun-python3-gunicorn

Test and deploy GCP Cloud Run Python Gunicorn web application.


### Getting Started with local development
```
# make sure essential OS packages are installed
sudo apt-get install software-properties-common python3 python3-dev python3-pip python3-venv make curl git -y

# download project
git clone https://github.com/fabianlee/gcp-cloudrun-python3-gunicorn.git
cd gcp-cloudrun-python3-gunicorn

# create and load virtual env
python3 -m venv .
source bin/activate
pip install -r requirements.txt

# run Python Flask app locally, open local browser to http://localhost:8080
python3 -m hellomodule.app run --port 8080

# OR run Gunicorn locally, open local browser to http://localhost:8080
gunicorn --config gunicorn.conf.py --log-config=gunicorn-logging.conf hellomodule.app:app
```

### Deploying to GCP CloudRun with single deploy command

```
# enable GCP project level services
export PYTHONWARNINGS="ignore:Unverified HTTPS request"
gcloud services enable cloudbuild.googleapis.com artifactregistry.googleapis.com run.googleapis.com

# setup variables
app_name="${PWD##*/}"
region=$(gcloud config get compute/region)
project_id=$(gcloud config get project)

# deploy to GCP Cloud Run
gcloud run deploy $app_name --source=. --region=$region --ingress=all --allow-unauthenticated --execution-environment=gen2 --no-use-http2 --quiet

# show details of deployment
gcloud run services list
gcloud run services describe $app_name --region=$region

# test pull of content
run_url=$(gcloud run services describe $app_name --region=$region --format='value(status.url)')
echo "CloudRun app at: $run_url"
curl $run_url
```

### Deploying to GCP CloudRun with separate build and deploy commands

```
# make sure Artifact Registry repo exists
repo_name=cloud-run-source-deploy
gcloud artifacts repositories create $repo_name --repository-format=docker --location=$region

# build image 1.0.0
gcloud builds submit --tag ${region}-docker.pkg.dev/$project_id/$repo_name/$app_name:1.0.0 .

# deploy using explicit 1.0.0 image
gcloud run deploy $app_name --region=$region --ingress=all --allow-unauthenticated --execution-environment=gen2 --no-use-http2 --image ${region}-docker.pkg.dev/$project_id/$repo_name/$app_name:1.0.0 --quiet

```

### Show logs of Cloud Run app

```
gcloud logging read "resource.type = \"cloud_run_revision\" AND resource.labels.service_name = \"$app_name\" AND resource.labels.location = $region AND severity>=DEFAULT AND textPayload !=''" --format="value(textPayload)" --limit 10
```

### Connect Github to to GCP Cloud Build trigger

See my full blog article below for building a GCP Continuous Deployment pipeline by connecting a remote GitHub repository.

https://fabianlee.org/2023/04/29/gcp-cloud-run-with-build-trigger-coming-from-remote-github-repository/

