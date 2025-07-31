# 🐳 Docker Setup for WoW Simple Registration

This directory contains Docker configuration files to help you quickly set up and run the WoW Simple Registration website using Docker containers.

## 📋 Prerequisites

- Docker Engine 20.10+ installed
- Docker Compose 2.0+ installed
- Git installed
- At least 2GB of free disk space

## 🚀 Quick Start

### Option 1: Standalone Setup (Recommended for Testing)

1. **Clone the repository:**
   ```bash
   git clone https://github.com/masterking32/WoWSimpleRegistration.git
   cd WoWSimpleRegistration/docker
   ```

2. **Start the services:**
   ```bash
   docker-compose up -d
   ```

3. **Access the services:**
   - Registration Website: http://localhost
   - phpMyAdmin: http://localhost:8080
   - MailHog (Email Testing): http://localhost:8025

### Option 2: Integration with Existing Docker Setup

If you already have a larger docker-compose.yml file for your WoW server infrastructure:

1. **Clone the repository into your project directory:**
   ```bash
   cd /path/to/your/wow-server-project
   git clone https://github.com/masterking32/WoWSimpleRegistration.git
   ```

2. **Add this service to your existing docker-compose.yml:**
   ```yaml
   wow-registration:
     build:
       context: ./WoWSimpleRegistration
       dockerfile: Dockerfile
     container_name: wow-registration
     restart: unless-stopped
     ports:
       - "80:80"
     volumes:
       # Mount for live development
       - ./WoWSimpleRegistration:/var/www/html
       # Custom config (create your own based on the sample)
       - ./my-config/config.php:/var/www/html/application/config/config.php
     environment:
       DB_AUTH_HOST: your-auth-db-host
       DB_AUTH_PORT: 3306
       DB_AUTH_USER: your-db-user
       DB_AUTH_PASS: your-db-password
       DB_AUTH_NAME: auth
       DB_CHAR_HOST: your-characters-db-host
       DB_CHAR_PORT: 3306
       DB_CHAR_USER: your-db-user
       DB_CHAR_PASS: your-db-password
       DB_CHAR_NAME: characters
     networks:
       - your-network-name
     depends_on:
       - your-mysql-service
   ```

3. **Build and start the service:**
   ```bash
   docker-compose up -d wow-registration
   ```

## 📁 Directory Structure

```
docker/
├── README.md           # This file
├── docker-compose.yml  # Example complete stack setup
└── config/
    └── config.php      # Sample configuration for Docker
```

## ⚙️ Configuration

### Database Connection

The Docker setup uses environment variables for database configuration. You can set these in your docker-compose.yml:

```yaml
environment:
  DB_AUTH_HOST: wow-mysql-auth
  DB_AUTH_PORT: 3306
  DB_AUTH_USER: trinity
  DB_AUTH_PASS: trinity_password
  DB_AUTH_NAME: auth
  DB_CHAR_HOST: wow-mysql-characters
  DB_CHAR_PORT: 3306
  DB_CHAR_USER: trinity
  DB_CHAR_PASS: trinity_password
  DB_CHAR_NAME: characters
```

### Custom Configuration

#### Quick Setup with Docker-Optimized Config

1. **Copy the Docker-optimized config:**
   ```bash
   # From the docker/ directory, copy the config with environment variable support
   cp config/config.php.example ../application/config/config.php
   ```

   This config file is pre-configured to work with Docker and includes:
   - Environment variable support for database connections
   - MailHog SMTP settings for email testing
   - Proper database service names for Docker networking

2. **Alternative: Manual Configuration**
   ```bash
   # Or use the original sample config and modify it manually
   cp ../application/config/config.php.sample ../application/config/config.php
   # Then edit ../application/config/config.php with your database settings
   ```

3. **Edit the configuration file to match your server setup:**
   - Update database credentials (Docker config uses environment variables automatically)
   - Set your realm information
   - Configure SMTP settings (MailHog is pre-configured for testing)
   - Choose your template
   - Enable/disable features

#### Using Environment Variables

The Docker-optimized config (`docker/config/config.php.example`) uses environment variables that are automatically set by docker-compose.yml:

