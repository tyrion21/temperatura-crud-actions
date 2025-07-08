# Temperatura CRUD - GitHub Actions CI/CD

Este repositorio contiene el pipeline de CI/CD para la aplicación Temperatura CRUD usando GitHub Actions, equivalente al pipeline de Jenkins.

## 🚀 Características del Pipeline

### Flujo de CI/CD Completo
- **Build Backend**: Compilación y testing del backend Spring Boot con Java 17
- **Build Frontend**: Compilación y linting del frontend Next.js con TypeScript
- **Security Scan**: Análisis de vulnerabilidades en dependencias
- **Docker Build**: Construcción y push de imágenes Docker
- **Integration Tests**: Tests de integración completos
- **Deploy Staging**: Despliegue automático en staging
- **Deploy Production**: Despliegue automático en producción

### Triggers
- **Push**: En ramas `main` y `develop`
- **Pull Request**: En rama `main`
- **Schedule**: Cada 2 horas (alternativa al polling de Jenkins)

## 🛠️ Configuración Necesaria

### Secrets de GitHub
Configura los siguientes secrets en tu repositorio:

```
DOCKER_USERNAME: tu_usuario_docker_hub
DOCKER_PASSWORD: tu_token_docker_hub
```

### Environments
El pipeline utiliza dos environments:
- `staging`: Para despliegue en staging
- `production`: Para despliegue en producción

## 📦 Estructura del Proyecto

```
temperatura-crud-actions/
├── .github/
│   └── workflows/
│       └── ci-cd.yml          # Pipeline principal
├── backend/
│   ├── src/
│   ├── pom.xml
│   └── Dockerfile
├── frontend/
│   ├── pages/
│   ├── package.json
│   └── Dockerfile
└── docker-compose.test.yml     # Para tests de integración
```

## 🔄 Flujo de Trabajo

### 1. Build y Test
- Compilación del backend Java con Maven
- Compilación del frontend TypeScript con npm
- Ejecución de tests unitarios
- Cache de dependencias para optimización

### 2. Security Scan
- OWASP dependency check para backend
- npm audit para frontend
- Scan en paralelo por componente

### 3. Docker Build
- Construcción de imágenes Docker optimizadas
- Push a Docker Hub con tags por build number
- Cache de layers Docker para builds rápidos

### 4. Integration Tests
- Despliegue con docker-compose
- Health checks automáticos
- Cleanup automático post-test

### 5. Deploy Staging
- Despliegue automático en ramas `develop` y `main`
- SQL Server en contenedor
- Health checks de servicios
- Puertos: Backend 8081, Frontend 3000

### 6. Deploy Production
- Despliegue automático solo en rama `main`
- Configuración optimizada para producción
- Health checks completos
- Puertos: Backend 8083, Frontend 3002

## 🎯 Mejoras vs Jenkins

### Ventajas de GitHub Actions
- ✅ **Nativo**: Integración perfecta con GitHub
- ✅ **Escalable**: Runners gestionados automáticamente
- ✅ **Cache**: Cache automático de dependencias
- ✅ **Paralelo**: Jobs en paralelo por defecto
- ✅ **Environments**: Protección de deployments
- ✅ **Artifacts**: Gestión automática de artefactos
- ✅ **Monitoring**: Logs y métricas integradas

### Optimizaciones Implementadas
- **Matrix Strategy**: Builds paralelos por componente
- **Dependency Caching**: Cache de Maven y npm
- **Docker Layer Caching**: Cache de layers Docker
- **Conditional Execution**: Jobs condicionados por rama
- **Health Checks**: Verificación automática de servicios

## 🔧 Configuración Avanzada

### Variables de Entorno
```yaml
env:
  DOCKER_BACKEND_IMAGE: jasonhermida/temperatura-backend
  DOCKER_FRONTEND_IMAGE: jasonhermida/temperatura-frontend
  JAVA_VERSION: '17'
  NODE_VERSION: '18'
```

### Servicios para Tests
```yaml
services:
  mssql:
    image: mcr.microsoft.com/mssql/server:2022-latest
    env:
      ACCEPT_EULA: Y
      SA_PASSWORD: j1s0n2108*
```

## 📊 Monitoreo y Reportes

- **Test Results**: Reportes JUnit automáticos
- **Artifacts**: Preservación de JARs y builds
- **Logs**: Logging estructurado por job
- **Status Checks**: Integración con PRs

## 🚦 Estados de Deployment

- **Staging**: Automático en push a `develop`/`main`
- **Production**: Automático en push a `main`
- **Rollback**: Manual via GitHub UI

## 🎨 Próximas Mejoras

- [ ] Slack/Teams notifications
- [ ] Deployment approvals
- [ ] Performance testing
- [ ] Code coverage reports
- [ ] Automated rollback
- [ ] Multi-environment support

## 🔗 Enlaces Útiles

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Hub Repository](https://hub.docker.com/u/jasonhermida)
- [Spring Boot Actuator](https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html)
- [Next.js Documentation](https://nextjs.org/docs)

---
*Pipeline migrado desde Jenkins a GitHub Actions para mayor integración y escalabilidad.*
