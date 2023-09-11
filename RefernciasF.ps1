Get-ChildItem -Path HKLM:\, HKCU:\ -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'F:' } | Remove-Item -Recurse -Force
Get-ChildItem -Path 'C:\' -Recurse -ErrorAction SilentlyContinue | Where-Object { ($_.FullName -match 'F:') -or ($_.FullName -match 'F\\') } | Remove-Item -Recurse -Force