# nginx-php image 
#   docker build -t elarasu/weave-nginx-php .
#
FROM elarasu/weave-supervisord
MAINTAINER elarasu@outlook.com

# Install requirements
RUN  apt-get update  \
  && apt-get upgrade -y \
  && apt-get install -yq ssh nodejs sudo cron git sendmail fetchmail ca-certificates nodejs-legacy npm python-pygments \
       build-essential g++ nginx \
       php5 php5-common php5-fpm php5-mcrypt php5-intl php5-mysql php5-gd php5-dev php5-apcu php5-curl php-apc php5-cli php5-json php5-ldap php5-imap php-pear --no-install-recommends \
  && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

# Composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

# Expose Nginx on port 80 and 443
EXPOSE 80
EXPOSE 443

# Add service config files
ADD conf/fastcgi.conf /etc/nginx/
ADD conf/nginx.conf /etc/nginx/
ADD conf/php.ini /etc/php5/fpm/
ADD conf/php-fpm.conf /etc/php5/fpm/

# Add Supervisord config files
ADD conf/cron.sv.conf /etc/supervisor/conf.d/
ADD conf/nginx.sv.conf /etc/supervisor/conf.d/
ADD conf/php5-fpm.sv.conf /etc/supervisor/conf.d/

CMD supervisord

