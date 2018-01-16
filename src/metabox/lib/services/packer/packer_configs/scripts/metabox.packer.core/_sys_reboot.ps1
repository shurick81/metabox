Write-Host "Restarting...."
$LASTEXITCODE = 0; Restart-Computer -Force -Confirm:$false; exit 0;