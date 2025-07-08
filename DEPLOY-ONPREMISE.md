# 🏢 Deploy a Servidor On-Premise

## 🎯 **Tu Escenario**
- **Desarrollo**: Tu PC (sin Docker)
- **CI/CD**: GitHub Actions (nube)
- **Producción**: Tu servidor on-premise
- **Base de datos**: Servidor ERP externo

## 🔧 **Configuración Necesaria**

### 1. **GitHub Actions → Tu Servidor**

#### **Secrets en GitHub** (Configurar una vez):
```yaml
# Settings → Secrets → Actions
PRODUCTION_HOST: 192.168.1.100      # IP de tu Windows Server
PRODUCTION_USER: Administrator      # Usuario de Windows
PRODUCTION_SSH_KEY: -----BEGIN OPENSSH PRIVATE KEY-----
PRODUCTION_PATH: C:\Apps\temperatura
DB_CONNECTION_STRING: jdbc:sqlserver://erp-server:1433;...
```

#### **Job de Deploy Modificado para Windows Server**:
```yaml
deploy-production:
  runs-on: ubuntu-latest
  needs: [integration-tests]
  if: github.ref == 'refs/heads/main'
  steps:
    - name: Deploy to Windows Production Server
      uses: appleboy/ssh-action@v0.1.7
      with:
        host: ${{ secrets.PRODUCTION_HOST }}
        username: ${{ secrets.PRODUCTION_USER }}
        key: ${{ secrets.PRODUCTION_SSH_KEY }}
        script: |
          cd C:\Apps\temperatura
          docker-compose -f docker-compose.prod.yml pull
          docker-compose -f docker-compose.prod.yml up -d
          timeout 30
          curl -f http://localhost:8083/actuator/health
```

### 2. **En Tu Windows Server**

#### **Instalar Docker** (Una vez):
```powershell
# Instalar Docker Desktop para Windows Server
# O Docker Engine via chocolatey
choco install docker-desktop
# O manual desde: https://docs.docker.com/desktop/install/windows-install/

# Verificar instalación
docker --version
docker-compose --version
```

#### **Configurar la Aplicación**:
```powershell
# Crear directorio
New-Item -ItemType Directory -Force -Path "C:\Apps\temperatura"
Set-Location "C:\Apps\temperatura"

# Crear docker-compose.prod.yml
```

#### **docker-compose.prod.yml**:
```yaml
version: '3.8'
services:
  temperatura-backend:
    image: tu-usuario/temperatura-backend:latest
    ports:
      - "8083:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - SPRING_DATASOURCE_URL=jdbc:sqlserver://erp-server:1433;databaseName=TemperaturaDB;encrypt=true;trustServerCertificate=true
      - SPRING_DATASOURCE_USERNAME=${DB_USERNAME}
      - SPRING_DATASOURCE_PASSWORD=${DB_PASSWORD}
    restart: unless-stopped
    
  temperatura-frontend:
    image: tu-usuario/temperatura-frontend:latest
    ports:
      - "3002:3000"
    environment:
      - NEXT_PUBLIC_API_URL=http://tu-servidor:8083
    restart: unless-stopped
```

## 🚀 **Flujo Completo**

### **Desarrollo** (Tu PC):
```bash
# Solo código, sin Docker
npm run dev              # Frontend
./mvnw spring-boot:run   # Backend
git push origin main     # Trigger deploy
```

### **CI/CD** (GitHub Actions):
```mermaid
graph LR
    A[git push] --> B[GitHub Actions]
    B --> C[Build/Test]
    C --> D[Docker Build]
    D --> E[Push to Registry]
    E --> F[Deploy to Tu Servidor]
```

### **Producción** (Tu Windows Server):
```powershell
# Automático vía SSH desde GitHub Actions
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d
```

## 🔒 **Configuración de SSH en Windows Server**

### **Habilitar SSH en Windows Server**:
```powershell
# Instalar OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# Iniciar y habilitar servicio
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'

# Verificar que está corriendo
Get-Service sshd
```

### **Generar SSH Key**:
```powershell
# En tu PC (PowerShell)
ssh-keygen -t ed25519 -f "$env:USERPROFILE\.ssh\github_actions_key"
Get-Content "$env:USERPROFILE\.ssh\github_actions_key.pub"  # Copiar contenido
```

