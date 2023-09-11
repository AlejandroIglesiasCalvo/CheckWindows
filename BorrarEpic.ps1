# Buscar todas las carpetas que contienen el nombre "EpicGames"
$folders = Get-ChildItem -Path "C:\" -Recurse -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*EpicGames*" }

# Mostrar las carpetas encontradas
$folders | ForEach-Object { Write-Host $_.FullName }

# Preguntar al usuario si desea eliminar las carpetas
$answer = Read-Host "¿Desea eliminar estas carpetas? (s/n)"

# Eliminar las carpetas si el usuario responde 's'
if ($answer -eq 's') {
    $folders | ForEach-Object {
        Remove-Item $_.FullName -Recurse -Force
    }
}
