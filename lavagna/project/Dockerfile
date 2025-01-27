# Build stage
FROM maven:3.6.3-openjdk-8 AS builder
WORKDIR /app
COPY . .
RUN mvn clean package && mvn stampo:build

# Run stage
FROM openjdk:8-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/lavagna-jetty-console.war /app/lavagna.war
COPY entrypoint.sh /app/
RUN apk add --no-cache netcat-openbsd && chmod +x /app/entrypoint.sh
CMD ["sh", "/app/entrypoint.sh"]