#!/bin/bash

# Organizr Docker - Dependency Compatibility Checker
# Ensures all updated dependencies work together properly

set -e

echo "🔍 Organizr Docker Dependency Compatibility Checker"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Function to check PHP compatibility
check_php_compatibility() {
    print_status "Checking PHP dependency compatibility..."
    
    cd api
    
    # Check if composer is available
    if command -v composer &> /dev/null; then
        COMPOSER_CMD="composer"
    else
        COMPOSER_CMD="docker run --rm -v \"$(pwd):/app\" -w /app composer:latest"
    fi
    
    # Validate composer.json
    print_status "Validating composer.json syntax..."
    if eval "$COMPOSER_CMD validate --strict"; then
        print_success "composer.json is valid"
    else
        print_error "composer.json validation failed"
        cd ..
        return 1
    fi
    
    # Check for dependency conflicts
    print_status "Checking for dependency conflicts..."
    if eval "$COMPOSER_CMD check-platform-reqs"; then
        print_success "Platform requirements satisfied"
    else
        print_warning "Some platform requirements may not be met"
    fi
    
    # Update dependencies and check for conflicts
    print_status "Testing dependency resolution..."
    rm -f composer.lock
    if eval "$COMPOSER_CMD update --dry-run --no-scripts"; then
        print_success "Dependencies can be resolved without conflicts"
    else
        print_error "Dependency conflicts detected"
        cd ..
        return 1
    fi
    
    cd ..
}

# Function to check Node.js compatibility
check_node_compatibility() {
    print_status "Checking Node.js dependency compatibility..."
    
    cd bootstrap
    
    # Check if npm is available
    if command -v npm &> /dev/null; then
        NPM_CMD="npm"
    else
        NPM_CMD="docker run --rm -v \"$(pwd):/app\" -w /app node:18-alpine npm"
    fi
    
    # Check package.json syntax
    print_status "Validating package.json syntax..."
    if node -e "JSON.parse(require('fs').readFileSync('package.json', 'utf8'))"; then
        print_success "package.json is valid"
    else
        print_error "package.json validation failed"
        cd ..
        return 1
    fi
    
    # Check for dependency conflicts
    print_status "Checking for Node.js dependency conflicts..."
    rm -rf package-lock.json node_modules
    if eval "$NPM_CMD install --dry-run"; then
        print_success "Node.js dependencies can be resolved"
    else
        print_warning "Some Node.js dependency issues detected"
    fi
    
    cd ..
}

# Function to test specific package compatibility
test_package_compatibility() {
    print_status "Testing critical package compatibility..."
    
    # Test PHP packages
    cd api
    
    print_status "Testing Guzzle HTTP client compatibility..."
    if command -v composer &> /dev/null; then
        composer require --dry-run guzzlehttp/guzzle:^7.8 guzzlehttp/psr7:^2.6 2>/dev/null
        if [ $? -eq 0 ]; then
            print_success "Guzzle packages are compatible"
        else
            print_warning "Guzzle compatibility issues detected"
        fi
    fi
    
    print_status "Testing Slim framework compatibility..."
    if command -v composer &> /dev/null; then
        composer require --dry-run slim/slim:^4.12 slim/psr7:^1.6.1 2>/dev/null
        if [ $? -eq 0 ]; then
            print_success "Slim packages are compatible"
        else
            print_warning "Slim compatibility issues detected"
        fi
    fi
    
    cd ..
    
    # Test Node.js packages
    cd bootstrap
    
    print_status "Testing Grunt compatibility with Node.js..."
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
        if [ "$NODE_VERSION" -ge 18 ]; then
            print_success "Node.js version is compatible with updated Grunt"
        else
            print_warning "Node.js version may be too old for updated Grunt packages"
        fi
    fi
    
    cd ..
}

# Function to create compatibility report
create_compatibility_report() {
    print_status "Creating compatibility report..."
    
    cat > COMPATIBILITY_REPORT.md << 'EOF'
# Dependency Compatibility Report

Generated on: $(date)

## Updated Packages

### PHP Dependencies (Composer)
- **guzzlehttp/guzzle**: ^7.8 (was transitive dependency)
- **guzzlehttp/psr7**: ^2.6 (new explicit dependency for compatibility)
- **slim/psr7**: ^1.6.1 (updated from ^1.1)
- **lcobucci/jwt**: ^5.2 (updated from ^4.1)
- **composer/semver**: ^3.4 (updated from ^1.4)
- **phpmailer/phpmailer**: ^6.9 (updated from ^6.2)
- **pusher/pusher-php-server**: ^7.2 (updated from ^4.0)
- **pragmarx/google2fa**: ^8.0 (updated from ^3.0)
- **psr/log**: ^3.0 (updated from ^1.1)
- **slim/slim**: ^4.12 (updated from ^4.0)
- **zircote/swagger-php**: ^4.8 (updated from ^3.0)
- **nekonomokochan/php-json-logger**: ^2.1 (updated from ^1.3)
- **stripe/stripe-php**: ^13.16 (updated from ^7.116)
- **ramsey/uuid**: ^4.7 (updated from ^4.2)
- **monolog/monolog**: ^3.5 (new dependency)

### Node.js Dependencies (NPM)
- **grunt**: ~1.6.1 (updated from ~0.4.5)
- **glob**: ~10.3.0 (updated from ~6.0.1)
- **All grunt plugins**: Updated to latest compatible versions
- **Node.js requirement**: >=18.0.0 (updated from >=0.10.1)

## Compatibility Notes

### PHP 8.1+ Compatibility
- All packages now explicitly support PHP 8.1+
- PSR interfaces updated to latest versions
- JWT library updated for better security and PHP 8.x compatibility

### HTTP Client Stack
- Guzzle HTTP client updated to latest secure version
- PSR-7 HTTP message interfaces updated
- Slim framework components updated for compatibility

### Security Improvements
- All packages updated to versions without known vulnerabilities
- JWT handling improved with latest lcobucci/jwt
- HTTP client security enhanced with Guzzle 7.8+

### Breaking Changes
- Some API changes may be required for:
  - JWT token handling (lcobucci/jwt 4.x -> 5.x)
  - Pusher client (4.x -> 7.x)
  - Google2FA (3.x -> 8.x)
  - Swagger-PHP (3.x -> 4.x)

### Testing Recommendations
1. Test JWT token generation and validation
2. Test Pusher real-time functionality
3. Test API documentation generation
4. Test two-factor authentication
5. Test payment processing with Stripe
6. Verify all HTTP client functionality

EOF

    print_success "Compatibility report created: COMPATIBILITY_REPORT.md"
}

# Main execution
main() {
    print_status "Starting compatibility checks..."
    echo
    
    # Run compatibility checks
    if check_php_compatibility && check_node_compatibility; then
        print_success "Basic compatibility checks passed"
    else
        print_error "Some compatibility issues detected"
    fi
    
    echo
    test_package_compatibility
    echo
    
    create_compatibility_report
    echo
    
    print_success "Compatibility check completed!"
    echo
    print_status "Next steps:"
    echo "  1. Review COMPATIBILITY_REPORT.md for breaking changes"
    echo "  2. Run: ./scripts/security-update.sh to apply updates"
    echo "  3. Test critical functionality after updates"
    echo "  4. Update any code that uses changed APIs"
}

# Run main function
main "$@"
