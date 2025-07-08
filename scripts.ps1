# Scripts para desarrollo local de Temperatura CRUD (PowerShell)

param(
    [Parameter(Position=0)]
    [string]$Command = "help"
)

Write-Host "🚀 Temperatura CRUD - Development Scripts" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

# Función para mostrar ayuda
function Show-Help {
    Write-Host "Uso: .\scripts.ps1 [comando]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Comandos disponibles:" -ForegroundColor Cyan
    Write-Host "  start       - Iniciar todos los servicios" -ForegroundColor White
    Write-Host "  stop        - Detener todos los servicios" -ForegroundColor White
    Write-Host "  restart     - Reiniciar todos los servicios" -ForegroundColor White
    Write-Host "  build       - Construir imágenes Docker" -ForegroundColor White
    Write-Host "  logs        - Mostrar logs de todos los servicios" -ForegroundColor White
    Write-Host "  logs-be     - Mostrar logs del backend" -ForegroundColor White
    Write-Host "  logs-fe     - Mostrar logs del frontend" -ForegroundColor White
    Write-Host "  logs-db     - Mostrar logs de la base de datos" -ForegroundColor White
    Write-Host "  test        - Ejecutar tests de integración" -ForegroundColor White
    Write-Host "  clean       - Limpiar contenedores y volúmenes" -ForegroundColor White
    Write-Host "  status      - Mostrar estado de los servicios" -ForegroundColor White
    Write-Host "  health      - Verificar health de los servicios" -ForegroundColor White
    Write-Host "  help        - Mostrar esta ayuda" -ForegroundColor White
    Write-Host ""
}

# Función para iniciar servicios
function Start-Services {
    Write-Host "🔄 Iniciando servicios..." -ForegroundColor Blue
    docker-compose -f docker-compose.dev.yml up -d
    Write-Host "✅ Servicios iniciados" -ForegroundColor Green
    Write-Host ""
    Write-Host "🌐 URLs disponibles:" -ForegroundColor Cyan
    Write-Host "   Frontend: http://localhost:3000" -ForegroundColor White
    Write-Host "   Backend:  http://localhost:8081" -ForegroundColor White
    Write-Host "   Health:   http://localhost:8081/actuator/health" -ForegroundColor White
    Write-Host ""
}

# Función para detener servicios
function Stop-Services {
    Write-Host "🛑 Deteniendo servicios..." -ForegroundColor Red
    docker-compose -f docker-compose.dev.yml down
    Write-Host "✅ Servicios detenidos" -ForegroundColor Green
}

# Función para reiniciar servicios
function Restart-Services {
    Write-Host "🔄 Reiniciando servicios..." -ForegroundColor Blue
    docker-compose -f docker-compose.dev.yml restart
    Write-Host "✅ Servicios reiniciados" -ForegroundColor Green
}

# Función para construir imágenes
function Build-Images {
    Write-Host "🏗️ Construyendo imágenes Docker..." -ForegroundColor Blue
    docker-compose -f docker-compose.dev.yml build --no-cache
    Write-Host "✅ Imágenes construidas" -ForegroundColor Green
}

# Función para mostrar logs
function Show-Logs {
    Write-Host "📋 Mostrando logs de todos los servicios..." -ForegroundColor Blue
    docker-compose -f docker-compose.dev.yml logs -f
}

# Función para mostrar logs del backend
function Show-BackendLogs {
    Write-Host "📋 Mostrando logs del backend..." -ForegroundColor Blue
    docker-compose -f docker-compose.dev.yml logs -f temperatura-backend
}

# Función para mostrar logs del frontend
function Show-FrontendLogs {
    Write-Host "📋 Mostrando logs del frontend..." -ForegroundColor Blue
    docker-compose -f docker-compose.dev.yml logs -f temperatura-frontend
}

# Función para mostrar logs de la base de datos
function Show-DbLogs {
    Write-Host "📋 Mostrando logs de la base de datos..." -ForegroundColor Blue
    docker-compose -f docker-compose.dev.yml logs -f temperatura-db
}

# Función para ejecutar tests
function Run-Tests {
    Write-Host "🧪 Ejecutando tests de integración..." -ForegroundColor Blue
    docker-compose -f docker-compose.test.yml up --build --abort-on-container-exit
    docker-compose -f docker-compose.test.yml down
    Write-Host "✅ Tests completados" -ForegroundColor Green
}

# Función para limpiar
function Clean-All {
    Write-Host "🧹 Limpiando contenedores y volúmenes..." -ForegroundColor Blue
    docker-compose -f docker-compose.dev.yml down -v
    docker-compose -f docker-compose.test.yml down -v
    docker system prune -f
    Write-Host "✅ Limpieza completada" -ForegroundColor Green
}

# Función para mostrar estado
function Show-Status {
    Write-Host "📊 Estado de los servicios:" -ForegroundColor Blue
    docker-compose -f docker-compose.dev.yml ps
}

# Función para verificar health
function Check-Health {
    Write-Host "🏥 Verificando health de los servicios..." -ForegroundColor Blue
    Write-Host ""
    
    Write-Host "Backend Health:" -ForegroundColor Cyan
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8081/actuator/health" -Method Get -TimeoutSec 5
        $response | ConvertTo-Json -Depth 3
        Write-Host "✅ Backend disponible" -ForegroundColor Green
    } catch {
        Write-Host "❌ Backend no disponible" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "Frontend Health:" -ForegroundColor Cyan
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000" -Method Get -TimeoutSec 5
        Write-Host "✅ Frontend disponible" -ForegroundColor Green
    } catch {
        Write-Host "❌ Frontend no disponible" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "Database Health:" -ForegroundColor Cyan
    try {
        $result = docker-compose -f docker-compose.dev.yml exec temperatura-db /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'j1s0n2108*' -Q 'SELECT 1' 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Database disponible" -ForegroundColor Green
        } else {
            Write-Host "❌ Database no disponible" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ Database no disponible" -ForegroundColor Red
    }
}

# Procesar argumentos
switch ($Command.ToLower()) {
    "start" { Start-Services }
    "stop" { Stop-Services }
    "restart" { Restart-Services }
    "build" { Build-Images }
    "logs" { Show-Logs }
    "logs-be" { Show-BackendLogs }
    "logs-fe" { Show-FrontendLogs }
    "logs-db" { Show-DbLogs }
    "test" { Run-Tests }
    "clean" { Clean-All }
    "status" { Show-Status }
    "health" { Check-Health }
    "help" { Show-Help }
    default {
        Write-Host "❌ Comando no reconocido: $Command" -ForegroundColor Red
        Show-Help
        exit 1
    }
}
