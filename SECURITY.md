# Security Policy

## Supported Versions

We actively support the following versions of Organizr Docker:

| Version | Supported          |
| ------- | ------------------ |
| latest  | :white_check_mark: |
| dev     | :white_check_mark: |
| < 2.x   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please report it by:

1. **Do NOT** open a public GitHub issue
2. Email the maintainer directly at [security contact]
3. Use GitHub's private vulnerability reporting if available

### What to include in your report:

- Description of the vulnerability
- Steps to reproduce the issue
- Potential impact assessment
- Suggested fix (if any)

### Response Timeline:

- **Acknowledgment**: Within 48 hours
- **Initial Assessment**: Within 1 week
- **Fix Timeline**: Depends on severity
  - Critical: Within 24-48 hours
  - High: Within 1 week
  - Medium: Within 2 weeks
  - Low: Within 1 month

## Security Updates

Security updates are released as:

- New Docker image tags on GHCR
- GitHub releases with security notes
- Updated documentation

## Security Best Practices

When using this Docker image:

1. **Keep images updated**: Regularly pull the latest versions
2. **Use specific tags**: Avoid using `latest` in production
3. **Limit container privileges**: Run with minimal required permissions
4. **Secure volumes**: Ensure proper file permissions on mounted volumes
5. **Network security**: Use proper firewall rules and reverse proxies
6. **Monitor logs**: Keep an eye on container logs for suspicious activity

## Dependencies

This project uses automated dependency scanning via:

- Dependabot for PHP Composer packages
- Dependabot for Docker base images
- Dependabot for GitHub Actions
- Trivy security scanning in CI/CD

Security updates for dependencies are automatically tested and merged when possible.
