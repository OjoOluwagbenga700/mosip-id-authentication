# Production Deployment Guide

## Overview

- **Local**: `./deploy.sh` - For development only
- **Production**: Docker Hub images - For production servers
- **CI/CD**: GitHub Actions - Automated build & push

## Production Deployment

### 1. **Prerequisites**
```bash
# On production server
sudo apt update
sudo apt install docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
```

### 2. **Create Production docker-compose.yml**
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:13
    environment:
      POSTGRES_DB: mosip_ida
      POSTGRES_USER: idauser
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: always
    networks:
      - ida-network

  ida-auth-service:
    image: yourusername/ida-auth-service:latest
    ports:
      - "8090:8090"
    environment:
      - spring_profiles_active=prod
      - mosip_ida_database_hostname=postgres
      - mosip_ida_database_password=${DB_PASSWORD}
    depends_on:
      - postgres
    restart: always
    networks:
      - ida-network

  ida-internal-service:
    image: yourusername/ida-internal-service:latest
    ports:
      - "8093:8093"
    environment:
      - spring_profiles_active=prod
      - mosip_ida_database_hostname=postgres
    depends_on:
      - postgres
    restart: always
    networks:
      - ida-network

  ida-otp-service:
    image: yourusername/ida-otp-service:latest
    ports:
      - "8092:8092"
    environment:
      - spring_profiles_active=prod
      - mosip_ida_database_hostname=postgres
    depends_on:
      - postgres
    restart: always
    networks:
      - ida-network

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - ida-auth-service
      - ida-internal-service
      - ida-otp-service
    restart: always
    networks:
      - ida-network

volumes:
  postgres_data:

networks:
  ida-network:
    driver: bridge
```

### 3. **Environment Variables**
```bash
# Create .env file
cat > .env << EOF
DB_PASSWORD=secure_password_here
DOCKER_HUB_USERNAME=yourusername
EOF
```

### 4. **Deploy to Production**
```bash
# Pull latest images
docker-compose pull

# Start services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

### 5. **Production URLs**
- **Authentication**: https://yourdomain.com/idauthentication/v1
- **Internal**: https://yourdomain.com:8093/idauthentication/v1
- **OTP**: https://yourdomain.com:8092/idauthentication/v1

## CI/CD Workflow

### 1. **Development Flow**
```bash
# Local development
./deploy.sh dev build
./deploy.sh dev deploy

# Commit changes
git add .
git commit -m "feature: new authentication logic"
git push origin feature/auth-update
```

### 2. **Production Release**
```bash
# Merge to main (triggers CI/CD)
git checkout main
git merge feature/auth-update
git push origin main

# GitHub Actions will:
# 1. Build Maven project
# 2. Create Docker images
# 3. Push to Docker Hub
# 4. Run tests
```

### 3. **Production Update**
```bash
# On production server
docker-compose pull
docker-compose up -d
```

## Monitoring

### Health Checks
```bash
# Service health
curl https://yourdomain.com/idauthentication/v1/actuator/health

# Container status
docker-compose ps

# Resource usage
docker stats
```

### Logs
```bash
# Application logs
docker-compose logs ida-auth-service

# Database logs
docker-compose logs postgres

# All logs
docker-compose logs
```

## Backup & Recovery

### Database Backup
```bash
# Backup
docker-compose exec postgres pg_dump -U idauser mosip_ida > backup.sql

# Restore
docker-compose exec -T postgres psql -U idauser mosip_ida < backup.sql
```

### Image Backup
```bash
# Save images
docker save yourusername/ida-auth-service:latest > ida-auth.tar
docker save yourusername/ida-internal-service:latest > ida-internal.tar
docker save yourusername/ida-otp-service:latest > ida-otp.tar

# Load images
docker load < ida-auth.tar
```

## Security

### SSL/TLS Setup
```bash
# Generate certificates
sudo certbot --nginx -d yourdomain.com

# Auto-renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

### Firewall
```bash
# Allow only necessary ports
sudo ufw allow 22    # SSH
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS
sudo ufw enable
```