# Script para comprobar el estado de la instalación de Windows

# 1. Comprobar si hay actualizaciones pendientes
Write-Host "Comprobando actualizaciones pendientes..."
$updates = Get-HotFix
if ($updates.Count -eq 0) {
    Write-Host "No se encontraron actualizaciones instaladas. Podría haber actualizaciones pendientes."
}
else {
    Write-Host "Se encontraron $($updates.Count) actualizaciones instaladas."
}

# 2. Verificar integridad de archivos del sistema
Write-Host "Verificando integridad de archivos del sistema (esto puede tardar unos minutos)..."
sfc /scannow

# 3. Comprobar espacio en disco en la unidad del sistema
Write-Host "Comprobando espacio en disco en la unidad del sistema..."
$drive = Get-PSDrive C
$freeSpace = [math]::Round($drive.Free / 1GB, 2)
$totalSpace = [math]::Round($drive.Used / 1GB, 2)
Write-Host "Espacio libre: $($freeSpace)GB, Espacio total: $($totalSpace)GB"

# 4. Comprobar el estado de los servicios críticos de Windows
Write-Host "Verificando el estado de los servicios críticos..."
$criticalServices = @("wuauserv", "cryptsvc", "bits", "msiserver")
foreach ($service in $criticalServices) {
    $status = Get-Service -Name $service
    Write-Host "$($status.DisplayName) está $($status.Status)"
}

# Finalizar el script
Write-Host "Comprobación del estado de la instalación de Windows completada."
