# Guía Rápida de Comandos 🚀

Esta es una guía de referencia rápida para configurar tu Git, compilar y ejecutar tus contenedores localmente paso a paso.

---

## Paso 1: Configurar tu Firma de Git
Antes de guardar tus avances, dile a Git quién eres. Ejecuta esto en tu terminal:
```bash
git config --local user.name "Tu Nombre Completo"
git config --local user.email "tu-correo@estudiante.edu"
```

---

## Paso 2: Construir las Imágenes una por una
Compila localmente cada contenedor para empaquetar tu código:

```bash
# 1. Servidor web Nginx básico
docker build -t nginx-basic ./01-nginx-basic

# 2. Frontend React (Compilación optimizada multietapa)
docker build -t frontend-react ./02-frontend-multi-stage

# 3. Backend FastAPI con Python
docker build -t backend-fastapi ./03-backend-fastapi
```

---

## Paso 3: Correr los Contenedores en tu máquina
Inicia los contenedores localmente para probar que todo funciona bien:

```bash
# 1. Correr Nginx (compruébalo abriendo el puerto 8080)
docker run -d -p 8080:80 --name contenedor-nginx nginx-basic

# 2. Correr el Frontend React (compruébalo abriendo el puerto 8081)
docker run -d -p 8081:80 --name contenedor-react frontend-react

# 3. Correr el Backend FastAPI (compruébalo abriendo el puerto 8000)
docker run -d -p 8000:8000 --name contenedor-api backend-fastapi
```

---

## 🛠️ Comandos de Apoyo Útiles

*   **Ver contenedores encendidos**:
    ```bash
    docker ps
    ```
*   **Detener un contenedor**:
    ```bash
    docker stop <nombre_o_id_del_contenedor>
    ```
    *(Ejemplo: `docker stop contenedor-nginx`)*
*   **Ver qué está pasando dentro del backend (logs)**:
    ```bash
    docker logs contenedor-api
    ```
