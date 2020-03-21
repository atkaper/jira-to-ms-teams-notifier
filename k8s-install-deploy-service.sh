#!/bin/bash

. ./env.inc

kubectl --context $CTX apply -n $NS -f k8s.yml
