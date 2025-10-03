#!/bin/bash

# MOSIP ID Authentication Docker Deployment Script

set -e

ENVIRONMENT=${1:-dev}
ACTION=${2:-deploy}
DOCKER_HUB_USERNAME=${DOCKER_HUB_USERNAME:-""}

echo "🚀 MOSIP ID Authentication Deployment"
echo "Environment: $ENVIRONMENT"
echo "Action: $ACTION"

case $ACTION in
  "build")
    echo "📦 Building services..."
    cd authentication
    mvn clean install -DskipTests=true -Dmaven.javadoc.skip=true -Dgpg.skip=true
    
    # Build Docker images
    if [ -n "$DOCKER_HUB_USERNAME" ]; then
      docker build -t $DOCKER_HUB_USERNAME/ida-auth-service:latest authentication-service/
      docker build -t $DOCKER_HUB_USERNAME/ida-internal-service:latest authentication-internal-service/
      docker build -t $DOCKER_HUB_USERNAME/ida-otp-service:latest authentication-otp-service/
    else
      docker build -t ida-auth-service:latest authentication-service/
      docker build -t ida-internal-service:latest authentication-internal-service/
      docker build -t ida-otp-service:latest authentication-otp-service/
    fi
    
    echo "✅ Build completed"
    ;;
    
  "deploy")
    echo "🚀 Deploying services..."
    
    # Create docker-compose file if not exists
    if [ ! -f docker-compose.yml ]; then
      echo "Creating docker-compose.yml..."
      cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:13
    environment:
      POSTGRES_DB: mosip_ida
      POSTGRES_USER: idauser
      POSTGRES_PASSWORD: mosip123
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  ida-auth-service:
    image: ${DOCKER_HUB_USERNAME:-ida}-auth-service:latest
    ports:
      - "8090:8090"
    environment:
      - spring_profiles_active=docker
      - mosip_ida_database_hostname=postgres
    depends_on:
      - postgres
    restart: unless-stopped

  ida-internal-service:
    image: ${DOCKER_HUB_USERNAME:-ida}-internal-service:latest
    ports:
      - "8093:8093"
    environment:
      - spring_profiles_active=docker
      - mosip_ida_database_hostname=postgres
    depends_on:
      - postgres
    restart: unless-stopped

  ida-otp-service:
    image: ${DOCKER_HUB_USERNAME:-ida}-otp-service:latest
    ports:
      - "8092:8092"
    environment:
      - spring_profiles_active=docker
      - mosip_ida_database_hostname=postgres
    depends_on:
      - postgres
    restart: unless-stopped

volumes:
  postgres_data:
EOF
    fi
    
    docker compose up -d
    echo "✅ Services deployed"
    ;;
    
  "stop")
    echo "🛑 Stopping services..."
    docker compose down
    echo "✅ Services stopped"
    ;;
    
  "status")
    echo "📊 Service status..."
    docker compose ps
    ;;
    
  "logs")
    echo "📋 Service logs..."
    docker compose logs -f
    ;;
    
  *)
    echo "Usage: $0 [environment] [build|deploy|stop|status|logs]"
    echo "Example: $0 dev build"
    echo "Example: $0 dev deploy"
    exit 1
    ;;
esac