# Organizr Docker - Security Update Script (PowerShell)
# Updates vulnerable packages to their latest secure versions

param(
    [switch]$SkipAudit = $false
)

# Colors for output
$Colors = @{
    Info = "Cyan"
    Success = "Green"
    Warning = "Yellow"
    Error = "Red"
}

function Write-Status {
    param([string]$Message, [string]$Type = "Info")
    $color = $Colors[$Type]
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] " -NoNewline
    Write-Host "[$Type] " -ForegroundColor $color -NoNewline
    Write-Host $Message
}

function Test-Command {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# Check if Docker is available
if (-not (Test-Command "docker")) {
    Write-Status "Docker is not installed or not available in PATH" "Error"
    exit 1
}

Write-Host "🔒 Organizr Docker Security Update Script" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Update PHP dependencies
function Update-PhpDependencies {
    Write-Status "Updating PHP dependencies..."
    
    if (Test-Path "api/composer.json") {
        Push-Location "api"
        
        Write-Status "Removing composer.lock to force fresh install..."
        if (Test-Path "composer.lock") {
            Remove-Item "composer.lock" -Force
        }
        
        Write-Status "Installing updated PHP dependencies..."
        if (Test-Command "composer") {
            & composer install --no-dev --optimize-autoloader
        } else {
            # Use Docker to run composer if not installed locally
            & docker run --rm -v "${PWD}:/app" -w /app composer:latest install --no-dev --optimize-autoloader
        }
        
        Pop-Location
        Write-Status "PHP dependencies updated!" "Success"
    } else {
        Write-Status "api/composer.json not found, skipping PHP updates" "Warning"
    }
}

# Update Node.js dependencies
function Update-NodeDependencies {
    Write-Status "Updating Node.js dependencies..."
    
    if (Test-Path "bootstrap/package.json") {
        Push-Location "bootstrap"
        
        Write-Status "Removing package-lock.json and node_modules..."
        if (Test-Path "package-lock.json") { Remove-Item "package-lock.json" -Force }
        if (Test-Path "node_modules") { Remove-Item "node_modules" -Recurse -Force }
        
        Write-Status "Installing updated Node.js dependencies..."
        if (Test-Command "npm") {
            & npm install
        } else {
            # Use Docker to run npm if not installed locally
            & docker run --rm -v "${PWD}:/app" -w /app node:18-alpine npm install
        }
        
        Pop-Location
        Write-Status "Node.js dependencies updated!" "Success"
    } else {
        Write-Status "bootstrap/package.json not found, skipping Node.js updates" "Warning"
    }
}

# Security audit
function Invoke-SecurityAudit {
    if ($SkipAudit) {
        Write-Status "Skipping security audit (--SkipAudit flag provided)" "Warning"
        return
    }
    
    Write-Status "Running security audits..."
    
    # PHP security audit
    if (Test-Path "api/composer.json") {
        Write-Status "Checking PHP dependencies for vulnerabilities..."
        Push-Location "api"
        try {
            if (Test-Command "composer") {
                & composer audit
            } else {
                & docker run --rm -v "${PWD}:/app" -w /app composer:latest audit
            }
        } catch {
            Write-Status "PHP security issues found - please review" "Warning"
        }
        Pop-Location
    }
    
    # Node.js security audit
    if (Test-Path "bootstrap/package.json") {
        Write-Status "Checking Node.js dependencies for vulnerabilities..."
        Push-Location "bootstrap"
        try {
            if (Test-Command "npm") {
                & npm audit
            } else {
                & docker run --rm -v "${PWD}:/app" -w /app node:18-alpine npm audit
            }
        } catch {
            Write-Status "Node.js security issues found - please review" "Warning"
        }
        Pop-Location
    }
}

# Main execution
try {
    Write-Status "Starting security updates..."
    Write-Host ""
    
    # Update dependencies
    Update-PhpDependencies
    Write-Host ""
    Update-NodeDependencies
    Write-Host ""
    
    # Run security audits
    Invoke-SecurityAudit
    Write-Host ""
    
    Write-Status "Security updates completed!" "Success"
    Write-Host ""
    Write-Status "Summary of changes:"
    Write-Host "  📦 PHP Packages Updated:" -ForegroundColor Cyan
    Write-Host "    • guzzlehttp/guzzle: ^7.8 (latest secure version)"
    Write-Host "    • guzzlehttp/psr7: ^2.6 (explicit compatibility dependency)"
    Write-Host "    • slim/psr7: ^1.6.1 (fixes known vulnerabilities)"
    Write-Host "    • lcobucci/jwt: ^5.2 (major security and API improvements)"
    Write-Host "    • composer/semver: ^3.4 (compatibility update)"
    Write-Host "    • phpmailer/phpmailer: ^6.9 (security patches)"
    Write-Host "    • pusher/pusher-php-server: ^7.2 (major compatibility update)"
    Write-Host "    • pragmarx/google2fa: ^8.0 (security improvements)"
    Write-Host "    • psr/log: ^3.0 (interface compatibility)"
    Write-Host "    • slim/slim: ^4.12 (framework updates)"
    Write-Host "    • zircote/swagger-php: ^4.8 (major API documentation updates)"
    Write-Host "    • nekonomokochan/php-json-logger: ^2.1 (logging improvements)"
    Write-Host "    • stripe/stripe-php: ^13.16 (payment security updates)"
    Write-Host "    • ramsey/uuid: ^4.7 (UUID generation improvements)"
    Write-Host "    • monolog/monolog: ^3.5 (logging framework update)"
    Write-Host ""
    Write-Host "  🟨 Node.js Packages Updated:" -ForegroundColor Yellow
    Write-Host "    • grunt: ^1.6.1 (major security and stability update)"
    Write-Host "    • All grunt plugins: Latest compatible versions"
    Write-Host "    • glob: ^10.3.0 (fixes multiple vulnerabilities)"
    Write-Host "    • Node.js requirement: >=18.0.0 (modern runtime)"
    Write-Host ""
    Write-Status "⚠️  IMPORTANT: Some packages have breaking changes!" "Warning"
    Write-Status "📋 Review the compatibility report: .\scripts\compatibility-check.sh"
    Write-Status "🧪 Please test your application thoroughly after these updates!" "Warning"
    Write-Status "🐳 Consider rebuilding your Docker image: docker build -t organizr-updated ."
    Write-Status "📚 Check API documentation for any required code changes"
    
} catch {
    Write-Status "An error occurred during the update process: $($_.Exception.Message)" "Error"
    exit 1
}
