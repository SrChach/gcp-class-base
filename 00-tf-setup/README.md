# Configuración de Accesos del Proyecto con Terraform 🛠️

¡Hola, Ingeniero/a GCP! En esta sección del laboratorio utilizarás **Terraform** para automatizar el alta de los miembros de tu equipo en tu proyecto de GCP.

Aprenderás a aplicar infraestructura como código garantizando que los accesos se **agreguen** sin sobreescribir ni borrar los permisos existentes.

---

## 📋 Temario / Pasos a seguir

1.  **Configurar tus variables (`terraform.tfvars`)**: Definir en qué proyecto de GCP se darán de alta los accesos.
2.  **Inicializar Terraform (`terraform init`)**: Descargar los plugins y el proveedor de Google.
3.  **Planificar (`terraform plan`)**: Ver la previsualización de qué cambios se realizarán.
4.  **Aplicar (`terraform apply`)**: Confirmar y crear los accesos en la nube.

---

## Paso 1: Configurar tu Proyecto

Crea tu archivo de valores a partir de la plantilla:
```bash
cp terraform.tfvars.example terraform.tfvars
```
Abre el archivo `terraform.tfvars` recién creado y reemplaza `"tu-proyecto-id-gcp"` por el ID real de tu proyecto de GCP.

---

## Paso 2: Inicializar Terraform

Descarga los conectores y plugins oficiales de Google Cloud necesarios para ejecutar el código:
```bash
terraform init
```

---

## Paso 3: Previsualizar los Cambios

Antes de aplicar cualquier cambio en la nube, es una excelente práctica revisar qué es lo que Terraform planea hacer. Ejecuta:
```bash
terraform plan
```
*Verás en la terminal que se planea crear exactamente 10 recursos (uno por cada miembro de la lista).*

---

## Paso 4: Aplicar y Crear los Accesos

Aplica los cambios en tu proyecto de GCP. Cuando te solicite confirmación, escribe `yes` y presiona Enter:
```bash
terraform apply
```

¡Listo! Si vas a la sección de **IAM & Admin** en la consola de Google Cloud, verás a todos tus compañeros añadidos de forma segura con el rol asignado. 🎉
