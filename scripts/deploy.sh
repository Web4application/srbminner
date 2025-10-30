#!/bin/bash
echo "Deploying SRBMinner..."
docker-compose build
docker-compose up -d
echo "Deployment complete."
