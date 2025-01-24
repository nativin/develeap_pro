#!/bin/zsh

# יצירת תיקיות
mkdir -p nginx/static
mkdir -p project/flask-app/templates

# העתקת קבצים סטטיים
cp -r project/flask-app/static/* nginx/static/
cp project/flask-app/templates/index.html nginx/

# יצירת Dockerfile-elasticsearch
cat > Dockerfile-elasticsearch << 'EOF'
FROM elasticsearch:7.17.13
EOF

# יצירת Dockerfile-nginx
cat > Dockerfile-nginx << 'EOF'
FROM nginx:alpine
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/static /usr/share/nginx/html/static
COPY nginx/index.html /usr/share/nginx/html/
EOF

# יצירת Dockerfile-flask בתיקייה המתאימה
cat > project/flask-app/Dockerfile-flask << 'EOF'
FROM alpine:3.11 as builder
RUN apk add --no-cache python2 py2-pip nodejs npm
WORKDIR /app
COPY . .
RUN npm install && npm run build
RUN pip install -r requirements.txt

FROM alpine:3.11
RUN apk add --no-cache python2
COPY --from=builder /usr/lib/python2.7/site-packages /usr/lib/python2.7/site-packages
COPY --from=builder /app/app.py /app/
COPY --from=builder /app/templates /app/templates
WORKDIR /app
EXPOSE 5000
ENTRYPOINT ["python", "./app.py"]
EOF

# יצירת nginx.conf
cat > nginx/nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    upstream flask {
        server flask:5000;
    }

    server {
        listen 80;
        server_name localhost;

        location /static/ {
            root /usr/share/nginx/html;
            try_files $uri $uri/ =404;
        }

        location / {
            proxy_pass http://flask;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
}
EOF

# יצירת docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  elasticsearch:
    build:
      context: .
      dockerfile: Dockerfile-elasticsearch
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ports:
      - "9200:9200"

  flask:
    build:
      context: ./project/flask-app
      dockerfile: Dockerfile-flask
    depends_on:
      - elasticsearch
    volumes:
      - ./project/flask-app:/app

  nginx:
    build:
      context: .
      dockerfile: Dockerfile-nginx
    ports:
      - "80:80"
    depends_on:
      - flask
EOF

chmod +x setup.sh