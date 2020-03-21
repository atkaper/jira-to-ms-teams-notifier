#!/bin/bash

docker rm -f jira-to-ms-teams-notifier

# start eel server
docker run -d --name jira-to-ms-teams-notifier \
	   -v `pwd`/transform-jira-to-ms-teams.json:/go/src/github.com/Comcast/eel/config-handlers/tenant1/default.json \
	   -p 8080:8080 \
	   eel-dev:0.1 bin/eel -loglevel debug

#!/bin/bash

# send test request
curl -s -X POST --data @example-jira-data.json http://localhost:8080/v1/sync/events >test.out 2>&1

# show logs, and stop eel server
docker logs jira-to-ms-teams-notifier 2>&1 | grep --color -i -e ^ -e error
docker rm -f jira-to-ms-teams-notifier

echo "========================================================================================================"
echo "Copy/paste below json in teams playground for preview:  https://messagecardplayground.azurewebsites.net/"
echo "========================================================================================================"
cat test.out
echo
echo "========================================================================================================"
rm -rf test.out

