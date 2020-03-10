
FROM postgres:9.6.17-alpine

LABEL maintainer="Cap'n Ajax <thomas@capnajax.com>"

# install PHP packages
RUN set -x \
	&& apk add \
		curl \
		fcgi \
		openrc \
		php7-apcu \
		php7-bcmath \
		php7-bz2 \
		php7-cgi \
		php7-common \
		php7-ctype \
		php7-curl \
		php7-curl \
		php7-dom \
		php7-fileinfo \
		php7-fpm \
		php7-gd \
		php7-gettext \
		php7-gmp \
		php7-iconv \
		php7-imap \
		php7-json \
		php7-ldap \
		php7-mbstring \
		php7-mcrypt \
		php7-mysqli \
		php7-odbc \
		php7-openssl \
		php7-pgsql \
		php7-pdo \
		php7-pdo_dblib \
		php7-pdo_mysql \
		php7-pdo_odbc \
		php7-pdo_pgsql \
		php7-pdo_sqlite \
		php7-posix \
		php7-session \
		php7-soap \
		php7-sqlite3 \
		php7-xml \
		php7-xmlreader \
		php7-xmlrpc \
		php7-xmlwriter \
		php7-zip \
		sudo \
		tzdata

RUN set -x && mkdir /usr/local/lepp/

COPY alpine-configs/* /usr/local/lepp/

# install Nginx
RUN set -x \
	&& apk update \
	&& apk add nginx \
	&& adduser -D -g 'www' www \
	&& mkdir /www \
	&& chown -R www:www /var/lib/nginx \
	&& chown -R www:www /www \
	&& mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig \
	&& mv /usr/local/lepp/index.html /www \
	&& rc-update add nginx default

# configure PHP7
ENV PHP_FPM_USER="www" \
	PHP_FPM_GROUP="www" \
	PHP_FPM_LISTEN_MODE="0660" \
	PHP_MEMORY_LIMIT="512M" \
	PHP_MAX_UPLOAD="50M" \
	PHP_MAX_FILE_UPLOAD="200" \
	PHP_MAX_POST="100M" \
	PHP_DISPLAY_ERRORS="On" \
	PHP_DISPLAY_STARTUP_ERRORS="On" \
	PHP_ERROR_REPORTING="E_COMPILE_ERROR\|E_RECOVERABLE_ERROR\|E_ERROR\|E_CORE_ERROR" \
	PHP_CGI_FIX_PATHINFO=0 \
	TIMEZONE="America/Chicago"

RUN set -x \
	&& sed -i "s|;listen.owner\s*=\s*nobody|listen.owner = ${PHP_FPM_USER}|g" /etc/php7/php-fpm.d/www.conf\
	&& sed -i "s|;listen.group\s*=\s*nobody|listen.group = ${PHP_FPM_GROUP}|g" /etc/php7/php-fpm.d/www.conf\
	&& sed -i "s|;listen.mode\s*=\s*0660|listen.mode = ${PHP_FPM_LISTEN_MODE}|g" /etc/php7/php-fpm.d/www.conf\
	&& sed -i "s|user\s*=\s*nobody|user = ${PHP_FPM_USER}|g" /etc/php7/php-fpm.d/www.conf\
	&& sed -i "s|group\s*=\s*nobody|group = ${PHP_FPM_GROUP}|g" /etc/php7/php-fpm.d/www.conf\
	&& sed -i "s|;log_level\s*=\s*notice|log_level = notice|g" /etc/php7/php-fpm.d/www.conf #uncommenting line 

RUN set -x \
	&& sed -i "s|display_errors\s*=\s*Off|display_errors = ${PHP_DISPLAY_ERRORS}|i" /etc/php7/php.ini\
	&& sed -i "s|display_startup_errors\s*=\s*Off|display_startup_errors = ${PHP_DISPLAY_STARTUP_ERRORS}|i" /etc/php7/php.ini\
	&& sed -i "s|error_reporting\s*=\s*E_ALL & ~E_DEPRECATED & ~E_STRICT|error_reporting = ${PHP_ERROR_REPORTING}|i" /etc/php7/php.ini\
	&& sed -i "s|;*memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" /etc/php7/php.ini\
	&& sed -i "s|;*upload_max_filesize =.*|upload_max_filesize = ${PHP_MAX_UPLOAD}|i" /etc/php7/php.ini\
	&& sed -i "s|;*max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|i" /etc/php7/php.ini\
	&& sed -i "s|;*post_max_size =.*|post_max_size = ${PHP_MAX_POST}|i" /etc/php7/php.ini\
	&& sed -i "s|;*cgi.fix_pathinfo=.*|cgi.fix_pathinfo= ${PHP_CGI_FIX_PATHINFO}|i" /etc/php7/php.ini

# Configure Nginx to use PHP7
RUN set -x \
	&& mv /usr/local/lepp/nginx.conf /etc/nginx \
	&& nginx -t \
	&& mv /usr/local/lepp/phpinfo.php /www \
	&& rc-update add php-fpm7 default

RUN set -x \
	&& chmod a+x /usr/local/lepp/entrypoint.sh 

ENTRYPOINT [ "/usr/local/lepp/entrypoint.sh" ]

EXPOSE 80/tcp





