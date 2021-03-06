#!/bin/bash

echo "Starting minikube..."

minikube start --memory 8g

echo "Setting docker env..."

eval $(minikube docker-env)

echo "Creating persistent volumes and claims"

kubectl apply -f ./kubernetes/persistent-volume.yml
kubectl apply -f ./kubernetes/persistent-volume-claim.yml


echo "Building system images for both backend and frontend..."

pushd ./speech-audio-annotation
docker build -t speech-audio-annotation_flask:latest .
popd

pushd ./speech-audio-annotation-ui
docker build -f Dockerfile-k8s -t speech-audio-annotation-ui_react:latest .
popd

echo "Creating the flask deployment and service..."

kubectl apply -f ./kubernetes/flask-deployment.yml
kubectl apply -f ./kubernetes/flask-service.yml


echo "Adding the ingress..."

minikube addons enable ingress
kubectl apply -f ./kubernetes/minikube-ingress.yml
echo "$(minikube ip) speech.annotation" | sudo tee -a /etc/hosts


echo "Creating the react deployment and service..."

kubectl apply -f ./kubernetes/react-deployment.yml
kubectl apply -f ./kubernetes/react-service.yml
