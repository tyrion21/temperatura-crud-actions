# Gestión de Contenedores en GitHub Actions

## 🚨 Problema de Nombres de Contenedores

En GitHub Actions, **los contenedores NO pueden tener el mismo nombre** cuando se ejecutan en paralelo o simultáneamente. Esto se debe a que:

1. **Runners compartidos**: Los runners de GitHub Actions pueden compartir el mismo host Docker
2. **Ejecuciones paralelas**: Múltiples workflows pueden ejecutarse al mismo tiempo
3. **Conflictos de nombres**: Docker no permite contenedores con nombres idénticos en el mismo host

## ✅ Solución Implementada

### Nombres Únicos con GitHub Run ID

Utilizamos `github.run_id` para generar nombres únicos de contenedores:

```yaml
# Ejemplo de naming único
DB_NAME="temperatura-staging-db-${{ github.run_id }}"
BACKEND_NAME="temperatura-staging-backend-${{ github.run_id }}"
FRONTEND_NAME="temperatura-staging-frontend-${{ github.run_id }}"
NETWORK_NAME="temperatura-staging-network-${{ github.run_id }}"
```

### Estrategias por Entorno

#### 🧪 **Tests de Integración**
```yaml
# Usa COMPOSE_PROJECT_NAME para crear namespaces únicos
TEST_COMPOSE_PROJECT="temperatura-test-${{ github.run_id }}"
docker-compose -p $TEST_COMPOSE_PROJECT -f docker-compose.test.yml up -d
```

#### 🔄 **Staging**
```yaml
# Contenedores con sufijo de run_id
temperatura-staging-db-123456789
temperatura-staging-backend-123456789
temperatura-staging-frontend-123456789
```

#### 🚀 **Production**
```yaml
# Contenedores con sufijo de run_id
temperatura-production-db-123456789
temperatura-production-backend-123456789
temperatura-production-frontend-123456789
```

## 🔧 Configuración Técnica

### Variables de GitHub Actions Utilizadas

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `github.run_id` | ID único de ejecución | `123456789` |
| `github.run_number` | Número de build | `42` |
| `github.sha` | Hash del commit | `abc123...` |
| `github.ref_name` | Nombre de la rama | `main` |

### Docker Compose con Project Names

```yaml
# docker-compose.test.yml
version: '3.8'

services:
  temperatura-backend:
    container_name: temperatura-backend-${COMPOSE_PROJECT_NAME:-test}
    # ... resto de configuración

networks:
  default:
    name: temperatura-test-network-${COMPOSE_PROJECT_NAME:-test}
```

## 🛠️ Manejo de Cleanup

### Cleanup Automático por Run ID

```bash
# Limpieza específica por run_id
docker stop temperatura-staging-db-${{ github.run_id }} || true
docker rm temperatura-staging-db-${{ github.run_id }} || true
docker network rm temperatura-staging-network-${{ github.run_id }} || true
```

### Cleanup de Contenedores Antiguos

```bash
# Limpieza de contenedores antiguos (más de 24 horas)
docker container prune -f --filter "until=24h" || true
docker network prune -f --filter "until=24h" || true
docker image prune -f --filter "until=24h" || true
```

## 📋 Ventajas del Enfoque

### ✅ **Beneficios**
- **Aislamiento**: Cada ejecución tiene sus propios contenedores
- **Paralelización**: Múltiples pipelines pueden ejecutarse simultáneamente
- **Trazabilidad**: Fácil identificación de contenedores por run_id
- **Cleanup automático**: Limpieza automática de recursos

### ✅ **Prevención de Conflictos**
- **Nombres únicos**: Evita conflictos de nombres entre ejecuciones
- **Redes separadas**: Cada ejecución tiene su propia red Docker
- **Puertos dinámicos**: Asignación de puertos sin conflictos
- **Cleanup programado**: Limpieza automática de recursos antiguos

## 🎯 Ejemplos de Uso

### Desarrollo Local
```bash
# Usar scripts locales que NO usan run_id
./scripts.sh start
```

### CI/CD Pipeline
```yaml
# GitHub Actions usa run_id automáticamente
- name: Deploy to Staging
  run: |
    DB_NAME="temperatura-staging-db-${{ github.run_id }}"
    docker run -d --name $DB_NAME ...
```

### Testing Manual
```bash
# Usar compose project name personalizado
COMPOSE_PROJECT_NAME="my-test-123" docker-compose -f docker-compose.test.yml up -d
```

## 🔍 Monitoreo y Debugging

### Identificar Contenedores Activos
```bash
# Ver contenedores por patrón
docker ps --filter "name=temperatura-*"

# Ver redes por patrón
docker network ls --filter "name=temperatura-*"
```

### Logs por Run ID
```bash
# Ver logs de una ejecución específica
docker logs temperatura-backend-123456789
```

## 🚀 Próximas Mejoras

### Posibles Optimizaciones
- [ ] **Resource Limits**: Limitar recursos por contenedor
- [ ] **Health Checks**: Mejorar health checks con timeouts
- [ ] **Monitoring**: Añadir métricas de contenedores
- [ ] **Auto-scaling**: Escalado automático según carga

### Consideraciones Futuras
- [ ] **Kubernetes**: Migración a K8s para mejor orquestación
- [ ] **Multi-region**: Despliegue en múltiples regiones
- [ ] **Blue-Green**: Implementar despliegue blue-green
- [ ] **Canary**: Despliegue progresivo canary

---

**Nota Importante**: Esta estrategia garantiza que múltiples ejecuciones del pipeline puedan ejecutarse simultáneamente sin conflictos de nombres de contenedores, mejorando significativamente la confiabilidad y escalabilidad del CI/CD.
