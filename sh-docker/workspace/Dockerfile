#
#--------------------------------------------------------------------------
# Image Setup
#--------------------------------------------------------------------------
#

FROM 870130602327.dkr.ecr.us-east-1.amazonaws.com/workbase:latest AS workbase

# Copy PHP ini
COPY build/etc/php/php.ini /usr/local/etc/php/

COPY build/etc/php/laravel.ini /usr/local/etc/php/conf.d

COPY build/composer.json /home/laradock/.composer/composer.json

#
#--------------------------------------------------------------------------
# Workspace container
#--------------------------------------------------------------------------
#
FROM workbase AS workspace

######################################
## xDebug:
######################################

ARG INSTALL_XDEBUG=false

RUN if [ ${INSTALL_XDEBUG} = true ]; then \
    # Install the xdebug extension
    pecl install xdebug && \
    docker-php-ext-enable xdebug && \
    echo "alias phpunit='php /sh-root/sh-www/sh-api/vendor/bin/phpunit'" >> /root/.bashrc && \
    echo "alias phpunit='php /sh-root/sh-www/sh-api/vendor/bin/phpunit'" >> /home/laradock/.bashrc \
;fi

COPY build/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# Install ping
RUN apt-get update -yqq && \
    apt-get -y install inetutils-ping

# Install node
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs && \
    apt-get clean

# Install sentry cli for builds
ARG INSTALL_SENTRY_CLI=false
RUN if [ ${INSTALL_SENTRY_CLI} = true ]; then \
    npm install -g @sentry/cli --unsafe-perm \
;fi

RUN echo "" >> ~/.bashrc && \
    echo 'export PATH="/var/www/vendor/bin:$PATH"' >> ~/.bashrc

# Clean up
# Apparently a kernel error prevents rm -rf from removing non-empty directories at the moment
# RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

# Set default work directory
WORKDIR /sh-root/sh-www

#
#--------------------------------------------------------------------------
# Workers container
#--------------------------------------------------------------------------
#
FROM workbase AS workers

# Install Supervisor
RUN apt-get install -y --allow-downgrades --allow-remove-essential --allow-change-held-packages supervisor

# Touch scheduler log file
RUN touch /var/log/cron-run.log
RUN chown laradock:laradock /var/log/cron-run.log

# Set default work directory
WORKDIR /etc/supervisor/conf.d/

# Copy supervisor config
COPY build/etc/supervisord.conf /etc/supervisord.conf

ARG WORKERS_ENABLED=false
COPY build/etc/supervisor/conf.d /tmp/supervisor/conf.d
RUN if [ ${WORKERS_ENABLED} = true ]; then \
    cp -p /tmp/supervisor/conf.d/* /etc/supervisor/conf.d/ \
;fi

# Setup logrotate
RUN apt-get install -y logrotate
COPY build/etc/logrotate.d/storyhunter /etc/logrotate.d/storyhunter
RUN mkdir -p /etc/cron.hourly && \
    mv /etc/cron.daily/logrotate /etc/cron.hourly/logrotate

# Clean up
# Apparently a kernel error prevents rm -rf from removing non-empty directories at the moment
# RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c",  "/etc/supervisord.conf"]
