#!/bin/bash

sed -i "s/{{DB_HOSTNAME}}/${DB_HOSTNAME:-localhost}/" /etc/renderd/mapnik.xml
sed -i "s/{{DB_PORT}}/ ${DB_PORT:-5432}/" /etc/renderd/mapnik.xml
sed -i "s/{{DB_USER}}/${DB_USER:-renderer}/" /etc/renderd/mapnik.xml
sed -i "s/{{DB_PASSWORD}}/${DB_PASSWORD}/" /etc/renderd/mapnik.xml

renderd -f -c /etc/renderd/config.ini
