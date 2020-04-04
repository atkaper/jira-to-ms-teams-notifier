#!/bin/bash

# Build  https://github.com/Comcast/eel
# JSON transformer

# This is the tag we use LOCALLY in our repo. It has no connection to eel version tags.
VERSIONTAG=0.1

# Info about your docker registry server
YOUR_REGISTRY_URL=
YOUR_REGISTRY_USER=
YOUR_REGISTRY_PASSWORD=

# terminate script on (first) error
set -e

# check if this is a new build, or a re-build using existing source folder "eel"
if [ -d eel ]
then
   cd eel
   git pull
else
   # original EEL repo:
   # git clone https://github.com/Comcast/eel.git
   # or if you want a smaller image, need a proxy, or need reading of query string from caller url, use my fork:
   git clone https://github.com/atkaper/eel.git
   cd eel
fi

# execute the docker build
docker build -t eel-dev:$VERSIONTAG .

if [ "$YOUR_REGISTRY_PASSWORD" != "" ]
then
   # optional registry login
   docker login -u $YOUR_REGISTRY_USER -p $YOUR_REGISTRY_PASSWORD $YOUR_REGISTRY_URL
fi

if [ "$YOUR_REGISTRY_URL" != "" ]
then
   # re-tag, and push
   docker tag eel-dev:$VERSIONTAG $YOUR_REGISTRY_URL/eel:$VERSIONTAG
   docker push $YOUR_REGISTRY_URL/eel:$VERSIONTAG
fi

if [ "$YOUR_REGISTRY_URL" != "" ]
then
   echo "Images:"
   echo "  eel-dev:$VERSIONTAG"
   echo "  $YOUR_REGISTRY_URL/eel:$VERSIONTAG"
else
   echo "Image:"
   echo "  eel-dev:$VERSIONTAG"
fi


