# Docker Hub Setup Guide

## Required GitHub Secrets

Set these secrets in your GitHub repository:

### 1. Go to Repository Settings
- Navigate to: `Settings` → `Secrets and variables` → `Actions`

### 2. Add Repository Secrets

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `DOCKER_HUB_USERNAME` | Your Docker Hub username | `myusername` |
| `DOCKER_HUB_TOKEN` | Docker Hub access token | `dckr_pat_xxxxx` |

### 3. Create Docker Hub Access Token

1. Login to [Docker Hub](https://hub.docker.com)
2. Go to `Account Settings` → `Security` → `Access Tokens`
3. Click `New Access Token`
4. Name: `GitHub Actions`
5. Permissions: `Read, Write, Delete`
6. Copy the generated token

## Docker Images Created

The workflow will create these images on Docker Hub:

- `{username}/ida-auth-service:latest`
- `{username}/ida-internal-service:latest` 
- `{username}/ida-otp-service:latest`

## Usage

### Manual Push to Docker Hub
```bash
# Build images
./deploy.sh dev build

# Tag for Docker Hub
docker tag ida-auth-service:latest {username}/ida-auth-service:latest
docker tag ida-internal-service:latest {username}/ida-internal-service:latest
docker tag ida-otp-service:latest {username}/ida-otp-service:latest

# Push to Docker Hub
docker push {username}/ida-auth-service:latest
docker push {username}/ida-internal-service:latest
docker push {username}/ida-otp-service:latest
```

### Pull from Docker Hub
```bash
docker pull {username}/ida-auth-service:latest
docker pull {username}/ida-internal-service:latest
docker pull {username}/ida-otp-service:latest
```

## Automated Workflow

- **Push to main/master/develop** → Build & Push to Docker Hub
- **Create PR** → Build only (no push)
- **Manual trigger** → Build & Push with environment selection

## Verify Setup

After setting up secrets, trigger the workflow:

1. Push to main branch, or
2. Go to `Actions` → `Build and Deploy ID Authentication Services` → `Run workflow`

Check Docker Hub for your images at: `https://hub.docker.com/u/{username}`