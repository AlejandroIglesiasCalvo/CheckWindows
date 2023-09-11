# Script para encontrar y eliminar entradas de Registro relacionadas con Epic Games

# Inicializar una lista para guardar las claves encontradas
$keysToRemove = @()

# Definir las rutas de las claves de Registro donde se listan las aplicaciones instaladas
$registryPaths = @(
    'HKLM:\*'
)

# Recorrer las rutas
foreach ($path in $registryPaths) {
    # Obtener todas las subclaves
    $subkeys = Get-ChildItem -Path $path

    # Recorrer cada subclave para examinar sus valores
    foreach ($key in $subkeys) {
        # Obtener el valor 'DisplayName' (si existe)
        $displayName = $key.GetValue('DisplayName')
        
        # Comprobar si el nombre de la aplicación contiene "Epic Games"
        if ($displayName -like '*EpicGames*') {
            Write-Host "Encontrado: $($key.PSPath) con DisplayName: $displayName"
            $keysToRemove += $key.PSPath
        }
    }
}

# Preguntar al usuario si desea eliminar todas las entradas encontradas
if ($keysToRemove.Count -gt 0) {
    $response = Read-Host "Se han encontrado $($keysToRemove.Count) entradas relacionadas con Epic Games. ¿Deseas eliminar todas estas entradas del registro? (y/N)"
    if ($response -eq 'y') {
        foreach ($keyPath in $keysToRemove) {
            Write-Host "Eliminando $keyPath..."
            Remove-Item -Path $keyPath -Force
        }
    }
} else {
    Write-Host "No se encontraron entradas relacionadas con Epic Games."
}
