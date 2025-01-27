#!/bin/sh
while ! nc -z db 3306; do echo "Waiting for MySQL..."; sleep 1; done
exec java "-Ddatasource.dialect=MYSQL" \
    "-Ddatasource.url=jdbc:mysql://db:3306/lavagna?autoReconnect=true&useSSL=false" \
    "-Ddatasource.username=lavagna_user" \
    "-Ddatasource.password=lavagna_pass" \
    "-Dspring.profiles.active=dev" \
    -jar lavagna.war