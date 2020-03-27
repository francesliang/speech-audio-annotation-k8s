#!/bin/bash

echo "Createing the flask deployment and service..."

kubectl create -f ./kubernetes/flask-deployment.yml
kubectl create -f ./kubernetes/flask-service.yml


echo "Adding the ingress..."

minikube addons enable ingress
kubectl apply -f ./kubernetes/minikube-ingress.yml


echo "Creating the react deployment and service..."

kubectl create -f ./kubernetes/react-deployment.yml
kubectl create -f ./kubernetes/react-service.yml
