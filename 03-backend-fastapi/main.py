from fastapi import FastAPI

app = FastAPI(
    title="GCP Class API",
    description="API mínima con FastAPI para demostración de Docker y Artifact Registry",
    version="1.0.0"
)

@app.get("/")
def read_root():
    return {
        "mensaje": "¡Hola desde FastAPI corriendo en GCP!",
        "estado": "online",
        "detalle": "Esta es la aplicación de backend dockerizada para la clase de GCP."
    }

@app.get("/health")
def health_check():
    return {"status": "healthy"}
