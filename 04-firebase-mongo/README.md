# 🌐 Gestor de Cursos Personal en Payload CMS (v3) + Firestore Mongo API & Cloud Run

En esta guía práctica aprenderás a desplegar una aplicación **Payload CMS** configurada como un **Gestor de Cursos Personal** en **Google Cloud Run**. La aplicación consumirá datos de **Firestore Database** (mediante la **API de MongoDB y autenticación SCRAM-SHA-256**) y servirá videos estáticos y multimedia alojados en la subcarpeta `payload-media` de tu bucket **Google Cloud Storage (GCS)**.

---

## 📌 Recursos Detectados y Configurados en el Proyecto

* **Proyecto de GCP**: `clases-gcp-500802`
* **Región**: `northamerica-south1`
* **Repositorio de Artifact Registry**: `cloud-run-source-deploy`
  * **Ruta completa de la imagen**: `northamerica-south1-docker.pkg.dev/clases-gcp-500802/cloud-run-source-deploy/payload-cms:v1`
* **Bucket de Google Cloud Storage (Media)**: `gs://liv-clases-gcp/`
* **Firestore MongoDB API URI (SCRAM)**: `mongodb://<username>:<password>@bb1bb5f3-0f1c-48b6-9091-c9b3c15fc23c.nam5.firestore.goog:443/demo-cms-payload?loadBalanced=true&tls=true&authMechanism=SCRAM-SHA-256&retryWrites=false`

---

## 🏗️ Arquitectura de Seguridad (Service Account Dedicada)

```mermaid
flowchart TD
    subgraph GCP IAM & Service Account
        A[payload-cms-sa@clases-gcp-500802.iam.gserviceaccount.com]
        A -->|Rol 1: roles/datastore.user| B[Firestore Database - Mongo API]
        A -->|Rol 2: roles/storage.objectAdmin| C[Bucket GCS: liv-clases-gcp]
    end

    subgraph Flujo de Contenedores & Cloud Run
        D[Cloud Build] -->|Push Image| E[Artifact Registry: cloud-run-source-deploy]
        E -->|Deploy con --service-account| F[Google Cloud Run]
        F -->|Usa Identidad SA| A
    end
```

---

## 🛡️ Pregunta Frecuente de Seguridad: ¿Se requiere generar un archivo de clave JSON para la Service Account?

**NO. En Google Cloud Run NO se debe generar un archivo de clave JSON (Key File).**

### Razones y Mejores Prácticas:
1. **Identidad Nativa de Cloud Run (`--service-account`)**: Al asociar la Service Account al servicio de Cloud Run con la bandera `--service-account="$SA_EMAIL"`, Google Cloud vincula automáticamente la identidad de la SA a la instancia en ejecución.
2. **Autenticación en Firestore mediante SCRAM**: Al utilizar autenticación **SCRAM-SHA-256** (usuario y contraseña generados en la consola de Firestore), se evitan problemas de *account impersonation* y permisos IAM complejos (OIDC). La identidad de la SA se reserva para el acceso a Google Cloud Storage.
3. **Cero Riesgos de Filtración de Llaves**: Al no crear archivos de claves estáticos `.json`, eliminamos el riesgo de subir accidentalmente credenciales privilegiadas a repositorios Git.
4. **Protección Preventiva en `.gitignore`**: Por seguridad adicional, hemos configurado los archivos `.gitignore` (tanto en la raíz del proyecto como en `payload-app/`) para ignorar automáticamente cualquier archivo de clave `*.json` que pudiera descargarse accidentalmente durante desarrollo local.

---

## 📋 Pasos Rápidos para Despliegue

### Paso 1: Definir variables de entorno en Cloud Shell
```bash
export PROJECT_ID="clases-gcp-500802"
export REGION="northamerica-south1"
export REPO_NAME="cloud-run-source-deploy"
export BUCKET_NAME="liv-clases-gcp"
export SA_NAME="payload-cms-sa"
export SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
export IMAGE_TAG="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/payload-cms:v1"
```

---

## 🔐 Paso 2: Paso a Paso para Crear la Service Account (SA)

Crearemos una Service Account dedicada exclusivamente para ejecutar la aplicación en Cloud Run bajo el principio de menor privilegio.

### 2.1: Crear la Service Account
```bash
gcloud iam service-accounts create "$SA_NAME" \
    --description="Service Account dedicada para Payload CMS en Cloud Run" \
    --display-name="Payload CMS Service Account" \
    --project="$PROJECT_ID"
```

### 2.2: Configurar Usuario en Firestore (SCRAM)
Para autenticarte contra Firestore MongoDB API usando SCRAM-SHA-256, debes crear un usuario y contraseña en GCP Console (*Firestore > MongoDB Compatibility > Database Users*). No requieres rol de IAM específico de Datastore en la Service Account si usas SCRAM.

### 2.3: Asignar Rol 2 - Storage Object Admin (Gestión de Archivos en GCS)
Este rol otorga permisos para subir, consultar y eliminar imágenes y archivos multimedia dentro del bucket `liv-clases-gcp`:

```bash
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:$SA_EMAIL" \
  --role="roles/storage.objectAdmin"
```

### 2.4: Verificar la Service Account creada y sus roles
```bash
gcloud projects get-iam-policy "$PROJECT_ID" \
  --flatten="bindings[].members" \
  --format="table(bindings.role)" \
  --filter="bindings.members:$SA_EMAIL"
```

---

## 🐳 Paso 3: Compilar y Subir la Imagen a Artifact Registry

Desde la carpeta del proyecto en Cloud Shell:

```bash
cd 04-firebase-mongo/payload-app

# Compilar e integrar en Artifact Registry existente
gcloud builds submit --tag "$IMAGE_TAG" .
```

---

## ☁️ Paso 4: Desplegar en Google Cloud Run usando la Service Account

Despliega el servicio asociando la Service Account creada (`--service-account="$SA_EMAIL"`):

```bash
gcloud run deploy payload-cms \
  --image="$IMAGE_TAG" \
  --platform=managed \
  --region="$REGION" \
  --service-account="$SA_EMAIL" \
  --allow-unauthenticated \
  --port=3000 \
  --set-env-vars="DATABASE_URI=mongodb://<username>:<password>@bb1bb5f3-0f1c-48b6-9091-c9b3c15fc23c.nam5.firestore.goog:443/demo-cms-payload?loadBalanced=true&tls=true&authMechanism=SCRAM-SHA-256&retryWrites=false,PAYLOAD_SECRET=super-secret-key-payload-gcp-2026,GCS_BUCKET=$BUCKET_NAME,GCS_PREFIX=payload-media,GCS_REGION=$REGION"
```

---

## 🔍 Verificación Final

1. **Service URL**: Haz clic en la URL generada por Cloud Run (ej: `https://payload-cms-xxxx-nn.a.run.app/admin`).
2. **Registro Admin**: Crea el usuario administrador inicial en Payload CMS.
3. **Persistencia GCS**: Sube una imagen; esta se almacenará dentro de la subcarpeta `gs://liv-clases-gcp/payload-media/` en lugar de la raíz.
4. **Verificación Mongo**: Conéctate mediante `mongosh` para inspeccionar las colecciones generadas en Firestore.
