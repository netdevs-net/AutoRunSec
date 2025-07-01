# Stage 1: (Optional) Build step placeholder
FROM alpine AS build
# Add build commands here, e.g. npm install && npm run build

# Stage 2: NGINX static server
FROM nginx:alpine
COPY www /usr/share/nginx/html
COPY infrastructure/components/frontend/nginx.conf /etc/nginx/nginx.conf
RUN find /usr/share/nginx/html -type d -exec chmod 755 {} \; \
 && find /usr/share/nginx/html -type f -exec chmod 644 {} \; \
 && chown -R nginx:nginx /usr/share/nginx/html
