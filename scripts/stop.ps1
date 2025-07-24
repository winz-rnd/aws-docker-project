# AWS Docker Project - Stop Services
# PowerShell script for stopping all services

Write-Host ""
Write-Host "====================================" -ForegroundColor Cyan
Write-Host "   AWS Docker Project - Stop" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Move to project root
Set-Location (Split-Path $PSScriptRoot -Parent)

Write-Host "Project path: $(Get-Location)" -ForegroundColor Yellow
Write-Host ""

Write-Host "Stopping all services..." -ForegroundColor Blue
docker-compose down

if ($LASTEXITCODE -eq 0) {
    Write-Host "[SUCCESS] All services stopped successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "To restart services:" -ForegroundColor Yellow
    Write-Host "  .\scripts\start.ps1" -ForegroundColor White
    Write-Host ""
    Write-Host "To reset data (WARNING - deletes all data):" -ForegroundColor Yellow
    Write-Host "  docker-compose down -v" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "[ERROR] Failed to stop services." -ForegroundColor Red
    Write-Host "[ERROR] Check manually: docker-compose ps" -ForegroundColor Red
}

Write-Host ""
Read-Host "Press Enter to continue"