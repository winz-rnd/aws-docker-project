# AWS Docker Project - Start Services
# PowerShell script for starting all services

Write-Host ""
Write-Host "====================================" -ForegroundColor Cyan
Write-Host "   AWS Docker Project - Start" -ForegroundColor Cyan  
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Move to project root
Set-Location (Split-Path $PSScriptRoot -Parent)

Write-Host "Project path: $(Get-Location)" -ForegroundColor Yellow
Write-Host ""

Write-Host "Checking Docker status..." -ForegroundColor Blue
try {
    docker info | Out-Null
    Write-Host "[SUCCESS] Docker is running." -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Docker is not running." -ForegroundColor Red
    Write-Host "[ERROR] Please start Docker Desktop." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Starting all services..." -ForegroundColor Blue
docker-compose up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host "[SUCCESS] All services started successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Access URLs:" -ForegroundColor Yellow
    Write-Host "  Frontend:      http://localhost:3000" -ForegroundColor Cyan
    Write-Host "  Backend API:   http://localhost:8080" -ForegroundColor Cyan
    Write-Host "  Health check:  http://localhost:8080/api/health" -ForegroundColor Cyan
    Write-Host "  phpMyAdmin:    http://localhost:8081" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Service management:" -ForegroundColor Yellow
    Write-Host "  Check status:  docker-compose ps" -ForegroundColor White
    Write-Host "  View logs:     docker-compose logs -f" -ForegroundColor White
    Write-Host "  Stop services: .\scripts\stop.ps1" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "[ERROR] Failed to start services." -ForegroundColor Red
    Write-Host "[ERROR] Check logs: docker-compose logs" -ForegroundColor Red
}

Write-Host "Visit http://localhost:3000 in your browser to test the application!" -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to continue"