# 🚀 Temperatura CRUD - Quick Start Guide

## Prerrequisitos

- Docker y Docker Compose instalados
- Git configurado
- Cuenta en Docker Hub (para CI/CD)

## 🛠️ Configuración Inicial

### 1. Clonar y configurar el proyecto

```bash
git clone <tu-repositorio>
cd temperatura-crud-actions
```

### 2. Configurar variables de entorno

```bash
# Copiar archivo de ejemplo
cp .env.example .env

# Editar las variables según tu configuración
# Especialmente DOCKER_USERNAME y DOCKER_PASSWORD
```

### 3. Configurar secrets en GitHub

Ve a tu repositorio en GitHub → Settings → Secrets and variables → Actions

Crear los siguientes **Repository secrets**:

- `DOCKER_USERNAME`: Tu usuario de Docker Hub
- `DOCKER_PASSWORD`: Tu token/password de Docker Hub

## 🏃‍♂️ Inicio Rápido

### Opción 1: Scripts automatizados (Recomendado)

**Windows (PowerShell):**
```powershell
.\scripts.ps1 start
```

**Linux/macOS:**
```bash
chmod +x scripts.sh
./scripts.sh start
```

### Opción 2: Docker Compose manual

```bash
# Iniciar todos los servicios
docker-compose -f docker-compose.dev.yml up -d

# Ver logs
docker-compose -f docker-compose.dev.yml logs -f

# Detener servicios
docker-compose -f docker-compose.dev.yml down
```

## 📱 URLs de la Aplicación

Una vez iniciados los servicios:

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8081
- **Health Check**: http://localhost:8081/actuator/health

## 🧪 Ejecutar Tests

```bash
# Con scripts
./scripts.sh test        # Linux/macOS
.\scripts.ps1 test       # Windows

# Manual
docker-compose -f docker-compose.test.yml up --abort-on-container-exit
```

## 🔧 Comandos Útiles

### Scripts disponibles:

```bash
# Iniciar servicios
./scripts.sh start

# Detener servicios
./scripts.sh stop

# Reiniciar servicios
./scripts.sh restart

# Construir imágenes
./scripts.sh build

# Ver logs
./scripts.sh logs
./scripts.sh logs-be    # Solo backend
./scripts.sh logs-fe    # Solo frontend
./scripts.sh logs-db    # Solo database

# Ejecutar tests
./scripts.sh test

# Limpiar todo
./scripts.sh clean

# Ver estado
./scripts.sh status

# Verificar health
./scripts.sh health

# Ver ayuda
./scripts.sh help
```

## 🚀 CI/CD con GitHub Actions

### Flujo automático:

1. **Push a `develop`**: Ejecuta hasta staging
2. **Push a `main`**: Ejecuta todo el pipeline incluyendo producción
3. **Pull Request**: Ejecuta build y tests
4. **Schedule**: Cada 2 horas (opcional)

### Environments configurados:

- **Testing**: Puerto 8082 (backend), 3001 (frontend)
- **Staging**: Puerto 8081 (backend), 3000 (frontend)  
- **Production**: Puerto 8083 (backend), 3002 (frontend)

### Ver pipeline:

Ve a tu repositorio en GitHub → Actions para ver el estado del pipeline.

## 🛠️ Desarrollo

### Estructura del proyecto:

```
temperatura-crud-actions/
├── .github/workflows/          # Pipeline CI/CD
├── backend/                    # API Spring Boot
│   ├── src/main/java/         # Código fuente
│   ├── Dockerfile             # Container backend
│   └── pom.xml               # Dependencias Maven
├── frontend/                   # App Next.js
│   ├── pages/                 # Páginas React
│   ├── styles/               # CSS
│   ├── Dockerfile            # Container frontend
│   └── package.json          # Dependencias npm
├── docker-compose.dev.yml      # Desarrollo local
├── docker-compose.test.yml     # Tests integración
└── scripts.{sh,ps1}           # Scripts desarrollo
```

### Desarrollo del backend:

```bash
cd backend
./mvnw spring-boot:run
```

### Desarrollo del frontend:

```bash
cd frontend
npm install
npm run dev
```

## 🐛 Solución de Problemas

### Base de datos no conecta:

```bash
# Verificar que SQL Server esté corriendo
docker ps | grep mssql

# Reiniciar base de datos
docker-compose -f docker-compose.dev.yml restart temperatura-db
```

### Puerto ocupado:

```bash
# Ver procesos usando puertos
netstat -tulpn | grep :3000  # Linux
netstat -ano | findstr :3000  # Windows

# Cambiar puertos en docker-compose.dev.yml si es necesario
```

### Limpiar todo y empezar de nuevo:

```bash
./scripts.sh clean
./scripts.sh start
```

### Pipeline falla en GitHub Actions:

1. Verificar que los secrets estén configurados
2. Verificar que Docker Hub sea accesible
3. Revisar logs en GitHub Actions
4. Verificar sintaxis de .github/workflows/ci-cd.yml

## 📝 Logs útiles:

```bash
# Ver logs de todos los servicios
./scripts.sh logs

# Ver logs específicos
docker logs temperatura-backend
docker logs temperatura-frontend
docker logs temperatura-db

# Ver logs del pipeline
# Ve a GitHub → Actions → [tu workflow]
```

## 🎯 Próximos Pasos

1. Personalizar la aplicación según tus necesidades
2. Añadir más tests
3. Configurar notificaciones (Slack, Teams)
4. Añadir métricas y monitoring
5. Configurar despliegue a cloud (AWS, Azure, GCP)

## 🆘 Soporte

Si tienes problemas:

1. Revisar logs con `./scripts.sh logs`
2. Verificar estado con `./scripts.sh status`
3. Limpiar y reiniciar con `./scripts.sh clean && ./scripts.sh start`
4. Verificar documentación en `README.md` y `CONTAINERS.md`

---

**¡Disfruta desarrollando con GitHub Actions! 🚀**
