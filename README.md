# Send new created Jira ticket info to MS-Teams Channels:
---

For background, and explanations, see blog post [https://www.kaper.com/cloud/send-new-created-jira-ticket-info-to-ms-teams-channels/](https://www.kaper.com/cloud/send-new-created-jira-ticket-info-to-ms-teams-channels/).

## Summary

To get a Microsoft Teams chat notification in a team channel for each newly created (Atlassian) Jira ticket, you can use this project. You need to deploy this as a service for transforming and forwarding Jira messages to Teams. Note: we use this with our own hosted Jira. Not with the Jira as a service on public web!

## Build the container

Build the needed "EEL" container using the ```build-docker-image.sh``` script.
It will clone the [Comcast EEL git project](https://github.com/Comcast/eel), execute the docker build, and optionally push the result to your docker repository.
Make sure to change the version number in the script before building a new one. And if needed, configure your docker repository details in the script.

## Configure Channels

Configure channels (webhooks) for MS-Teams in the ```transform-jira-to-ms-teams.json``` script. The Jira Project Code to channel URI (path) translation happens near the top of that file, in a section called ```CustomProperties```. There are three example projects and a default put in there. You can define as many as you like. You need to keep the "default" in there also, pointing to some generic channel for non-matched project codes.

To find the value to be used, you need to create a Channel in Teams, and configure an "Incoming Webhook" Connector. You copy the URL from there, and just use the "path" (the part without "https://outlook.office.com" as value in the ```CustomProperties``` section.

## Run transformation test

Use the ```local-single-transform-test.sh``` file to run a single message transformation test. It starts the docker image in debug mode, takes the example-jira-data.json message, and sends it to the container in an "echo" mode. The resulting json (suitable for teams), is echoed back. You can use this to tweak the transform script if needed. The result json can be copied to a microsoft message test playground. The playground url will be shown on screen (Note: the playground preview style is not the same as the real MS-Teams).

Optionally, you could also change the curl statement in the test script from ```/v1/sync/events``` into ```/v1/events```, which will not echo the transformation, but send it to MS-Teams.

## Running in docker

See ```local-docker-run.sh``` for an example on how to run the EEL container in docker.
Change this into whatever you need to run this on a suitable server somewhere. Note: there is no security/authentication on the listening port of this service. We do run this in a private kubernetes cluster next to our Jenkins installation (not in plain docker), so we do not have a problem with this. But do realize that if you run this somewhere, where the general public can reach the listening port, then your Teams Channels will be flooded with silly (or mainly empty) messages. You CAN fix this, by adding authentication. I have not yet tried this (perhaps later). How to do this -> You need to use the "Match" entry, and match a request header to a proper value. For example the Authorization header, for the proper authentication. And make sure to configure this also on the Jira sending end.

## Running in Kubernetes

We run this setup in the same kubernetes cluster, as in which our Jira is running.

Start by editing the ```env.inc``` file, to setup the required namespace and cluster context name, for use by the kubectl commands.

The ```transform-jira-to-ms-teams.json``` needs to be deployed to K8S in a configmap. You can do this by running script ```k8s-deploy-configmap.sh```.

Run the ```k8s-install-deploy-service.sh``` script to apply the k8s.yml file to install the
deployment, and the service.

If needed, you can use the ```k8s-delete-deploy-service.sh``` script to remove the container.

As we are running this in the cluster next to Jira, we did not need exposure to the outside of the cluster. If you do need this exposure, you either need to add an Ingress rule, or add a NodePort to the service definition. I suggest you add that to the k8s.yml, before installing it. Note: IF you expose this service from the outside of the cluster, then keep in mind that there is NO authentication. See section on running in Docker about this note and a possible fix suggestion.

## Configure Jira WebHook

In Jira, go to ```"System" -> "WebHooks"``` to configure the webhook. In our system that page lives on https://jira.OURSERVER.nl/plugins/servlet/webhooks

For our case, running in the same cluster, I used the following data:
```
Name: Jira2Teams-On-Ticket-Create
URL: http://jira-to-ms-teams-notifier.jira2teams/v1/events
And enable the "Issue -> Create" checkbox.
```

Note: the "test" transformation endpoint in EEL is "/v1/sync/events", which just echoes back the transformed json. The "real" EEL endpoint, which sends the message to MS-Teams is "/v1/events".

## Adding new MS Teams Channels

If you want to ADD a new MS-Teams channel to the routing, put it in the
```transform-jira-to-ms-teams.json``` script. See description above to find where/how.

To *activate* the change, run ```k8s-deploy-configmap.sh``` (if you are running in kubernetes), and it will also *restart* the running EEL container for you.

If you were running in plain docker, just restart the docker image, and make sure it uses the updated ```transform-jira-to-ms-teams.json``` file.

## The End

I hope this nice little project does help you out. I quite like the Comcast EEL container. Very handy!

Thijs Kaper, March 12, 2020.

