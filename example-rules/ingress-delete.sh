#!/bin/bash

kubectl delete -f ingress-1.yml
kubectl delete -f ingress-2.yml
kubectl delete -f ingress-3.yml
kubectl delete -f ingress-4.yml
kubectl delete -f ingress-5.yml
kubectl delete -f ingress-6.yml

kubectl delete ns other-ns

