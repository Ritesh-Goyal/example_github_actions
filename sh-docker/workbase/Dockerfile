#--------------------------------------------------------------------------
# Image Setup
#--------------------------------------------------------------------------

FROM php:8.0-cli

# Set Environment Variables
ENV DEBIAN_FRONTEND noninteractive

#--------------------------------------------------------------------------
# Software's Installation
#--------------------------------------------------------------------------

RUN set -eux; \
    apt-get update -y; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends \
            curl \
            libmemcached-dev \
            libz-dev \
            libpq-dev \
            libjpeg-dev \
            libpng-dev \
            libfreetype6-dev \
            libssl-dev \
            libwebp-dev \
            libmcrypt-dev \
            libonig-dev;

# Add a non-root user to prevent files being created with root permissions on host machine.
ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}

RUN groupadd -g ${PGID} laradock && \
    useradd -l -u ${PUID} -g laradock -m laradock && \
    usermod -p "*" laradock -s /bin/bash

# Install PHP libraries
RUN set -eux; \
    # Install the PHP pdo_mysql extention
    docker-php-ext-install pdo_mysql; \
    # Install the PHP gd library
    docker-php-ext-configure gd \
            --prefix=/usr \
            --with-jpeg \
            --with-webp \
            --with-freetype; \
    docker-php-ext-install gd; \
    php -r 'var_dump(gd_info());'

# Update pecl and utilities
RUN set -xe && \
    pecl channel-update pecl.php.net && \
    apt-get install -yqq \
      sudo \
      wget \
      apt-utils \
      #
      #--------------------------------------------------------------------------
      # Mandatory Software's Installation
      #--------------------------------------------------------------------------
      #
      # Mandatory Software's such as ("mcrypt", "pdo_mysql", "libssl-dev", ....)
      # are installed on the base image 'laradock/php-fpm' image. If you want
      # to add more Software's or remove existing one, you need to edit the
      # base image (https://github.com/Laradock/php-fpm).
      #
      # next lines are here becase there is no auto build on dockerhub see https://github.com/laradock/laradock/pull/1903#issuecomment-463142846
      libzip-dev zip unzip && \
      # Install the zip extension
      docker-php-ext-install zip && \
      php -m | grep -q 'zip'

# Install pcntl used to administer job timeouts
RUN docker-php-ext-configure pcntl --enable-pcntl && \
    docker-php-ext-install pcntl

# Install the PHP mcrypt extention
RUN pecl install mcrypt-snapshot
RUN docker-php-ext-enable mcrypt

# Install the phpredis extension
RUN pecl install redis
RUN docker-php-ext-enable redis

###########################################################################
# Install pdf library wkhtmltox and dependencies
###########################################################################
RUN apt-get install -yqq \
    fontconfig \
    libx11-6 \
    libxcb1 \
    libxext6 \
    libxrender1 \
    xfonts-75dpi \
    xfonts-base

#COPY build/getarch.sh /tmp/getarch.sh
COPY build /tmp
#RUN chmod +x /tmp/getarch.sh
#RUN /tmp/getarch.sh

#RUN apt-get install -yqq \
#    wkhtmltopdf

RUN ls -lrt /tmp

# Install datadog agent
RUN curl -LO "https://github.com/DataDog/dd-trace-php/releases/latest/download/datadog-setup.php" && \
    php datadog-setup.php --php-bin=all --enable-appsec 

# Install python
RUN apt-get -y install python3 python3-dev build-essential  \
  && curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py  \
  && python3 get-pip.py  \
  && rm get-pip.py  \
  && python3 -m pip install --upgrade --force-reinstall pip  \
  && python3 -m pip install --upgrade virtualenv

#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------

# Adding the faketime library to the preload file needs to be done last
# otherwise it will preload it for all commands that follow in this file
RUN if [ ${INSTALL_FAKETIME} = true ]; then \
    echo "/usr/lib/x86_64-linux-gnu/faketime/libfaketime.so.1" > /etc/ld.so.preload \
;fi

# Configure locale.
ARG LOCALE=POSIX
ENV LC_ALL ${LOCALE}

#####################################
# Set Timezone
#####################################

ARG TZ=UTC
ENV TZ ${TZ}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install composer
RUN cd /tmp && \
    curl -sS https://getcomposer.org/installer -o composer-setup.php && \
    php composer-setup.php --force --install-dir=/usr/local/bin --filename=composer
