# 🗺️ Roadmap de Desarrollo: Plataforma de Cursos `igncursos`

Este documento contiene la hoja de ruta estratégica para transformar la plantilla base de **Payload CMS 3.x + Next.js App Router** en una plataforma completa y funcional para la gestión, navegación y reproducción de cursos en línea.

---

## 📌 Fase 1: Arquitectura de Datos en Payload CMS (`src/collections/`)

Definición del modelo relacional para el contenido educativo:

### 1. Colección `Categories` (`src/collections/Categories.ts`)
* **Propósito**: Clasificar los cursos por áreas temáticas (ej: *Desarrollo Web*, *Cloud Computing*, *DevOps*).
* **Campos**:
  * `title` (Text, Requerido)
  * `slug` (Text, Único, Indexado)

### 2. Colección `Courses` (`src/collections/Courses.ts`)
* **Propósito**: Almacenar la información general del curso.
* **Campos**:
  * `title` (Text, Requerido)
  * `slug` (Text, Único, Indexado)
  * `description` (RichText / Lexical)
  * `coverImage` (Upload `Media` -> GCS)
  * `category` (Relationship -> `Categories`)
  * `level` (Select: *Principiante*, *Intermedio*, *Avanzado*)
  * `publishedAt` (Date)

### 3. Colección `Lessons` (`src/collections/Lessons.ts`)
* **Propósito**: Lecciones o clases individuales pertenecientes a un curso.
* **Campos**:
  * `title` (Text, Requerido)
  * `slug` (Text, Requerido)
  * `course` (Relationship -> `Courses`)
  * `order` (Number, para ordenamiento de clases)
  * `videoFile` (Upload `Media` -> GCS para videos de clases)
  * `videoUrl` (Text opcional para contenido externo como YouTube/Vimeo)
  * `content` (RichText / Lexical con notas de la clase y código)

---

## 🖥️ Fase 2: Frontend en Next.js App Router (`src/app/(frontend)/`)

Desarrollo de las páginas públicas y de reproducción utilizando *Server Components* y la *Local API de Payload*:

### 1. Catálogo de Cursos (`/`)
* Banner principal interactivo.
* Lista de categorías con filtrado dinámico.
* Grid de tarjetas (*cards*) de cursos con imagen de portada (servida desde GCS), título, categoría y nivel.

### 2. Detalle del Curso (`/courses/[slug]`)
* Cabecera con portada y resumen del curso.
* Lista estructurada de lecciones ordenadas (`order`).
* Botón para iniciar el aprendizaje / abrir la primera lección.

### 3. Reproductor de Lección (`/courses/[slug]/lessons/[lessonSlug]`)
* Reproductor de video HTML5 integrado con los archivos almacenados en GCS (`gs://igncursos-media/webcourses/`).
* Barra lateral de navegación entre lecciones (Anterior / Siguiente).
* Renderizado del contenido explicativo en texto enriquecido.

---

## ⚡ Fase 3: Optimización de Modelado y Consulta en MongoDB

### 1. Modelado Específico para MongoDB
* **Estrategia Documental de Embebido**: Para vistas de lectura ultra rápidas, las lecciones pueden incrustarse como un arreglo de subdocumentos en `Courses`. Con **1 sola lectura BSON** a MongoDB se recupera el curso completo con su temario sin realizar búsquedas relacionales (`$lookup`).
* **Indexación B-Tree (`index: true`)**: Agregar `index: true` y `unique: true` en los campos `slug` de `Courses`, `Lessons` y `Categories` para búsquedas en tiempo $O(1)$.

### 2. Consultas Eficientes con Payload Local API
* **Control de Profundidad (`depth`)**: Ajustar `depth: 1` o `depth: 0` para evitar que MongoDB traiga relaciones anidadas innecesarias al listar el catálogo.
* **Proyección de Campos (`select`)**: Recuperar únicamente los campos requeridos por la vista:
  ```typescript
  import { getPayload } from 'payload'
  import config from '@payload-config'

  const payload = await getPayload({ config })
  const courses = await payload.find({
    collection: 'courses',
    depth: 1,
    select: {
      title: true,
      slug: true,
      coverImage: true,
    },
  })
  ```
* **Caché en Next.js**: Combinar la Local API con `unstable_cache` o `revalidate` para servir el catálogo en milisegundos desde memoria.

---

## 🎨 Fase 4: Diseño y Experiencia de Usuario (UI/UX)

* Diseño moderno en Modo Oscuro con colores elegantes.
* Tipografía limpia desde Google Fonts (ej: *Inter* u *Outfit*).
* Transiciones y animaciones fluidas para tarjetas y reproductores de video.
* Reproducción HTML5 estándar (`<video>`) y librerías maduras de Next.js.

---

## ⚡ Fase 5: Escalado y Caché Persistente en Cloud Run (Tráfico Medio/Alto)

*(Nota: Para tráfico bajo a medio, la caché local de Next.js dentro del contenedor activo funciona 100% bien y sin configuraciones extra).*

### 1. Opción 1: Google Cloud CDN / Firebase Hosting en el Borde
* **Propósito**: Servir las páginas compiladas del catálogo desde la red de borde global de Google (<20 ms).
* **Mecanismo**: Next.js envía cabeceras `Cache-Control: s-maxage=3600, stale-while-revalidate`. Cloud CDN guarda el HTML en el borde y responde a los estudiantes sin despertar instancias adicionales de Cloud Run (costo cercano a $0).

### 2. Opción 2: Redis Compartido (`cacheHandler` de Next.js)
* **Propósito**: Compartir la caché de datos entre múltiples contenedores de Cloud Run o hacerla persistir tras un escalado a cero.
* **Mecanismo**: Configurar `cacheHandler` en `next.config.ts` conectado a un servidor Redis (Upstash o Google Cloud Memorystore).

---

## 🚀 Fase 6 (Avanzado): Integración de WebAssembly (WASM) & Rust

*(Esta fase es opcional y avanzada. Se ejecuta únicamente cuando la aplicación requiera procesamiento o encriptación pesada de video).*

### 1. Procesamiento de Video con `FFmpeg.wasm` (C/Rust a WASM)
* **Propósito**: Procesar, recortar o generar miniaturas (*thumbnails*) de videos subidos directamente desde el servidor Node.js o navegador cliente sin depender de binarios instalados en el sistema operativo.

### 2. Desencriptación y Protección de Video (Rust + WASM)
* **Propósito**: Proteger los videos contra descargas no autorizadas mediante streaming **HLS (`.m3u8`)** encriptado en AES-128.
* **Implementación**: Un módulo compilado en **Rust (`wasm-bindgen`)** que ejecuta la desencriptación de fragmentos de video en memoria antes de alimentarlos al reproductor en el navegador.

### 3. Reproductores de Streaming Adaptativo
* **HLS.js / Shaka Player**: Integración con librerías de streaming que ajustan automáticamente la calidad de reproducción del video según el ancho de banda del usuario.
