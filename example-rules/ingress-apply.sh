#!/bin/bash

kubectl apply -f ingress-1.yml
kubectl apply -f ingress-2.yml
kubectl apply -f ingress-3.yml
kubectl apply -f ingress-4.yml

kubectl create ns other-ns
kubectl apply -f ingress-5.yml
kubectl apply -f ingress-6.yml


