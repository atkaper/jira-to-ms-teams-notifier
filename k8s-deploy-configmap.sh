#!/bin/bash

. ./env.inc

# Convert json to config-map yaml, and apply it to the cluster.
# This is a trick to make this script repeatable for both initial create, and further updates.
kubectl --context $CTX create configmap jira-to-ms-teams-notifier -n $NS --from-file=transform-jira-to-ms-teams.json -o yaml --dry-run | kubectl --context $CTX apply -n $NS -f -