- `DB_AUTH_HOST` → wow-mysql-auth
- `DB_AUTH_USER` → trinity  
- `DB_AUTH_PASS` → trinity_password
- `DB_CHAR_HOST` → wow-mysql-characters

If you want to override any settings, you can modify the environment variables in docker-compose.yml or set them when running the containers.

### Volume Mounting for Development

The docker-compose.yml mounts the entire project as a volume, allowing you to:
- Edit PHP files and see changes immediately
- Modify templates without rebuilding
- Update configuration on the fly
- Access logs for debugging

## 🎨 Customization

### Changing Templates

1. Edit your `config.php`:
   ```php
   $config['template'] = 'battleforazeroth'; // Options: light, advance, icecrown, kaelthas, battleforazeroth
   ```

2. Refresh your browser to see the new template

### Adding Custom Styles

1. Navigate to `template/[your-template]/css/`
2. Edit the CSS files
3. Changes will be reflected immediately due to volume mounting

## 🔧 Maintenance

### Viewing Logs

```bash
# View registration site logs
docker logs wow-registration

# Follow logs in real-time
docker logs -f wow-registration
```

### Accessing the Container

```bash
# Execute bash in the container
docker exec -it wow-registration bash

# Run composer commands
docker exec -it wow-registration composer install --working-dir=/var/www/html/application
```

### Updating the Application

```bash
# Pull latest changes
cd WoWSimpleRegistration
git pull origin master

# Rebuild the container if Dockerfile changed
docker-compose up -d --build wow-registration
```

## 📧 Email Configuration

The example setup includes MailHog for testing emails:
- SMTP Server: `mailhog`
- SMTP Port: `1025`
- No authentication required
- View sent emails at: http://localhost:8025

For production, update the SMTP settings in your config.php to use a real mail server.

## 🐛 Troubleshooting

### Composer/Vendor Directory Issues

If you see errors about missing `vendor/autoload.php`:

1. **Rebuild the container:**
   ```bash
   docker-compose down
   docker-compose up -d --build wow-registration
   ```

2. **Manually install dependencies:**
   ```bash
   docker exec -it wow-registration bash
   cd /var/www/html/application
   composer install --no-dev --optimize-autoloader
   ```

3. **Check if vendor directory exists:**
   ```bash
   docker exec wow-registration ls -la /var/www/html/application/vendor
   ```

### Blank Page or Errors

1. Enable debug mode in config.php:
   ```php
   $config['debug_mode'] = true;
   ```

2. Check container logs:
   ```bash
   docker logs wow-registration
   ```

3. Verify PHP extensions:
   ```bash
   docker exec wow-registration php -m
   ```

### Database Connection Issues

1. Verify database containers are running:
   ```bash
   docker ps
   ```

2. Test database connection:
   ```bash
   docker exec wow-registration php -r "mysqli_connect('wow-mysql-auth', 'trinity', 'trinity_password', 'auth') or die('Connection failed');"
   ```

3. Check network connectivity:
   ```bash
   docker network ls
   docker network inspect wow-network
   ```

### Permission Issues

If you encounter permission errors:
```bash
# Fix ownership
docker exec wow-registration chown -R www-data:www-data /var/www/html

# Fix permissions
docker exec wow-registration chmod -R 755 /var/www/html
```

## 🔒 Security Considerations

1. **Change default passwords** in production
2. **Use HTTPS** with a reverse proxy like Traefik or nginx
3. **Disable debug mode** in production
4. **Restrict database access** to only necessary containers
5. **Regular updates** of both the application and Docker images

## 📚 Additional Resources

- [Main Project Documentation](https://github.com/masterking32/WoWSimpleRegistration)
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [PHP Docker Official Images](https://hub.docker.com/_/php)

## 💡 Tips

- Use `.env` files for sensitive configuration
- Consider using Docker Secrets for passwords in production
- Set up automated backups for your database volumes
- Monitor container health with tools like Prometheus
- Use a reverse proxy for SSL termination and multiple sites

## 🤝 Contributing

Feel free to submit issues or pull requests to improve the Docker setup!
