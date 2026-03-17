FROM php:8.2-apache

# تثبيت PHP extensions
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libonig-dev libxml2-dev zip unzip git curl \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd

# تعطيل MPM conflicted وتفعيل prefork + rewrite
RUN a2dismod mpm_event && a2enmod mpm_prefork
RUN a2enmod rewrite

# تثبيت Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# نسخ المشروع
COPY . .

# تثبيت Laravel dependencies
RUN composer install --no-dev --optimize-autoloader

# permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage

# Apache يجب أن يشير لـ public
RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf

EXPOSE 80

CMD ["apache2-foreground"]