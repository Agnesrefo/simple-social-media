FROM ubuntu:22.04

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN apt update -y && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
    php \
    php-cli \
    php-xml \
    php-mbstring \
    php-curl \
    php-mysql \
    php-gd \
    php-zip \
    unzip \
    npm \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/sosmed

COPY . .

RUN mkdir -p bootstrap/cache \
    storage/framework/cache \
    storage/framework/sessions \
    storage/framework/views && \
    chown -R www-data:www-data bootstrap storage && \
    chmod -R ug+rwx bootstrap storage

# Jalankan install.sh (pastikan file ada)
RUN chmod +x install.sh && ./install.sh
#RUN echo "Install.sh skipped for now"

EXPOSE 8000

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
