# ---------------------------------------------------------------------------#
# gdal-base image with full build deps
# ---------------------------------------------------------------------------#
FROM python:3.6-slim-stretch as builder

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
        cmake build-essential wget ca-certificates unzip pkg-config \
        zlib1g-dev libfreexl-dev libxml2-dev

WORKDIR /tmp

# using gdal master
ENV CPUS 6
ENV CURL_VERSION 7.61.1
ENV GDAL_VERSION 2.4.0
ENV GEOS_VERSION 3.7.1
ENV OPENJPEG_VERSION 2.3.0
ENV PROJ_VERSION 5.2.0
ENV WEBP_VERSION 1.0.0
ENV ZSTD_VERSION 1.3.4
ENV SPATIALITE_VERSION 4.3.0a
ENV SQLITE_VERSION 3250200

RUN wget -q https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-${WEBP_VERSION}.tar.gz
RUN wget -q -O zstd-${ZSTD_VERSION}.tar.gz https://github.com/facebook/zstd/archive/v${ZSTD_VERSION}.tar.gz
RUN wget -q https://download.osgeo.org/geos/geos-${GEOS_VERSION}.tar.bz2
RUN wget -q https://download.osgeo.org/proj/proj-${PROJ_VERSION}.tar.gz
RUN wget -q https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz
RUN wget -q -O openjpeg-${OPENJPEG_VERSION}.tar.gz https://github.com/uclouvain/openjpeg/archive/v${OPENJPEG_VERSION}.tar.gz
# TODO remove RC1
RUN wget -q https://download.osgeo.org/gdal/${GDAL_VERSION}/gdal-${GDAL_VERSION}rc1.tar.gz
RUN wget -q https://www.sqlite.org/2018/sqlite-autoconf-${SQLITE_VERSION}.tar.gz
RUN wget -q https://www.gaia-gis.it/gaia-sins/libspatialite-${SPATIALITE_VERSION}.tar.gz

RUN tar xzf libwebp-${WEBP_VERSION}.tar.gz && \
    cd libwebp-${WEBP_VERSION} && \
    CFLAGS="-O2 -Wl,-S" ./configure && \
    make -j${CPUS} && make install

RUN tar -zxf zstd-${ZSTD_VERSION}.tar.gz \
    && cd zstd-${ZSTD_VERSION} \
    && make -j${CPUS} ZSTD_LEGACY_SUPPORT=0 CFLAGS=-O1 \
    && make install ZSTD_LEGACY_SUPPORT=0 CFLAGS=-O1

RUN tar -xjf geos-${GEOS_VERSION}.tar.bz2 \
    && cd geos-${GEOS_VERSION} \
    && ./configure --prefix=/usr/local \
    && make -j${CPUS} && make install

RUN tar -xzf proj-${PROJ_VERSION}.tar.gz \
    && cd proj-${PROJ_VERSION} \
    && ./configure --prefix=/usr/local \
    && make -j${CPUS} && make install

RUN tar -zxf openjpeg-${OPENJPEG_VERSION}.tar.gz \
    && cd openjpeg-${OPENJPEG_VERSION} \
    && mkdir build && cd build \
    && cmake .. -DBUILD_THIRDPARTY:BOOL=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local \
    && make -j${CPUS} && make install

RUN tar -xzf curl-${CURL_VERSION}.tar.gz && cd curl-${CURL_VERSION} \
    && ./configure --prefix=/usr/local \
    && echo "building CURL ${CURL_VERSION}..." \
    && make --quiet -j${CPUS} && make --quiet install

RUN tar -xzvf sqlite-autoconf-${SQLITE_VERSION}.tar.gz && cd sqlite-autoconf-${SQLITE_VERSION} \
    && ./configure --prefix=/usr/local \
    && echo "building SQLITE ${SQLITE_VERSION}..." \
    && make --quiet -j${CPUS} && make --quiet install

RUN tar -xzvf libspatialite-${SPATIALITE_VERSION}.tar.gz && cd libspatialite-${SPATIALITE_VERSION} \
    && ./configure --prefix=/usr/local \
    && echo "building SPATIALITE ${SPATIALITE_VERSION}..." \
    && make --quiet -j${CPUS} && make --quiet install

# TODO SFCGAL, requires boost libraries
# ENV SFCGAL_VERSION 1.3.0
# RUN wget -q -O sfcgal-${SFCGAL_VERSION}.tar.gz https://github.com/Oslandia/SFCGAL/archive/v${SFCGAL_VERSION}.tar.gz
# RUN tar -xzf sfcgal-${SFCGAL_VERSION}.tar.gz && cd SFCGAL-${SFCGAL_VERSION} \
#       && mkdir build && cd build \
#       && echo "building SFCGAL ${SFCGAL_VERSION}..." \
#       && cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. \
#       && make --quiet -j${CPUS} && make --quiet install

RUN tar -xzf gdal-${GDAL_VERSION}rc1.tar.gz && cd gdal-${GDAL_VERSION} && \
    ./configure \
        --disable-debug \
        --disable-static \
        --prefix=/usr/local \
        --with-curl=/usr/local/bin/curl-config \
        --with-geos \
        --with-geotiff=internal \
        --with-hide-internal-symbols=yes \
        --with-libtiff=internal \
        --with-openjpeg \
        --with-sqlite3 \
        --with-spatialite \
        --with-proj=/usr/local \
        --with-rename-internal-libgeotiff-symbols=yes \
        --with-rename-internal-libtiff-symbols=yes \
        --with-threads=yes \
        --with-webp=/usr/local \
        --with-zstd=/usr/local \
    && echo "building GDAL ${GDAL_VERSION}..." \
    && make --quiet -j${CPUS} && make --quiet install

RUN ldconfig
