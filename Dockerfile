FROM node:20-alpine AS base
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# Set build-time environment variables
ARG VITE_STORAGE_MODE=local
ARG VITE_API_BASE_URL=http://localhost:3001/api
ARG VITE_APP_VERSION
ARG VITE_FEATURE_USE_CUSTOM_VERSION_UPDATE
ARG VITE_FEATURE_DEMO_MODE
ARG VITE_FEATURE_BETA_LANGUAGES
ARG VITE_FEATURE_NOTIFICATIONS

# Set as environment variables (used during Vite build)
ENV VITE_STORAGE_MODE=${VITE_STORAGE_MODE}
ENV VITE_API_BASE_URL=${VITE_API_BASE_URL}
ENV VITE_APP_VERSION=${VITE_APP_VERSION}
ENV VITE_FEATURE_USE_CUSTOM_VERSION_UPDATE=${VITE_FEATURE_USE_CUSTOM_VERSION_UPDATE}
ENV VITE_FEATURE_DEMO_MODE=${VITE_FEATURE_DEMO_MODE}
ENV VITE_FEATURE_BETA_LANGUAGES=${VITE_FEATURE_BETA_LANGUAGES}
ENV VITE_FEATURE_NOTIFICATIONS=${VITE_FEATURE_NOTIFICATIONS}

FROM base AS development
EXPOSE 5173
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
FROM base AS build

RUN npm run build

FROM nginx:alpine AS production
COPY --from=build /app/dist /usr/share/nginx/html
RUN echo 'server { \
    listen 80; \
    server_name localhost; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html; \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
