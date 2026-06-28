#!/bin/bash

# Terminar la ejecución si algún comando falla
set -e

# Colores para la terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # Sin color

echo -e "${BLUE}================================================================${NC}"
echo -e "${BLUE}  Script de Automatización: Compilación y Push a Artifact Registry ${NC}"
echo -e "${BLUE}================================================================${NC}"

# 1. Verificar si el archivo .env existe
if [ ! -f .env ]; then
    echo -e "${RED}[ERROR] El archivo .env no existe en el directorio actual.${NC}"
    echo -e "${YELLOW}[TIP] Copia la plantilla ejecutando: cp .env.example .env y completa los campos.${NC}"
    exit 1
fi

# 2. Cargar variables de entorno
echo -e "${BLUE}[1/4] Cargando variables de entorno desde .env...${NC}"
# Filtramos comentarios y exportamos variables
export $(grep -v '^#' .env | xargs)

# Validar variables obligatorias
if [ -z "$GCP_PROJECT_ID" ] || [ -z "$GCP_REGION" ] || [ -z "$GCP_ARTIFACT_REPO" ]; then
    echo -e "${RED}[ERROR] Faltan variables requeridas en el archivo .env (GCP_PROJECT_ID, GCP_REGION o GCP_ARTIFACT_REPO).${NC}"
    exit 1
fi

echo -e "  - Proyecto GCP ID: ${GREEN}$GCP_PROJECT_ID${NC}"
echo -e "  - Región de GCP:  ${GREEN}$GCP_REGION${NC}"
echo -e "  - Repositorio AR: ${GREEN}$GCP_ARTIFACT_REPO${NC}"

REGISTRY_PATH="$GCP_REGION-docker.pkg.dev/$GCP_PROJECT_ID/$GCP_ARTIFACT_REPO"

# 3. Autenticación de Docker con Google Cloud
echo -e "\n${BLUE}[2/4] Configurando autenticación de Docker con Artifact Registry...${NC}"
gcloud auth configure-docker "$GCP_REGION-docker.pkg.dev" --quiet

# 4. Construcción de las imágenes Docker
echo -e "\n${BLUE}[3/4] Construyendo imágenes de contenedores...${NC}"

echo -e "${YELLOW}>> Construyendo [01-nginx-basic]...${NC}"
docker build -t "$REGISTRY_PATH/nginx-basic:v1" ./01-nginx-basic

echo -e "${YELLOW}>> Construyendo [02-frontend-multi-stage] (React + Vite)...${NC}"
docker build -t "$REGISTRY_PATH/frontend-multi-stage:v1" ./02-frontend-multi-stage

echo -e "${YELLOW}>> Construyendo [03-backend-fastapi] (FastAPI + Python)...${NC}"
docker build -t "$REGISTRY_PATH/backend-fastapi:v1" ./03-backend-fastapi

echo -e "${GREEN}[OK] Todas las imágenes se compilaron exitosamente.${NC}"

# 5. Push de las imágenes a GCP Artifact Registry
echo -e "\n${BLUE}[4/4] Subiendo imágenes a Artifact Registry...${NC}"

echo -e "${YELLOW}>> Subiendo [nginx-basic:v1]...${NC}"
docker push "$REGISTRY_PATH/nginx-basic:v1"

echo -e "${YELLOW}>> Subiendo [frontend-multi-stage:v1]...${NC}"
docker push "$REGISTRY_PATH/frontend-multi-stage:v1"

echo -e "${YELLOW}>> Subiendo [backend-fastapi:v1]...${NC}"
docker push "$REGISTRY_PATH/backend-fastapi:v1"

echo -e "\n${GREEN}================================================================${NC}"
echo -e "${GREEN}  ¡Proceso completado con éxito! 🚀${NC}"
echo -e "${GREEN}================================================================${NC}"
echo -e "Puedes ver tus imágenes en la consola de GCP usando este enlace:"
echo -e "${BLUE}https://console.cloud.google.com/artifacts/docker/$GCP_PROJECT_ID/$GCP_REGION/$GCP_ARTIFACT_REPO?project=$GCP_PROJECT_ID${NC}\n"
