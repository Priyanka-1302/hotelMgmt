#!/bin/bash
set -e

REGION="ap-south-1"
ECR_URI=601512582150.dkr.ecr.ap-south-1.amazonaws.com/wild-oasis
IMAGE_TAG=$(cat /home/ubuntu/deployment/IMAGE_TAG)

echo ">>> Logging into ECR..."
aws ecr get-login-password --region $REGION | \
  docker login --username AWS --password-stdin $ECR_URI

echo ">>> Pulling image..."
docker pull $ECR_URI:$IMAGE_TAG

echo ">>> Stopping old container..."
docker stop wild-oasis 2>/dev/null || true
docker rm wild-oasis 2>/dev/null || true

echo ">>> Starting new container..."
docker run -d \
  --name wild-oasis \
  --restart unless-stopped \
  -p 3000:3000 \
  --env-file /home/ubuntu/.env.production \
  $ECR_URI:$IMAGE_TAG

echo ">>> Deployed successfully!"