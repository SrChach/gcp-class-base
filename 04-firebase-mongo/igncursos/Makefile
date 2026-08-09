# ==========================================
# Makefile - Automatización para igncursos (Payload CMS)
# ==========================================

# Cargar variables automáticamente del archivo .env si existe
ifneq (,$(wildcard ./.env))
    include .env
    export $(shell sed 's/=.*//' .env)
endif

# Variables de GCP (con valores por defecto sobreescribibles)
PROJECT_ID   ?= clases-gcp-500802
REGION       ?= northamerica-south1
REPO_NAME    ?= cloud-run-source-deploy
SERVICE_NAME ?= igncursos
IMAGE_NAME   ?= igncursos
TAG          ?= v1

IMAGE_TAG    := $(REGION)-docker.pkg.dev/$(PROJECT_ID)/$(REPO_NAME)/$(IMAGE_NAME):$(TAG)

.PHONY: help dev docker-build docker-up docker-down gcp-auth gcp-build gcp-deploy deploy-all

help: ## Muestra este menú de ayuda
	@echo "Comandos disponibles en igncursos:"
	@grep -hE '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

dev: ## Inicia el servidor de desarrollo local
	npm run dev

docker-build: ## Compila la imagen Docker localmente
	docker build -t igncursos:local .

docker-up: ## Compila y ejecuta los contenedores localmente con docker compose
	docker compose up --build

docker-down: ## Detiene y elimina los contenedores creados con docker compose
	docker compose down

gcp-auth: ## Autentica Docker con Google Artifact Registry
	gcloud auth configure-docker $(REGION)-docker.pkg.dev

gcp-build: ## Compila y sube la imagen a Artifact Registry usando Cloud Build
	gcloud builds submit --tag "$(IMAGE_TAG)" .

gcp-deploy: ## Despliega el contenedor a Cloud Run inyectando variables del .env
	gcloud run deploy $(SERVICE_NAME) \
		--image="$(IMAGE_TAG)" \
		--platform=managed \
		--region="$(REGION)" \
		--allow-unauthenticated \
		--port=3000 \
		--set-env-vars="DATABASE_URL=$(DATABASE_URL),PAYLOAD_SECRET=$(PAYLOAD_SECRET)"

deploy-all: gcp-build gcp-deploy ## Compila, sube a Artifact Registry y despliega en Cloud Run (Todo en 1)
