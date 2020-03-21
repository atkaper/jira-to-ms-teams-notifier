#!/bin/bash

. ./env.inc

kubectl --context $CTX delete -n $NS -f k8s.yml
