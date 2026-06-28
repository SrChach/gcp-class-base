# Usamos una imagen de Python oficial liviana (slim)
FROM python:3.11-slim

# Definimos el directorio de trabajo
WORKDIR /app

# Copiamos e instalamos las dependencias primero para aprovechar el caché de Docker
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiamos el código de la aplicación
COPY . .

# Exponemos el puerto de la aplicación (FastAPI por defecto corre en el 8000)
EXPOSE 8000

# Comando para ejecutar FastAPI usando uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
