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

## ⚡ Fase 3: Optimización y Consulta de Datos

* **Payload Local API**: Consultar datos directamente desde Node.js en los Server Components sin sobrecarga HTTP:
  ```typescript
  import { getPayload } from 'payload'
  import config from '@payload-config'

  const payload = await getPayload({ config })
  const courses = await payload.find({ collection: 'courses' })
  ```
* **Imágenes y CDN**: Aprovechar la optimización de imágenes nativa de Next.js (`<Image>`) configurando las rutas de media de Payload.

---

## 🎨 Fase 4: Diseño y Experiencia de Usuario (UI/UX)

* Diseño moderno en Modo Oscuro con colores elegantes.
* Tipografía limpia desde Google Fonts (ej: *Inter* u *Outfit*).
* Transiciones y animaciones fluidas para tarjetas y reproductores de video.
