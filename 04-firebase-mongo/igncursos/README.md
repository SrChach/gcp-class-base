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
* **Docker & Docker Compose**: (Opcional) para pruebas y despliegue contenerizado local.
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

## 🐳 Ejecución con Docker

### Compilación y Ejecución Local
El proyecto cuenta con un `Dockerfile` multietapa optimizado (`deps`, `builder`, `runner`) que empaqueta únicamente la salida `standalone` de Next.js.

Para levantar el entorno contenerizado localmente:

```bash
docker compose up --build
```

Accede a la interfaz administrativa en `http://localhost:3000/admin`.

---

## ☁️ Despliegue en Google Cloud

### 1. Compilación y Subida a Artifact Registry
```bash
export PROJECT_ID="tu-project-id"
export REGION="northamerica-south1"
export REPO_NAME="cloud-run-source-deploy"
export IMAGE_TAG="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/payload-cms:v1"

gcloud builds submit --tag "$IMAGE_TAG" .
```

### 2. Despliegue en Google Cloud Run
```bash
gcloud run deploy payload-cms \
  --image="$IMAGE_TAG" \
  --platform=managed \
  --region="$REGION" \
  --allow-unauthenticated \
  --port=3000 \
  --set-env-vars="DATABASE_URL=your_firestore_url,PAYLOAD_SECRET=your_secret"
```
