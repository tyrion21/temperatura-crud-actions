#!/bin/bash

# Scripts para desarrollo local de Temperatura CRUD

echo "🚀 Temperatura CRUD - Development Scripts"
echo "========================================="

# Función para mostrar ayuda
show_help() {
    echo "Uso: ./scripts.sh [comando]"
    echo ""
    echo "Comandos disponibles:"
    echo "  start       - Iniciar todos los servicios"
    echo "  stop        - Detener todos los servicios"
    echo "  restart     - Reiniciar todos los servicios"
    echo "  build       - Construir imágenes Docker"
    echo "  logs        - Mostrar logs de todos los servicios"
    echo "  logs-be     - Mostrar logs del backend"
    echo "  logs-fe     - Mostrar logs del frontend"
    echo "  logs-db     - Mostrar logs de la base de datos"
    echo "  test        - Ejecutar tests de integración"
    echo "  clean       - Limpiar contenedores y volúmenes"
    echo "  status      - Mostrar estado de los servicios"
    echo "  health      - Verificar health de los servicios"
    echo "  help        - Mostrar esta ayuda"
    echo ""
}

# Función para iniciar servicios
start_services() {
    echo "🔄 Iniciando servicios..."
    docker-compose -f docker-compose.dev.yml up -d
    echo "✅ Servicios iniciados"
    echo ""
    echo "🌐 URLs disponibles:"
    echo "   Frontend: http://localhost:3000"
    echo "   Backend:  http://localhost:8081"
    echo "   Health:   http://localhost:8081/actuator/health"
    echo ""
}

# Función para detener servicios
stop_services() {
    echo "🛑 Deteniendo servicios..."
    docker-compose -f docker-compose.dev.yml down
    echo "✅ Servicios detenidos"
}

# Función para reiniciar servicios
restart_services() {
    echo "🔄 Reiniciando servicios..."
    docker-compose -f docker-compose.dev.yml restart
    echo "✅ Servicios reiniciados"
}

# Función para construir imágenes
build_images() {
    echo "🏗️ Construyendo imágenes Docker..."
    docker-compose -f docker-compose.dev.yml build --no-cache
    echo "✅ Imágenes construidas"
}

# Función para mostrar logs
show_logs() {
    echo "📋 Mostrando logs de todos los servicios..."
    docker-compose -f docker-compose.dev.yml logs -f
}

# Función para mostrar logs del backend
show_backend_logs() {
    echo "📋 Mostrando logs del backend..."
    docker-compose -f docker-compose.dev.yml logs -f temperatura-backend
}

# Función para mostrar logs del frontend
show_frontend_logs() {
    echo "📋 Mostrando logs del frontend..."
    docker-compose -f docker-compose.dev.yml logs -f temperatura-frontend
}

# Función para mostrar logs de la base de datos
show_db_logs() {
    echo "📋 Mostrando logs de la base de datos..."
    docker-compose -f docker-compose.dev.yml logs -f temperatura-db
}

# Función para ejecutar tests
run_tests() {
    echo "🧪 Ejecutando tests de integración..."
    docker-compose -f docker-compose.test.yml up --build --abort-on-container-exit
    docker-compose -f docker-compose.test.yml down
    echo "✅ Tests completados"
}

# Función para limpiar
clean_all() {
    echo "🧹 Limpiando contenedores y volúmenes..."
    docker-compose -f docker-compose.dev.yml down -v
    docker-compose -f docker-compose.test.yml down -v
    docker system prune -f
    echo "✅ Limpieza completada"
}

# Función para mostrar estado
show_status() {
    echo "📊 Estado de los servicios:"
    docker-compose -f docker-compose.dev.yml ps
}

# Función para verificar health
check_health() {
    echo "🏥 Verificando health de los servicios..."
    echo ""
    echo "Backend Health:"
    curl -s http://localhost:8081/actuator/health | jq '.' || echo "❌ Backend no disponible"
    echo ""
    echo "Frontend Health:"
    curl -s http://localhost:3000 > /dev/null && echo "✅ Frontend disponible" || echo "❌ Frontend no disponible"
    echo ""
    echo "Database Health:"
    docker-compose -f docker-compose.dev.yml exec temperatura-db /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'j1s0n2108*' -Q 'SELECT 1' > /dev/null && echo "✅ Database disponible" || echo "❌ Database no disponible"
}

# Procesar argumentos
case "${1:-help}" in
    "start")
        start_services
        ;;
    "stop")
        stop_services
        ;;
    "restart")
        restart_services
        ;;
    "build")
        build_images
        ;;
    "logs")
        show_logs
        ;;
    "logs-be")
        show_backend_logs
        ;;
    "logs-fe")
        show_frontend_logs
        ;;
    "logs-db")
        show_db_logs
        ;;
    "test")
        run_tests
        ;;
    "clean")
        clean_all
        ;;
    "status")
        show_status
        ;;
    "health")
        check_health
        ;;
    "help")
        show_help
        ;;
    *)
        echo "❌ Comando no reconocido: $1"
        show_help
        exit 1
        ;;
esac
