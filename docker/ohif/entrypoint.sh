#!/bin/bash

if [ -n "${PORT}" ]
  then
    echo "Changing port to ${PORT}..."
    sed -i -e "s/listen 80/listen ${PORT}/g" /etc/nginx/conf.d/default.conf
fi

if [ -d "/usr/share/nginx/html/config" ]
  then
    echo "Copying externally provided config..."
    cp /usr/share/nginx/html/config/app-config.js /usr/share/nginx/html/app-config.js
fi

echo "Starting Nginx to serve the OHIF Viewer..."

exec "$@"