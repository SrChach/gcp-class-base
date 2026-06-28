# --- ETAPA 1: Compilación ---
FROM node:18-alpine AS builder

WORKDIR /app

# Copiar archivos de dependencias e instalarlas
COPY package*.json ./
RUN npm ci

# Copiar el código fuente y compilar la aplicación
COPY . .
RUN npm run build

# --- ETAPA 2: Servidor de Producción ---
FROM nginx:alpine

# Copiar los archivos compilados desde la etapa 'builder'
COPY --from=builder /app/dist /usr/share/nginx/html

# Exponer el puerto por defecto de Nginx
EXPOSE 80

# Iniciar Nginx
CMD ["nginx", "-g", "daemon off;"]
