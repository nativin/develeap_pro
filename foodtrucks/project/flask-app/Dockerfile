FROM alpine:3.11 as builder
RUN apk add --no-cache python2 py2-pip nodejs npm curl
WORKDIR /app
COPY . .
RUN mkdir -p /app/static/build
RUN npm install && npm run build
RUN ls -la /app/static/build

FROM alpine:3.11
RUN apk add --no-cache python2 py2-pip curl
WORKDIR /app
COPY --from=builder /app/app.py ./
COPY --from=builder /app/requirements.txt ./
COPY --from=builder /app/templates ./templates
COPY --from=builder /app/static ./static
RUN pip install -r requirements.txt
EXPOSE 5000
CMD ["python", "app.py"]