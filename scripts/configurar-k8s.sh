#!/bin/bash

KUBECONFIG=$(kubectl --namespace crossplane-system get secret proyecto-eks-cluster --output jsonpath="{.data.kubeconfig}" | base64 -d)
kubectl -n crossplane-system create secret generic cluster-config --from-literal=kubeconfig="${KUBECONFIG}"
#echo "$KUBECONFIG"
kubectl apply -f ../config-kubernetes.yaml
