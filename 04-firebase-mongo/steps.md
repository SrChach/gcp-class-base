# 📖 Guía de Reproducción Completa: `igncursos`

Esta guía documenta paso a paso el procedimiento exacto para replicar desde cero la compilación, configuración de infraestructura en Google Cloud y despliegue del proyecto **Payload CMS 3.x + Next.js Standalone + Firestore Mongo API + Cloud Run + Google Cloud Storage**.

---

## 📌 Requisitos Previos

* **Google Cloud SDK (`gcloud` CLI)** instalado y autenticado (`gcloud auth login`).
* **Node.js**: `>=20.9.0`.
* **GNU Make**: *(Opcional)* Para ejecutar automatizaciones con `Makefile`.
* **Proyecto de GCP**: `clases-gcp-500802` (Región: `northamerica-south1`).

---

## 🛠️ Paso 1: Configurar Entorno Local y Variables (`.env`)

1. **Ingresar al directorio del proyecto**:
   ```bash
   cd /home/zombyegru/gcp-class/04-firebase-mongo/igncursos
   ```

2. **Crear o verificar el archivo `.env`**:
   ```env
   # Conexión a Firestore Database (API MongoDB vía TLS en puerto 443)
   DATABASE_URL=mongodb://nasho:<password>@bb1bb5f3-0f1c-48b6-9091-c9b3c15fc23c.nam5.firestore.goog:443/demo-cms-payload?loadBalanced=true&tls=true&authMechanism=SCRAM-SHA-256&retryWrites=false
   PAYLOAD_SECRET=6c579091ddf4756a91e9e4c8

   # Configuración de Google Cloud Platform (GCP)
   PROJECT_ID=clases-gcp-500802
   REGION=northamerica-south1
   GAR_REPO_NAME=cloud-run-source-deploy
   RUN_SERVICE_NAME=igncursos
   IMAGE_NAME=igncursos
   IMAGE_TAG=v1
   GCS_BUCKET=igncursos-media
   GCS_PREFIX=webcourses
   ```

3. **Habilitar salida Standalone en Next.js** ([`next.config.ts`](file:///home/zombyegru/gcp-class/04-firebase-mongo/igncursos/next.config.ts)):
   ```typescript
   const nextConfig: NextConfig = {
     output: 'standalone',
     // ...
   }
   ```

---

## ⚙️ Paso 2: Crear la Service Account y Bucket en GCP

### 2.1. Crear la Service Account dedicada (`igncursos-sa`)
```bash
gcloud iam service-accounts create igncursos-sa \
  --description="Service Account dedicada para igncursos en Cloud Run y GCS" \
  --display-name="igncursos Service Account" \
  --project="clases-gcp-500802"
```

### 2.2. Crear el Bucket de Google Cloud Storage
```bash
gcloud storage buckets create gs://igncursos-media \
  --location=northamerica-south1 \
  --uniform-bucket-level-access \
  --project="clases-gcp-500802"
```

### 2.3. Asignar Permiso de IAM a la Service Account en el Bucket
```bash
gcloud storage buckets add-iam-policy-binding gs://igncursos-media \
  --member="serviceAccount:igncursos-sa@clases-gcp-500802.iam.gserviceaccount.com" \
  --role="roles/storage.objectAdmin"
```

---

## 📦 Paso 3: Integración de Google Cloud Storage en Payload CMS

1. **Instalar el complemento oficial**:
   ```bash
   npm install @payloadcms/storage-gcs
   ```

2. **Fijar versión en `package.json`** ([`package.json`](file:///home/zombyegru/gcp-class/04-firebase-mongo/igncursos/package.json)):
   Asegurar que `@payloadcms/storage-gcs` tenga la misma versión que `payload` (`"3.87.0"`):
   ```json
   "@payloadcms/storage-gcs": "3.87.0"
   ```

3. **Configurar el plugin en [`src/payload.config.ts`](file:///home/zombyegru/gcp-class/04-firebase-mongo/igncursos/src/payload.config.ts)**:
   ```typescript
   import { gcsStorage } from '@payloadcms/storage-gcs'

   export default buildConfig({
     // ...
     plugins: [
       gcsStorage({
         collections: {
           media: {
             prefix: process.env.GCS_PREFIX || 'webcourses',
           },
         },
         bucket: process.env.GCS_BUCKET || 'igncursos-media',
         options: {},
       }),
     ],
   })
   ```

4. **Automatizar la generación del mapa de importaciones (`importMap`) en `package.json`**:
   ```json
   "build": "cross-env NODE_OPTIONS=\"--no-deprecation --max-old-space-size=8000\" payload generate:importmap && next build"
   ```

---

## 🐳 Paso 4: Optimización del `Dockerfile` y `.dockerignore`

1. **Crear [`.dockerignore`](file:///home/zombyegru/gcp-class/04-firebase-mongo/igncursos/.dockerignore)** para acelerar la copia de archivos:
   ```text
   node_modules
   .next
   .git
   coverage
   ```

2. **[`Dockerfile`](file:///home/zombyegru/gcp-class/04-firebase-mongo/igncursos/Dockerfile) multietapa optimizado**:
   ```dockerfile
   FROM node:22.17.0-alpine AS base

   FROM base AS deps
   RUN apk add --no-cache libc6-compat
   WORKDIR /app
   COPY package.json package-lock.json* ./
   RUN npm install --legacy-peer-deps

   FROM base AS builder
   WORKDIR /app
   COPY --from=deps /app/node_modules ./node_modules
   COPY . .
   ENV NEXT_TELEMETRY_DISABLED=1
   RUN mkdir -p public && npm run build

   FROM base AS runner
   WORKDIR /app
   ENV NODE_ENV=production NEXT_TELEMETRY_DISABLED=1 PORT=3000 HOSTNAME="0.0.0.0"
   RUN addgroup --system --gid 1001 nodejs && adduser --system --uid 1001 nextjs
   RUN mkdir .next && chown nextjs:nodejs .next
   COPY --from=builder /app/public ./public
   COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
   COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
   USER nextjs
   EXPOSE 3000
   CMD ["node", "server.js"]
   ```

---

## 🚀 Paso 5: Compilación y Despliegue Automatizado

### Usando `Makefile`

1. **Verificar menú de ayuda**:
   ```bash
   make help
   ```

2. **Probar servidor local con Hot Reload**:
   ```bash
   make dev
   ```

3. **Validar ejecutable de producción localmente**:
   ```bash
   make build-up
   ```

4. **Compilar, subir a Artifact Registry y desplegar en Cloud Run (Todo en 1)**:
   ```bash
   make deploy-all
   ```

---

## 🔍 Paso 6: Verificación y Debugging

1. **Obtener URL del servicio**:
   Abre la URL generada por Cloud Run en tu navegador (ej: `https://igncursos-1022480551944.northamerica-south1.run.app/admin`).
2. **Probar subida a GCS**:
   Sube una imagen desde la colección **Media** del panel administrativo y verifica su existencia en GCS:
   ```bash
   gcloud storage ls gs://igncursos-media/webcourses/
   ```
3. **Monitorear Logs de Cloud Run**:
   ```bash
   gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=igncursos" --limit 30 --format="table(timestamp, textPayload, jsonPayload.message)"
   ```
