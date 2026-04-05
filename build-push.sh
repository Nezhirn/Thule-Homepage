#!/bin/bash
set -e

# Configuration
IMAGE_NAME="thuleseeker/thule"
VERSION="latest"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}  Thule Homepage - Build & Push  ${NC}"
echo -e "${GREEN}================================${NC}"

# Step 1: Build the Docker image
echo -e "\n${YELLOW}[1/3] Building Docker image...${NC}"
docker build -t "${IMAGE_NAME}:${VERSION}" -t "${IMAGE_NAME}:1.0.0" .

echo -e "\n${GREEN}✓ Image built successfully${NC}"

# Step 2: Test the image (optional health check)
echo -e "\n${YELLOW}[2/3] Running quick test...${NC}"
CONTAINER_ID=$(docker run -d -p 8001:8000 "${IMAGE_NAME}:${VERSION}")
echo "  Container started: ${CONTAINER_ID}"

echo -e "  Waiting for service to start..."
sleep 5

# Check health endpoint
if curl -f http://localhost:8001/api/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Health check passed${NC}"
else
    echo -e "${RED}✗ Health check failed${NC}"
    docker logs "$CONTAINER_ID"
    docker stop "$CONTAINER_ID" > /dev/null 2>&1
    docker rm "$CONTAINER_ID" > /dev/null 2>&1
    exit 1
fi

# Cleanup test container
docker stop "$CONTAINER_ID" > /dev/null 2>&1
docker rm "$CONTAINER_ID" > /dev/null 2>&1

# Step 3: Push to registry
echo -e "\n${YELLOW}[3/3] Pushing image to Docker Hub...${NC}"
docker push "${IMAGE_NAME}:${VERSION}"
docker push "${IMAGE_NAME}:1.0.0"

echo -e "\n${GREEN}================================${NC}"
echo -e "${GREEN}  ✓ Done! Image pushed successfully  ${NC}"
echo -e "${GREEN}================================${NC}"
echo -e "\nImage: ${IMAGE_NAME}:${VERSION}"
echo -e "Tags: latest, 1.0.0"
echo -e "\nRun with:"
echo -e "  docker run -d -p 8000:8000 ${IMAGE_NAME}:${VERSION}"
echo -e "\n"
