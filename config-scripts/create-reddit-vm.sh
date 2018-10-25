#!/bin/bash
gcloud compute instances create reddit-app \
--image-family reddit-full \
--machine-type g1-small \
--tags puma-server \
--zone europe-west1-b \
--restart-on-failure
