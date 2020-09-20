#!/bin/bash

#echo "Create a new GKE cluster..."
#
#CLUSTER_NAME=speech-audio-annotation
#gcloud container clusters create $CLUSTER_NAME --num-nodes=2 --machine-type=n1-standard-2


#echo "Reserve a new static IP on GCP..."
#gcloud compute addresses create speech-annotation-ip --global


echo "Setting env for gcp..."

export PROJECT_ID=speech-audio-annotation
CLUSTER_NAME=speech-audio-annotation

gcloud container clusters get-credential $CLUSTER_NAME


echo "Creating persistent volume claims"

kubectl apply -f ./kubernetes-gcp/persistent-volume-claim.yml


echo "Building system images for both backend and frontend..."

VERSION="v1.0"

pushd ./speech-audio-annotation
docker build -t gcr.io/${PROJECT_ID}/speech-audio-annotation_flask:$VERSION .
popd

pushd ./speech-audio-annotation-ui
docker build -f Dockerfile-k8s-gcp -t gcr.io/${PROJECT_ID}/speech-audio-annotation-ui_react:$VERSION .
popd


echo "Pushing docker images to GCP Container Registry..."

gcloud auth configure-docker
docker push gcr.io/${PROJECT_ID}/speech-audio-annotation_flask:$VERSION
docker push gcr.io/${PROJECT_ID}/speech-audio-annotation-ui_react:$VERSION


echo "Creating the flask deployment and service..."

kubectl apply -f ./kubernetes-gcp/flask-deployment.yml
kubectl apply -f ./kubernetes-gcp/flask-service.yml


echo "Adding the ingress..."

kubectl apply -f ./kubernetes-gcp/gke-ingress.yml


echo "Creating the react deployment and service..."

kubectl apply -f ./kubernetes-gcp/react-deployment.yml
kubectl apply -f ./kubernetes-gcp/react-service.yml
