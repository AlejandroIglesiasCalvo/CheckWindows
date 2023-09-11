# Función para confirmar la ejecución del script
function ConfirmExecution {
    $confirm = Read-Host "Do you want to proceed with cleaning all references to F: drive? (y/n)"
    return $confirm
}

# Función para limpiar archivos de configuración de shell
function CleanShellFiles {
    $homePath = $env:USERPROFILE
    $shellFiles = @(".bashrc", ".zshrc")

    foreach ($file in $shellFiles) {
        $filePath = Join-Path -Path $homePath -ChildPath $file
        if (Test-Path -Path $filePath) {
            Write-Host "Cleaning $filePath"
            (Get-Content $filePath) | Where-Object { $_ -notmatch "F:" } | Set-Content $filePath
        }
    }
}

# Función para limpiar la variable de entorno PATH
function CleanEnvironmentPath {
    Write-Host "Cleaning environment PATH variable"
    $newPath = (($env:PATH -split ";") | Where-Object { $_ -notmatch "F:" }) -join ";"
    [System.Environment]::SetEnvironmentVariable('PATH', $newPath, [System.EnvironmentVariableTarget]::Process)
}

# Función para revisar y eliminar tareas programadas (Esta parte solo identifica las tareas)
function CheckScheduledTasks {
    Write-Host "Checking Scheduled Tasks for references to F: drive"
    $tasks = Get-ScheduledTask | Where-Object { $_.Actions -match "F:" }
    if ($tasks) {
        Write-Host "Found tasks that reference F: drive. Manual review required."
        $tasks | ForEach-Object { Write-Host $_.TaskName }
    }
    else {
        Write-Host "No scheduled tasks found that reference F: drive."
    }
}

# Función para buscar y eliminar referencias en el Registro de Windows
function CheckRegistry {
    Write-Host "Checking Windows Registry for references to F: drive"
    $pathsToSearch = @("HKLM:\SOFTWARE", "HKCU:\SOFTWARE")
    
    foreach ($path in $pathsToSearch) {
        Get-ChildItem -Path $path -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
            if ((Get-ItemProperty -Path $_.PsPath -ErrorAction SilentlyContinue) -match "F:") {
                Write-Host "Found reference in Registry at $_.PsPath. Deleting."
                Remove-Item -Path $_.PsPath
            }
        }
    }
}

# Preguntar una sola vez para confirmar toda la operación
$execute = ConfirmExecution

if ($execute -eq 'y') {
    CleanShellFiles
    CleanEnvironmentPath
    CheckScheduledTasks
    CheckRegistry
    Write-Host "Cleanup complete. Review any reported issues and restart your system for changes to take full effect."
}
else {
    Write-Host "Operation cancelled."
}
