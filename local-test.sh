#!/bin/bash

# Note: /v1/sync/events is a test endpoint, which ECHOES the transformed data.
# The "real" endpoint for sending to MS-Teams is: /v1/events

curl -X POST --data @example-jira-data.json http://localhost:8080/v1/sync/events

