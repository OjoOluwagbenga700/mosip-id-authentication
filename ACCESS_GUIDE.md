# MOSIP ID Authentication - Access Guide

## Deployment Options

### Option 1: Local Development
```bash
# Build and run locally
./deploy.sh dev build
./deploy.sh dev deploy
./deploy.sh dev status
```

### Option 2: Production (Docker Hub)
```bash
# Pull from Docker Hub and run
docker pull yourusername/ida-auth-service:latest
docker pull yourusername/ida-internal-service:latest
docker pull yourusername/ida-otp-service:latest
docker-compose up -d
```

### Option 3: GitHub Actions (Automated)
```bash
# Push to trigger CI/CD
git push origin main
```

## Service Access

### Main Services
| Service | URL | Port | Purpose |
|---------|-----|------|---------|
| Authentication | http://localhost:8090/idauthentication/v1 | 8090 | Main auth API |
| Internal Auth | http://localhost:8093/idauthentication/v1 | 8093 | Internal operations |
| OTP Service | http://localhost:8092/idauthentication/v1 | 8092 | OTP generation/validation |

### Health Checks
```bash
curl http://localhost:8090/idauthentication/v1/actuator/health
curl http://localhost:8092/idauthentication/v1/actuator/health  
curl http://localhost:8093/idauthentication/v1/actuator/health
```

### API Documentation
- **Swagger UI**: http://localhost:8090/idauthentication/v1/swagger-ui.html
- **OpenAPI Spec**: http://localhost:8090/idauthentication/v1/v3/api-docs

## Sample API Calls

### 1. Generate OTP
```bash
curl -X POST http://localhost:8092/idauthentication/v1/otp \
  -H "Content-Type: application/json" \
  -d '{
    "id": "mosip.identity.otp",
    "version": "1.0", 
    "requestTime": "2024-01-01T10:00:00.000Z",
    "request": {
      "individualId": "123456789",
      "otpChannel": ["email", "sms"]
    }
  }'
```

### 2. Authenticate with OTP
```bash
curl -X POST http://localhost:8090/idauthentication/v1/auth \
  -H "Content-Type: application/json" \
  -d '{
    "id": "mosip.identity.auth",
    "version": "1.0",
    "requestTime": "2024-01-01T10:00:00.000Z", 
    "request": {
      "individualId": "123456789",
      "otp": "123456"
    }
  }'
```

### 3. Demographic Authentication
```bash
curl -X POST http://localhost:8090/idauthentication/v1/auth \
  -H "Content-Type: application/json" \
  -d '{
    "id": "mosip.identity.auth",
    "version": "1.0",
    "requestTime": "2024-01-01T10:00:00.000Z",
    "request": {
      "individualId": "123456789",
      "demographics": {
        "name": [{"language": "eng", "value": "John Doe"}],
        "dob": "1990/01/01"
      }
    }
  }'
```

## Database Access
- **Host**: localhost:5432
- **Database**: mosip_ida
- **User**: idauser
- **Password**: mosip123

```bash
# Connect to database
docker-compose exec postgres psql -U idauser -d mosip_ida

# View tables
\dt
```

## Troubleshooting

### Check Logs
```bash
./deploy.sh dev logs
```

### Restart Services
```bash
./deploy.sh dev stop
./deploy.sh dev deploy
```

### Check Docker Status
```bash
docker-compose ps
docker-compose logs ida-auth-service
```

## Development

### Build Only
```bash
./deploy.sh dev build
```

### Local Testing
```bash
# Run tests
cd authentication
mvn test

# Package without tests
mvn clean package -DskipTests=true
```