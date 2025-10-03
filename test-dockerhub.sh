#!/bin/bash

# Test Docker Hub Images Script

DOCKER_HUB_USERNAME=${1:-"yourusername"}

echo "🧪 Testing Docker Hub Images for: $DOCKER_HUB_USERNAME"

# Pull latest images
echo "📥 Pulling images from Docker Hub..."
docker pull $DOCKER_HUB_USERNAME/ida-auth-service:latest
docker pull $DOCKER_HUB_USERNAME/ida-internal-service:latest
docker pull $DOCKER_HUB_USERNAME/ida-otp-service:latest

# Create test docker-compose
cat > docker-compose-test.yml << EOF
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

  ida-auth-service:
    image: $DOCKER_HUB_USERNAME/ida-auth-service:latest
    ports:
      - "8090:8090"
    environment:
      - spring_profiles_active=docker
      - mosip_ida_database_hostname=postgres
    depends_on:
      - postgres

  ida-internal-service:
    image: $DOCKER_HUB_USERNAME/ida-internal-service:latest
    ports:
      - "8093:8093"
    environment:
      - spring_profiles_active=docker
      - mosip_ida_database_hostname=postgres
    depends_on:
      - postgres

  ida-otp-service:
    image: $DOCKER_HUB_USERNAME/ida-otp-service:latest
    ports:
      - "8092:8092"
    environment:
      - spring_profiles_active=docker
      - mosip_ida_database_hostname=postgres
    depends_on:
      - postgres
EOF

# Start services
echo "🚀 Starting services..."
docker compose -f docker-compose-test.yml up -d

# Wait for startup
echo "⏳ Waiting for services to start..."
sleep 60

# Test services
echo "🔍 Testing services..."
for i in {1..10}; do
  echo "Attempt $i/10"
  
  # Test auth service
  if curl -s http://localhost:8090/idauthentication/v1/actuator/health > /dev/null; then
    echo "✅ Auth Service (8090) - OK"
    AUTH_OK=true
  else
    echo "❌ Auth Service (8090) - Not Ready"
    AUTH_OK=false
  fi
  
  # Test OTP service
  if curl -s http://localhost:8092/idauthentication/v1/actuator/health > /dev/null; then
    echo "✅ OTP Service (8092) - OK"
    OTP_OK=true
  else
    echo "❌ OTP Service (8092) - Not Ready"
    OTP_OK=false
  fi
  
  # Test internal service
  if curl -s http://localhost:8093/idauthentication/v1/actuator/health > /dev/null; then
    echo "✅ Internal Service (8093) - OK"
    INTERNAL_OK=true
  else
    echo "❌ Internal Service (8093) - Not Ready"
    INTERNAL_OK=false
  fi
  
  if [ "$AUTH_OK" = true ] && [ "$OTP_OK" = true ] && [ "$INTERNAL_OK" = true ]; then
    echo "🎉 All services are healthy!"
    break
  fi
  
  sleep 10
done

# Show logs if services failed
if [ "$AUTH_OK" != true ]; then
  echo "=== Auth Service Logs ==="
  docker compose -f docker-compose-test.yml logs ida-auth-service | tail -20
fi

# Cleanup
echo "🧹 Cleaning up..."
docker compose -f docker-compose-test.yml down
rm docker-compose-test.yml

echo "✅ Test completed!"