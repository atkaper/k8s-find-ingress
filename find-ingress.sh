#!/bin/bash

# This script lists all ingress rules for a given hostname.
#
# To use this, you need to have some tools installed:
#
# - kubectl  : to query kubernetes
# - jq       : to process json (a recent version, older versions do not know about $ENV handling)
# - column   : to format data in a table
#
# Only tested on linux.
#
# Thijs Kaper, July 8. 2021.

if [ "$1" == "" ]
then
   echo "Usage: $0 hostname"
   echo "Example: $0 www.kaper.com"
   echo
   echo "The following hostnames are available:"
   echo
   kubectl get --all-namespaces ingress -o json | jq -r '.items[].spec.rules[].host' | sort -u
   exit 1
fi

export HOST=$1

(
    echo "HOST PATH NAMESPACE SERVICE PORT INGRESS REWRITE"
    echo "---- ---- --------- ------- ---- ------- -------"
    kubectl get --all-namespaces ingress -o json | \
        jq -r '.items[] | . as $parent | .spec.rules[] | select(.host==$ENV.HOST) | .host as $host | .http.paths[] | ( $host + " " + .path + " " + $parent.metadata.namespace + " " + .backend.service.name + " " + (.backend.service.port.number // .backend.service.port.name | tostring) + " " + $parent.metadata.name + " " + $parent.metadata.annotations."nginx.ingress.kubernetes.io/rewrite-target")' | \
        sort
) | column -s\  -t


