FROM ubuntu:22.04

# Install dependencies
RUN apt update -y && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
    apache2 \
    php \
    php-xml \
    php-mbstring \
    php-curl \
    php-mysql \
    php-gd \
    unzip \
    nano \
    curl \
    git

# Install NodeJS (pengganti npm dari apt)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt install -y nodejs

# Install Composer
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    rm composer-setup.php

# Set working directory
RUN mkdir -p /var/www/sosmed
WORKDIR /var/www/sosmed

# Copy project
ADD . /var/www/sosmed
ADD sosmed.conf /etc/apache2/sites-available/

# Enable site
RUN a2dissite 000-default.conf && a2ensite sosmed.conf

# Laravel folder permission
RUN mkdir -p bootstrap/cache \
    storage/framework/cache \
    storage/framework/sessions \
    storage/framework/views && \
    chmod -R 775 bootstrap storage

# Install composer dependencies
RUN composer install --no-interaction --optimize-autoloader || true

# FIX Apache port ke 8080
RUN sed -i 's/80/8080/g' /etc/apache2/ports.conf && \
    sed -i 's/:80/:8080/g' /etc/apache2/sites-available/000-default.conf || true

# Permission final
RUN chmod -R 755 /var/www/sosmed

# Port expose
EXPOSE 8080

# Run Apache
CMD ["apachectl", "-D", "FOREGROUND"]
