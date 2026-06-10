# NutriCare Pro

NutriCare Pro es una aplicacion clinica para nutriologos. Incluye una API REST para almacenar
pacientes, planes alimenticios, citas y mediciones de progreso, junto con una app iOS SwiftUI
que consume la API mediante `URLSession`.

## Estructura

```text
NutriCarePro/
├── backend-java/            # API Spring Boot y configuracion de contenedor
├── app-swift/               # App SwiftUI MVVM y proyecto Xcode
├── docker-compose.yml       # MySQL + API para ejecucion local o servidor
└── README.md
```

## Tecnologias

- Backend: Java 17, Spring Boot 3.4.5, Spring Web, Spring Data JPA y Bean Validation.
- Base de datos: MySQL 8.4.
- App: Swift, SwiftUI, MVVM, `NavigationStack`, `TabView` y `URLSession`.
- Despliegue: Docker y Docker Compose; el backend acepta configuracion por variables de entorno.

## Funcionalidades

- Login simple para el nutriologo.
- CRUD de pacientes.
- CRUD de planes alimenticios asignados a pacientes.
- CRUD de citas asignadas a pacientes.
- CRUD de registros de progreso.
- Validacion de datos y mensajes de error de conexion en la app.
- Interfaz clara con tarjetas, fondo claro y paleta verde/azul.

## Requisitos

- Docker Desktop, opcion recomendada para levantar API y MySQL juntos.
- Alternativa local: Java 17, Maven 3.9 o superior y MySQL 8.
- Xcode 16 o superior para ejecutar la app iOS (el proyecto esta configurado para iOS 17+).

## Ejecutar backend con Docker

Desde esta carpeta:

```bash
cp .env.example .env
# Cambiar APP_ADMIN_PASSWORD y las contrasenas de MySQL en .env
docker compose up --build
```

La API queda disponible en `http://localhost:8080/api`. MySQL expone el puerto `3306`.
Al arrancar por primera vez se crea el usuario definido por `APP_ADMIN_EMAIL` y
`APP_ADMIN_PASSWORD`.

## Ejecutar backend localmente

Crear la base de datos o permitir que el parametro `createDatabaseIfNotExist` la genere. Configurar:

```bash
export DB_URL='jdbc:mysql://localhost:3306/nutricare_pro?createDatabaseIfNotExist=true&serverTimezone=UTC'
export DB_USERNAME='root'
export DB_PASSWORD='tu_password'
export APP_ADMIN_EMAIL='admin@nutricarepro.com'
export APP_ADMIN_PASSWORD='una_password_segura'
cd backend-java
mvn spring-boot:run
```

Las propiedades se encuentran en `backend-java/src/main/resources/application.properties`:

```properties
spring.datasource.url=${DB_URL:jdbc:mysql://localhost:3306/nutricare_pro?createDatabaseIfNotExist=true&serverTimezone=UTC}
spring.datasource.username=${DB_USERNAME:root}
spring.datasource.password=${DB_PASSWORD:root}
spring.jpa.hibernate.ddl-auto=${JPA_DDL_AUTO:update}
```

## Ejecutar app Swift

1. Abrir `app-swift/NutriCareProApp.xcodeproj` en Xcode.
2. Verificar `API_BASE_URL` en `app-swift/Info.plist`. Para simulador local el valor incluido es
   `http://localhost:8080/api/`.
3. Seleccionar un simulador iPhone y ejecutar el esquema `NutriCarePro`.
4. Iniciar sesion con las credenciales definidas para el backend.

Para un dispositivo fisico, cambiar `API_BASE_URL` por la IP accesible del equipo que ejecuta la
API o por el dominio HTTPS desplegado.

## API REST

Todos los recursos producen y reciben JSON.

| Metodo | Endpoint | Descripcion |
| --- | --- | --- |
| POST | `/api/auth/login` | Autentica correo y contrasena |
| GET, POST | `/api/usuarios` | Lista o crea nutriologos |
| GET, PUT, DELETE | `/api/usuarios/{id}` | Consulta, actualiza o elimina nutriologo |
| GET, POST | `/api/pacientes` | Lista o registra pacientes |
| GET, PUT, DELETE | `/api/pacientes/{id}` | Consulta, actualiza o elimina paciente |
| GET, POST | `/api/planes` | Lista o crea planes alimenticios |
| GET, PUT, DELETE | `/api/planes/{id}` | Consulta, actualiza o elimina plan |
| GET, POST | `/api/citas` | Lista o agenda citas |
| GET, PUT, DELETE | `/api/citas/{id}` | Consulta, actualiza o elimina cita |
| GET, POST | `/api/progresos` | Lista o registra mediciones |
| GET, PUT, DELETE | `/api/progresos/{id}` | Consulta, actualiza o elimina progreso |

Ejemplo de login:

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@nutricarepro.com","password":"admin123"}'
```

Ejemplo de paciente:

```json
{
  "nombre": "Ana",
  "apellido": "Lopez",
  "email": "ana@example.com",
  "telefono": "5551234567",
  "fechaNacimiento": "1990-06-10",
  "genero": "Femenino",
  "objetivo": "Control de peso",
  "notas": "Primera consulta"
}
```

## Modelo de base de datos

| Tabla | Campos principales |
| --- | --- |
| `usuarios` | `id`, `nombre`, `email` unico, `password`, `especialidad` |
| `pacientes` | `id`, `nombre`, `apellido`, `email`, `telefono`, `fechaNacimiento`, `objetivo`, `nutriologoId` |
| `planes_alimenticios` | `id`, `pacienteId`, `nombre`, `descripcion`, `caloriasObjetivo`, fechas, `activo` |
| `citas` | `id`, `pacienteId`, `fechaHora`, `motivo`, `estado`, `notas` |
| `progresos` | `id`, `pacienteId`, `fecha`, `peso`, `altura`, `porcentajeGrasa`, `cintura` |

El servicio valida que un plan, una cita o un progreso referencie un paciente existente. No permite
eliminar pacientes con registros clinicos asociados.

## Evidencias pendientes

Agregar capturas al entregar o demostrar el sistema:

- Pantalla de login.
- Listado y formulario de pacientes.
- Listado de planes alimenticios.
- Agenda de citas.
- Registro de progreso.
- Peticiones exitosas en la API o tablas MySQL.

## Despliegue en la nube

El backend esta preparado como imagen Docker. En Railway, Render, Fly.io, Azure Container Apps o
AWS se puede desplegar `backend-java/Dockerfile` y conectar una instancia MySQL administrada:

1. Crear una base MySQL administrada y habilitar acceso desde el servicio backend.
2. Construir/desplegar la imagen desde `backend-java/Dockerfile`.
3. Configurar `DB_URL`, `DB_USERNAME`, `DB_PASSWORD`, `JPA_DDL_AUTO=update`,
   `APP_ADMIN_EMAIL`, `APP_ADMIN_PASSWORD` y `CORS_ALLOWED_ORIGINS`.
4. Publicar la API mediante HTTPS y colocar su URL terminada en `/api/` en `API_BASE_URL`
   antes de compilar la app iOS.

Para un servidor propio, `docker compose up --build -d` ejecuta ambos contenedores; cambiar
secretos y colocar un proxy HTTPS como Nginx o Caddy delante del backend.

## Seguridad

El login solicitado es deliberadamente simple y almacena la contrasena sin cifrado para fines
academicos. Antes de uso real se debe implementar Spring Security, hash BCrypt, autenticacion JWT,
HTTPS obligatorio y gestion de secretos fuera del repositorio.
