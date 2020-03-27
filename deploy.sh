#!/bin/bash

echo "Starting minikube..."

minikube start

echo "Setting docker env..."

eval $(minikube docker-env)

echo "Building system images for both backend and frontend..."

pushd ./speech-audio-annotation
docker build -t speech-audio-annotation_flask:latest .
popd

pushd ./speech-audio-annotation-ui
docker build -t speech-audio-annotation-ui_react:latest .
popd

echo "Createing the flask deployment and service..."

kubectl create -f ./kubernetes/flask-deployment.yml
kubectl create -f ./kubernetes/flask-service.yml


echo "Adding the ingress..."

minikube addons enable ingress
kubectl apply -f ./kubernetes/minikube-ingress.yml


echo "Creating the react deployment and service..."

kubectl create -f ./kubernetes/react-deployment.yml
kubectl create -f ./kubernetes/react-service.yml
