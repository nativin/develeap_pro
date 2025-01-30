#!/bin/sh

# Wait for MySQL to be ready
while ! nc -z db 3306; do 
  echo "Waiting for MySQL..."; 
  sleep 1; 
done

# Run Lavagna with the provided environment variables
exec java -Ddatasource.dialect=$DATASOURCE_DIALECT \
    -Ddatasource.url=$DATASOURCE_URL \
    -Ddatasource.username=$DATASOURCE_USERNAME \
    -Ddatasource.password=$DATASOURCE_PASSWORD \
    -Dspring.profiles.active=$SPRING_PROFILES_ACTIVE \
    -jar lavagna-jetty-console.war
