#!/bin/bash

# Organizr Docker - Security Update Script
# Updates vulnerable packages to their latest secure versions

set -e

echo "🔒 Organizr Docker Security Update Script"
echo "========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed or not available in PATH"
    exit 1
fi

# Update PHP dependencies
update_php_dependencies() {
    print_status "Updating PHP dependencies..."
    
    if [ -f "api/composer.json" ]; then
        cd api
        
        print_status "Removing composer.lock to force fresh install..."
        if [ -f "composer.lock" ]; then
            rm composer.lock
        fi
        
        print_status "Installing updated PHP dependencies..."
        if command -v composer &> /dev/null; then
            composer install --no-dev --optimize-autoloader
        else
            # Use Docker to run composer if not installed locally
            docker run --rm -v "$(pwd):/app" -w /app composer:latest install --no-dev --optimize-autoloader
        fi
        
        cd ..
        print_success "PHP dependencies updated!"
    else
        print_warning "api/composer.json not found, skipping PHP updates"
    fi
}

# Update Node.js dependencies
update_node_dependencies() {
    print_status "Updating Node.js dependencies..."
    
    if [ -f "bootstrap/package.json" ]; then
        cd bootstrap
        
        print_status "Removing package-lock.json and node_modules..."
        rm -rf package-lock.json node_modules
        
        print_status "Installing updated Node.js dependencies..."
        if command -v npm &> /dev/null; then
            npm install
        else
            # Use Docker to run npm if not installed locally
            docker run --rm -v "$(pwd):/app" -w /app node:18-alpine npm install
        fi
        
        cd ..
        print_success "Node.js dependencies updated!"
    else
        print_warning "bootstrap/package.json not found, skipping Node.js updates"
    fi
}

# Security audit
run_security_audit() {
    print_status "Running security audits..."
    
    # PHP security audit
    if [ -f "api/composer.json" ]; then
        print_status "Checking PHP dependencies for vulnerabilities..."
        cd api
        if command -v composer &> /dev/null; then
            composer audit || print_warning "PHP security issues found - please review"
        else
            docker run --rm -v "$(pwd):/app" -w /app composer:latest audit || print_warning "PHP security issues found - please review"
        fi
        cd ..
    fi
    
    # Node.js security audit
    if [ -f "bootstrap/package.json" ]; then
        print_status "Checking Node.js dependencies for vulnerabilities..."
        cd bootstrap
        if command -v npm &> /dev/null; then
            npm audit || print_warning "Node.js security issues found - please review"
        else
            docker run --rm -v "$(pwd):/app" -w /app node:18-alpine npm audit || print_warning "Node.js security issues found - please review"
        fi
        cd ..
    fi
}

# Main execution
main() {
    echo
    print_status "Starting security updates..."
    echo
    
    # Update dependencies
    update_php_dependencies
    echo
    update_node_dependencies
    echo
    
    # Run security audits
    run_security_audit
    echo
    
    print_success "Security updates completed!"
    echo
    print_status "Summary of changes:"
    echo "  📦 PHP Packages Updated:"
    echo "    • guzzlehttp/guzzle: ^7.8 (latest secure version)"
    echo "    • guzzlehttp/psr7: ^2.6 (explicit compatibility dependency)"
    echo "    • slim/psr7: ^1.6.1 (fixes known vulnerabilities)"
    echo "    • lcobucci/jwt: ^5.2 (major security and API improvements)"
    echo "    • composer/semver: ^3.4 (compatibility update)"
    echo "    • phpmailer/phpmailer: ^6.9 (security patches)"
    echo "    • pusher/pusher-php-server: ^7.2 (major compatibility update)"
    echo "    • pragmarx/google2fa: ^8.0 (security improvements)"
    echo "    • psr/log: ^3.0 (interface compatibility)"
    echo "    • slim/slim: ^4.12 (framework updates)"
    echo "    • zircote/swagger-php: ^4.8 (major API documentation updates)"
    echo "    • nekonomokochan/php-json-logger: ^2.1 (logging improvements)"
    echo "    • stripe/stripe-php: ^13.16 (payment security updates)"
    echo "    • ramsey/uuid: ^4.7 (UUID generation improvements)"
    echo "    • monolog/monolog: ^3.5 (logging framework update)"
    echo ""
    echo "  🟨 Node.js Packages Updated:"
    echo "    • grunt: ^1.6.1 (major security and stability update)"
    echo "    • All grunt plugins: Latest compatible versions"
    echo "    • glob: ^10.3.0 (fixes multiple vulnerabilities)"
    echo "    • Node.js requirement: >=18.0.0 (modern runtime)"
    echo ""
    print_warning "⚠️  IMPORTANT: Some packages have breaking changes!"
    print_status "📋 Review the compatibility report: ./scripts/compatibility-check.sh"
    print_warning "🧪 Please test your application thoroughly after these updates!"
    print_status "🐳 Consider rebuilding your Docker image: docker build -t organizr-updated ."
    print_status "📚 Check API documentation for any required code changes"
}

# Run main function
main "$@"
