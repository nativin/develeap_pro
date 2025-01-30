# Stage 1 - Build with Maven
FROM maven:3.6.3-openjdk-8 AS builder
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Stage 2 - Run with lightweight JRE
FROM openjdk:8-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/lavagna-jetty-console.war /app/lavagna-jetty-console.war
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]
