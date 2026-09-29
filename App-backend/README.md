# App-backend

Backend microservices architecture for the ResQMesh system.

## Microservices Overview

| Service | Port | Description | Database |
| :--- | :--- | :--- | :--- |
| **`auth-service`** | `8081` | Authentication, JWT issuing, user verification (email/phone OTP), team management | `auth_db`, `team_db` |
| **`device-service`** | `8082` | LoRa device registration, telemetry ingestion, device status tracking | `lora_device_db` |
| **`user-service`** | `8083` | User profiles, emergency contacts, medical information | `lora_user_db` |
| **`sos_service`** | `8085` | SOS alert creation, rescue coordination, alert status dispatch | `rescue_db` |

## Project Structure

```
App-backend/
├── pom.xml
├── .gitignore
├── .env.example
├── README.md
└── backend/
    ├── auth-service/
    │   ├── pom.xml
    │   └── src/
    ├── device-service/
    │   ├── pom.xml
    │   └── src/
    ├── sos_service/
    │   ├── pom.xml
    │   └── src/
    └── user-service/
        ├── pom.xml
        └── src/
```

## Configuration

Configure environment variables or application properties before running:
- `DB_HOST`: MySQL host (default: `localhost`)
- `DB_PORT`: MySQL port (default: `3306`)
- `DB_USERNAME`: Database username (default: `root`)
- `DB_PASSWORD`: Database password
- `JWT_SECRET`: Secret key for JWT signing and verification
- `RESEND_API_KEY`: API key for Resend email service (OTP delivery)

## Running the Services

Each service is a Spring Boot application and can be run independently:

```bash
# Auth Service
cd backend/auth-service
mvn spring-boot:run

# Device Service
cd backend/device-service
mvn spring-boot:run

# User Service
cd backend/user-service
mvn spring-boot:run

# SOS Service
cd backend/sos_service
mvn spring-boot:run
```