### **En Tu Windows Server**:
```powershell
# Crear directorio SSH si no existe
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.ssh"

# Agregar public key
Add-Content -Path "$env:USERPROFILE\.ssh\authorized_keys" -Value "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIxxx..."

# Configurar permisos
icacls "$env:USERPROFILE\.ssh\authorized_keys" /inheritance:r /grant:r "$env:USERNAME:(R)"
```

### **En GitHub**:
```powershell
# Copiar private key completa
Get-Content "$env:USERPROFILE\.ssh\github_actions_key"
# Pegar en GitHub → Settings → Secrets → PRODUCTION_SSH_KEY
```

## 🎯 **Ventajas de Esta Configuración**

### ✅ **Desarrollo Simplificado**:
- Solo código en tu PC
- Sin Docker local
- `git push` = deploy automático

### ✅ **CI/CD Profesional**:
- Tests automáticos
- Security scanning
- Build en la nube

### ✅ **Producción Controlada**:
- En tu servidor
- Acceso a BD ERP
- Monitoreo local

## 🔄 **Alternativas para Windows Server**

### **Opción 2: Self-Hosted Runner en Windows**
```yaml
# Tu Windows Server como runner de GitHub Actions
runs-on: self-hosted
```

### **Opción 3: PowerShell Remoting**
```powershell
# Usar PowerShell remoting en lugar de SSH
Invoke-Command -ComputerName $server -ScriptBlock {
    Set-Location "C:\Apps\temperatura"
    docker-compose -f docker-compose.prod.yml up -d
}
```

### **Opción 4: Pull-Based Deploy con Task Scheduler**
```powershell
# Script en tu servidor que pull las imágenes cada 5 minutos
# Programar en Task Scheduler: C:\Apps\temperatura\update.ps1
```

## 📋 **Checklist de Implementación para Windows Server**

- [ ] Instalar Docker Desktop en Windows Server
- [ ] Habilitar SSH Server en Windows
- [ ] Configurar SSH keys (PowerShell)
- [ ] Crear secrets en GitHub
- [ ] Modificar workflow de deploy para Windows paths
- [ ] Configurar docker-compose.prod.yml
- [ ] Probar conectividad SSH desde GitHub Actions
- [ ] Configurar conexión a BD ERP
- [ ] Hacer deploy de prueba
- [ ] Configurar Windows Firewall para Docker ports

## 🎉 **Resultado Final**

```bash
# Tu PC - Solo desarrollo
npm run dev
git push origin main

# GitHub Actions - Build/Test/Deploy
# (Automático en la nube)

# Tu Windows Server - Aplicación corriendo
# http://tu-servidor:8083 (Backend)
# http://tu-servidor:3002 (Frontend)
```

## ⚠️ **Consideraciones Especiales para Windows Server**

### **1. Rutas de Archivos**
```yaml
# Usar rutas de Windows en scripts
PRODUCTION_PATH: C:\Apps\temperatura
# No usar: /apps/temperatura
```

### **2. Comandos PowerShell vs Bash**
```powershell
# PowerShell en lugar de bash
timeout 30        # En lugar de: sleep 30
Set-Location      # En lugar de: cd
New-Item          # En lugar de: mkdir
```

### **3. Firewall de Windows**
```powershell
# Abrir puertos para Docker
New-NetFirewallRule -DisplayName "Docker Backend" -Direction Inbound -Protocol TCP -LocalPort 8083
New-NetFirewallRule -DisplayName "Docker Frontend" -Direction Inbound -Protocol TCP -LocalPort 3002
```

### **4. Docker en Windows**
```powershell
# Verificar que Docker funciona
docker run hello-world
docker-compose --version

# Si hay problemas, reiniciar Docker service
Restart-Service docker
```

### **5. Variables de Entorno**
```powershell
# En docker-compose.prod.yml usar variables de Windows
environment:
  - SPRING_DATASOURCE_URL=jdbc:sqlserver://erp-server:1433;databaseName=TemperaturaDB
  - TEMP_DIR=${TEMP}  # Variable de Windows
```

### **6. Permisos y Seguridad**
```powershell
# Asegurar que el usuario tenga permisos Docker
Add-LocalGroupMember -Group "docker-users" -Member "Administrator"

# Configurar execution policy si es necesario
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**¡Tendrás lo mejor de ambos mundos en Windows Server!** 🚀
