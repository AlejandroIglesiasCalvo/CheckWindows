# Script para encontrar y eliminar entradas de Registro inconsistentes relacionadas con las unidades F: y D:

# Inicializar lista para guardar las claves encontradas
$keysToRemove = @()

# Definir las rutas de las claves de Registro donde se listan las aplicaciones instaladas
$registryPaths = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
)

# Recorrer las rutas
foreach ($path in $registryPaths) {
    # Obtener todas las subclaves
    $subkeys = Get-ChildItem -Path $path

    # Recorrer cada subclave para examinar sus valores
    foreach ($key in $subkeys) {
        $shouldRemove = $false
        # Obtener las propiedades 'InstallLocation' y 'UninstallString' (si existen)
        $installLocation = $key.GetValue('InstallLocation')
        $uninstallString = $key.GetValue('UninstallString')

        # Comprobar si la ubicación de instalación apunta a la unidad F: o D:
        if ($installLocation -like 'F:\*' -or ($installLocation -like 'D:\*' -and -Not (Test-Path $installLocation))) {
            $shouldRemove = $true
        }

        # Verificar si el archivo ejecutable del UninstallString existe
        if ($uninstallString -ne $null) {
            $executablePath = ($uninstallString -split ' ')[0]
            if (-Not (Test-Path $executablePath)) {
                Write-Host "UninstallString apunta a un archivo ejecutable que no existe: $executablePath"
                $shouldRemove = $true
            }
        }

        # Detectar errores de Registro comunes (p.e., rutas o nombres inválidos)
        if ($installLocation -eq "" -or $installLocation -eq $null) {
            Write-Host "Ubicación de instalación faltante o inválida"
            $shouldRemove = $true
        }

        if ($shouldRemove) {
            Write-Host "Encontrado: $($key.PSPath) con inconsistencias"
            $keysToRemove += $key.PSPath
        }
    }
}

# Preguntar al usuario si desea eliminar todas las entradas encontradas
if ($keysToRemove.Count -gt 0) {
    $response = Read-Host "Se han encontrado $($keysToRemove.Count) entradas inconsistentes. ¿Deseas eliminar todas estas entradas del registro? (y/N)"
    if ($response -eq 'y') {
        foreach ($keyPath in $keysToRemove) {
            Write-Host "Eliminando $keyPath..."
            Remove-Item -Path $keyPath -Force
        }
    }
}
else {
    Write-Host "No se encontraron entradas inconsistentes."
}
