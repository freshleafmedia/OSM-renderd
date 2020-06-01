FROM ubuntu:18.04 AS renderd

RUN apt-get update && \
    apt-get install -y git build-essential cmake autoconf libtool apache2-dev libmapnik-dev

RUN curl -L https://github.com/openstreetmap/mod_tile/archive/master.tar.gz | tar -zxvf - && \
    cd mod_tile-master && \
    ./autogen.sh && \
    ./configure && \
    make -j $(nproc) && \
    make -j $(nproc) install && \
    ldconfig



FROM node:14 AS stylesheet

RUN npm install -g carto
RUN curl -L https://github.com/gravitystorm/openstreetmap-carto/archive/v4.23.0.tar.gz | tar -zxf - && \
    mv openstreetmap-carto-4.23.0 openstreetmap-carto

RUN sed -i "/^    type: \"postgis\"/a\    host: \"{{DB_HOSTNAME}}\"" /openstreetmap-carto/project.mml
RUN sed -i "/^    type: \"postgis\"/a\    port: \"{{DB_PORT}}\"" /openstreetmap-carto/project.mml
RUN sed -i "/^    type: \"postgis\"/a\    password: \"{{DB_PASSWORD}}\"" /openstreetmap-carto/project.mml
RUN sed -i "/^    type: \"postgis\"/a\    user: \"{{DB_USER}}\"" /openstreetmap-carto/project.mml

RUN carto /openstreetmap-carto/project.mml -f /mapnik.xml



FROM python:3-buster AS shapefiles

RUN apt-get update && apt-get install -y git mapnik-utils
RUN curl -L https://github.com/gravitystorm/openstreetmap-carto/archive/v4.23.0.tar.gz | tar -zxf - && \
    mv openstreetmap-carto-4.23.0 openstreetmap-carto

RUN python /openstreetmap-carto/scripts/get-shapefiles.py -r -d /data



FROM ubuntu:18.04 AS bin

RUN adduser --disabled-password --gecos "" renderd

RUN apt-get update && \
    apt-get install --no-install-recommends -y libmapnik-dev fonts-noto-cjk fonts-noto-hinted fonts-noto-unhinted ttf-unifont && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

COPY --from=renderd /usr/local/lib /usr/local/lib
COPY --from=renderd /usr/local/bin/renderd /usr/local/bin/renderd

RUN ldconfig

RUN mkdir /etc/renderd
RUN mkdir /tileCache
RUN chown renderd:renderd /etc/renderd /tileCache

USER renderd

COPY --from=stylesheet /mapnik.xml /etc/renderd/mapnik.xml
COPY --from=stylesheet /openstreetmap-carto/symbols /etc/renderd/symbols

COPY --from=shapefiles /data /etc/renderd/data

COPY entrypoint.sh /entrypoint.sh
COPY config.ini /etc/renderd/config.ini

ENTRYPOINT /entrypoint.sh
