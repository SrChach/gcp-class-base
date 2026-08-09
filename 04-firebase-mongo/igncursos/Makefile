# ==========================================
# Makefile - Automatización para igncursos (Payload CMS)
# ==========================================

# Cargar variables automáticamente del archivo .env si existe
ifneq (,$(wildcard ./.env))
    include .env
    export $(shell sed 's/=.*//' .env)
endif

# Variables de GCP (con valores por defecto sobreescribibles)
PROJECT_ID       ?= clases-gcp-500802
REGION           ?= northamerica-south1
GAR_REPO_NAME    ?= cloud-run-source-deploy
RUN_SERVICE_NAME ?= igncursos
IMAGE_NAME       ?= igncursos
IMAGE_TAG        ?= v1
SERVICE_ACCOUNT  ?= igncursos-sa@$(PROJECT_ID).iam.gserviceaccount.com
GCS_BUCKET       ?= igncursos-media
GCS_PREFIX       ?= webcourses

FULL_IMAGE_URI   := $(REGION)-docker.pkg.dev/$(PROJECT_ID)/$(GAR_REPO_NAME)/$(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: help dev build-image build-up build-down gcp-auth gcp-build gcp-deploy deploy-all

help: ## Muestra este menú de ayuda
	@echo "Comandos disponibles en igncursos:"
	@grep -hE '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

dev: ## Servidor de desarrollo local con Hot Reload (npm run dev)
	npm run dev

build-image: ## Compila la imagen Docker localmente (Valida compilado de producción)
	docker build -t igncursos:local .

build-up: ## Compila y ejecuta en Docker (Valida ejecutable de producción listo para desplegar)
	docker compose up --build

build-down: ## Detiene y limpia los contenedores creados con docker compose
	docker compose down

gcp-auth: ## Autentica Docker con Google Artifact Registry
	gcloud auth configure-docker $(REGION)-docker.pkg.dev

gcp-build: ## Compila y sube la imagen a Artifact Registry usando Cloud Build
	gcloud builds submit --tag "$(FULL_IMAGE_URI)" .

gcp-deploy: ## Despliega el contenedor a Cloud Run inyectando variables del .env
	gcloud run deploy $(RUN_SERVICE_NAME) \
		--image="$(FULL_IMAGE_URI)" \
		--platform=managed \
		--region="$(REGION)" \
		--service-account="$(SERVICE_ACCOUNT)" \
		--allow-unauthenticated \
		--port=3000 \
		--set-env-vars="DATABASE_URL=$(DATABASE_URL),PAYLOAD_SECRET=$(PAYLOAD_SECRET),GCS_BUCKET=$(GCS_BUCKET),GCS_PREFIX=$(GCS_PREFIX)"

deploy-all: gcp-build gcp-deploy ## Compila, sube a Artifact Registry y despliega en Cloud Run (Todo en 1)
