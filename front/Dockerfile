# Build stage
FROM node:20.19.0-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --cache .npm --prefer-offline
COPY . .
RUN npm run build

# Runtime stage
FROM nginx:1.27-alpine
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY --from=build /app/dist/olympic-games-starter/browser /app
EXPOSE 80
