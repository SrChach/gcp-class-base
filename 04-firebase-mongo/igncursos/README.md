# 📚 igncursos - Gestor de Cursos Personal (Payload CMS + Next.js)

`igncursos` es un sistema de gestión de contenidos (CMS) headless diseñado para la administración de cursos, usuarios y medios interactivos. Está desarrollado con **Payload CMS 3.x** integrado de forma nativa sobre **Next.js (App Router)**, utilizando **Google Cloud Firestore Database** (mediante la API de MongoDB) para la persistencia de datos y preparado para despliegues contenerizados en **Google Cloud Run**.

---

## 📌 Arquitectura del Sistema

* **Core**: Next.js 16 (App Router) + Payload CMS 3.x.
* **Base de Datos**: Google Cloud Firestore Database (API MongoDB / SCRAM-SHA-256).
* **Contenerización**: Docker Multi-stage con salida `standalone` de Next.js.
* **Plataforma de Despliegue**: Google Cloud Run & Google Artifact Registry.

---

## 🛠️ Requisitos Previos

* **Node.js**: versión `v20.9.0` o superior.
* **Gestor de paquetes**: `npm` o `pnpm`.
* **Google Cloud SDK (`gcloud` CLI)**: Autenticado (`gcloud auth login`) y configurado en el proyecto objetivo (`clases-gcp-500802`).
* **GNU Make**: *(Opcional)* Para automatizar comandos mediante `Makefile`. Requiere entorno Linux/POSIX (Cloud Shell, Linux, macOS, WSL2 o Git Bash) debido al uso de herramientas del sistema (`sed`, `grep`, `awk`).
* **Docker & Docker Compose**: *(Opcional)* Para pruebas y validación del ejecutable de producción local.
* **Instancia de Firestore Database**: Configurada en modo API MongoDB con autenticación SCRAM-SHA-256.

---

## ⚙️ Configuración de Variables de Entorno (`.env`)

Crea un archivo `.env` en la raíz del proyecto basándote en la plantilla de ejemplo:

```env
# Conexión a Firestore Database (API MongoDB vía TLS en puerto 443)
DATABASE_URL=mongodb://<usuario>:<password>@<cluster-id>.nam5.firestore.goog:443/<database_name>?loadBalanced=true&tls=true&authMechanism=SCRAM-SHA-256&retryWrites=false

# Clave secreta para la firma de tokens y sesiones de Payload CMS
PAYLOAD_SECRET=tu-clave-secreta-payload
```

> **Nota**: Si tu contraseña contiene caracteres especiales (como `@`, `#`, `/`), deben codificarse en formato URL-encode (ejemplo: `@` pasa a ser `%40`).

---

## 🚀 Uso en Desarrollo Local

1. **Instalar dependencias**:
   ```bash
   npm install
   ```

2. **Iniciar servidor de desarrollo**:
   ```bash
   npm run dev
   ```

3. **Endpoints de la aplicación**:
   * **Panel Administrativo**: `http://localhost:3000/admin`
   * **API GraphQL**: `http://localhost:3000/api/graphql`
   * **GraphQL Playground**: `http://localhost:3000/api/graphql-playground`
   * **REST API**: `http://localhost:3000/api/<colección>`

---

## 🐳 Validación del Compilado de Producción con Docker

> 💡 **Nota**: Los comandos `build-*` ejecutan la compilación de **producción (`standalone`)**. Se utilizan para **validar que el ejecutable esté 100% funcional y listo para desplegar** a Google Cloud Run antes de realizar el push.

* **`make build-up`**: Compila en modo producción y levanta los contenedores en `http://localhost:3000/admin` (equivale a `docker compose up --build`).
* **`make build-down`**: Detiene y limpia los contenedores locales (equivale a `docker compose down`).
* **`make build-image`**: Compila únicamente la imagen Docker localmente para validar el build.

---

## ☁️ Despliegue en Google Cloud

### Método Recomendado: Usando `Makefile`
Puedes compilar, subir a Artifact Registry y desplegar en Cloud Run en un solo comando:

```bash
make deploy-all
```

### Comandos Individuales con `make`:
* **`make help`**: Muestra la lista de comandos disponibles.
* **`make dev`**: Inicia el servidor local con Hot Reload (`npm run dev`).
* **`make gcp-build`**: Compila y sube la imagen a Artifact Registry (`igncursos:v1`).
* **`make gcp-deploy`**: Despliega el servicio `igncursos` en Cloud Run inyectando las variables de `.env`.

---

### Método Manual (Vía `gcloud` CLI)

```bash
export PROJECT_ID="clases-gcp-500802"
export REGION="northamerica-south1"
export GAR_REPO_NAME="cloud-run-source-deploy"
export RUN_SERVICE_NAME="igncursos"
export IMAGE_TAG="v1"
export FULL_IMAGE_URI="${REGION}-docker.pkg.dev/${PROJECT_ID}/${GAR_REPO_NAME}/igncursos:${IMAGE_TAG}"

# 1. Compilar y subir a Artifact Registry
gcloud builds submit --tag "$FULL_IMAGE_URI" .

# 2. Despliegue en Google Cloud Run
gcloud run deploy "$RUN_SERVICE_NAME" \
  --image="$FULL_IMAGE_URI" \
  --platform=managed \
  --region="$REGION" \
  --allow-unauthenticated \
  --port=3000 \
  --set-env-vars="DATABASE_URL=your_firestore_url,PAYLOAD_SECRET=your_secret"
```
