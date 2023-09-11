# Script para encontrar y eliminar entradas de Registro que referencian la unidad F:

# Inicializar una lista para guardar las claves encontradas
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
        # Obtener el valor 'InstallLocation' (si existe)
        $installLocation = $key.GetValue('InstallLocation')
        
        # Comprobar si la ubicación de la instalación está en la unidad F:
        if ($installLocation -like 'F\*') {
            Write-Host "Encontrado: $($key.PSPath) con InstallLocation: $installLocation"
            $keysToRemove += $key.PSPath
        }
    }
}

# Preguntar al usuario si desea eliminar todas las entradas encontradas
if ($keysToRemove.Count -gt 0) {
    $response = Read-Host "Se han encontrado $($keysToRemove.Count) entradas que referencian la unidad F:. ¿Deseas eliminar todas estas entradas del registro? (y/N)"
    if ($response -eq 'y') {
        foreach ($keyPath in $keysToRemove) {
            Write-Host "Eliminando $keyPath..."
            Remove-Item -Path $keyPath -Force
        }
    }
} else {
    Write-Host "No se encontraron entradas que referencian la unidad F:."
}
