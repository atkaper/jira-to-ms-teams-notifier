#!/bin/bash

docker rm -f jira-to-ms-teams-notifier

docker run -d --name jira-to-ms-teams-notifier --restart=always \
	   -v `pwd`/transform-jira-to-ms-teams.json:/go/src/github.com/Comcast/eel/config-handlers/tenant1/default.json \
	   -p 8080:8080 \
	   eel-dev:0.1 bin/eel -loglevel info

