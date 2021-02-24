#----------------------------------- #
# gdal-base image with full build deps
# github: perrygeo/docker-gdal-base
# docker: perrygeo/gdal-base
#----------------------------------- #
FROM python:3.8-slim-buster as builder

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    cmake build-essential wget ca-certificates unzip pkg-config \
    zlib1g-dev libfreexl-dev libxml2-dev nasm libpng-dev

WORKDIR /tmp

ENV CPUS 2

ENV WEBP_VERSION 1.0.0
RUN wget -q https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-${WEBP_VERSION}.tar.gz && \
    tar xzf libwebp-${WEBP_VERSION}.tar.gz && \
    cd libwebp-${WEBP_VERSION} && \
    CFLAGS="-O2 -Wl,-S" ./configure --enable-silent-rules && \
    echo "building WEBP ${WEBP_VERSION}..." \
    make --quiet -j${CPUS} && make --quiet install

ENV ZSTD_VERSION 1.3.4
RUN wget -q -O zstd-${ZSTD_VERSION}.tar.gz https://github.com/facebook/zstd/archive/v${ZSTD_VERSION}.tar.gz \
    && tar -zxf zstd-${ZSTD_VERSION}.tar.gz \
    && cd zstd-${ZSTD_VERSION} \
    && echo "building ZSTD ${ZSTD_VERSION}..." \
    && make --quiet -j${CPUS} ZSTD_LEGACY_SUPPORT=0 CFLAGS=-O1 \
    && make --quiet install ZSTD_LEGACY_SUPPORT=0 CFLAGS=-O1

ENV LIBDEFLATE_VERSION 1.7
RUN wget -q https://github.com/ebiggers/libdeflate/archive/v${LIBDEFLATE_VERSION}.tar.gz \
    && tar -zxf v${LIBDEFLATE_VERSION}.tar.gz \
    && cd libdeflate-${LIBDEFLATE_VERSION} \
    && echo "building libdeflate ${LIBDEFLATE_VERSION}..." \
    && make -j${CPUS} \
    && make --quiet install

ENV LIBJPEG_TURBO_VERSION 2.0.5
RUN wget -q https://github.com/libjpeg-turbo/libjpeg-turbo/archive/${LIBJPEG_TURBO_VERSION}.tar.gz \
    && tar -zxf ${LIBJPEG_TURBO_VERSION}.tar.gz \
    && cd libjpeg-turbo-${LIBJPEG_TURBO_VERSION} \
    && echo "building libjpeg-turbo ${LIBJPEG_TURBO_VERSION}..." \
    && cmake -G"Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=Release . \
    && make -j${CPUS} \
    && make --quiet install

ENV GEOS_VERSION 3.9.1
RUN wget -q https://download.osgeo.org/geos/geos-${GEOS_VERSION}.tar.bz2 \
    && tar -xjf geos-${GEOS_VERSION}.tar.bz2  \
    && cd geos-${GEOS_VERSION} \
    && ./configure --prefix=/usr/local \
    && echo "building geos ${GEOS_VERSION}..." \
    && make --quiet -j${CPUS} && make --quiet install

ENV SQLITE_VERSION 3330000
ENV SQLITE_YEAR 2020
RUN wget -q https://sqlite.org/${SQLITE_YEAR}/sqlite-autoconf-${SQLITE_VERSION}.tar.gz \
    && tar -xzf sqlite-autoconf-${SQLITE_VERSION}.tar.gz && cd sqlite-autoconf-${SQLITE_VERSION} \
    && ./configure --prefix=/usr/local \
    && echo "building SQLITE ${SQLITE_VERSION}..." \
    && make --quiet -j${CPUS} && make --quiet install

ENV LIBTIFF_VERSION=4.2.0
RUN wget -q https://download.osgeo.org/libtiff/tiff-${LIBTIFF_VERSION}.tar.gz \
    && tar -xzf tiff-${LIBTIFF_VERSION}.tar.gz \
    && cd tiff-${LIBTIFF_VERSION} \
    && ./configure --prefix=/usr/local \
    && echo "building libtiff ${LIBTIFF_VERSION}..." \
    && make --quiet -j${CPUS} && make --quiet install

ENV NGHTTP2_VERSION 1.42.0
RUN wget https://github.com/nghttp2/nghttp2/releases/download/v${NGHTTP2_VERSION}/nghttp2-${NGHTTP2_VERSION}.tar.gz \
    && tar -xzf nghttp2-${NGHTTP2_VERSION}.tar.gz \
    && cd nghttp2-${NGHTTP2_VERSION} \
    && echo "building NGHTTP2 ${NGHTTP2_VERSION}..." \
    && ./configure --enable-lib-only --prefix=/usr/local \
    && make --quiet -j${CPUS} && make --quiet install

ENV CURL_VERSION 7.73.0
RUN wget -q https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz \
    && tar -xzf curl-${CURL_VERSION}.tar.gz && cd curl-${CURL_VERSION} \
    && ./configure --prefix=/usr/local \
    && echo "building CURL ${CURL_VERSION}..." \
    && make --quiet -j${CPUS} && make --quiet install

ENV PROJ_VERSION 7.2.1
RUN wget -q https://download.osgeo.org/proj/proj-${PROJ_VERSION}.tar.gz \
    && tar -xzf proj-${PROJ_VERSION}.tar.gz \
    && cd proj-${PROJ_VERSION} \
    && ./configure --prefix=/usr/local \
    && echo "building proj ${PROJ_VERSION}..." \
    && make --quiet -j${CPUS} && make --quiet install

ENV LIBGEOTIFF_VERSION=1.6.0
RUN wget -q https://github.com/OSGeo/libgeotiff/releases/download/${LIBGEOTIFF_VERSION}/libgeotiff-${LIBGEOTIFF_VERSION}.tar.gz \
    && tar -xzf libgeotiff-${LIBGEOTIFF_VERSION}.tar.gz \
    && cd libgeotiff-${LIBGEOTIFF_VERSION} \
    && ./configure --prefix=/usr/local --with-zlib \
    && echo "building libgeotiff ${LIBGEOTIFF_VERSION}..." \
    && make --quiet -j${CPUS} && make --quiet install

# ENV SPATIALITE_VERSION 5.0.0
# RUN wget -q https://www.gaia-gis.it/gaia-sins/libspatialite-${SPATIALITE_VERSION}.tar.gz
# RUN apt-get install -y libminizip-dev
# RUN tar -xzvf libspatialite-${SPATIALITE_VERSION}.tar.gz && cd libspatialite-${SPATIALITE_VERSION} \
#     && ./configure --prefix=/usr/local \
#     && echo "building SPATIALITE ${SPATIALITE_VERSION}..." \
#     && make --quiet -j${CPUS} && make --quiet install

ENV OPENJPEG_VERSION 2.3.1
RUN wget -q -O openjpeg-${OPENJPEG_VERSION}.tar.gz https://github.com/uclouvain/openjpeg/archive/v${OPENJPEG_VERSION}.tar.gz \
    && tar -zxf openjpeg-${OPENJPEG_VERSION}.tar.gz \
    && cd openjpeg-${OPENJPEG_VERSION} \
    && mkdir build && cd build \
    && cmake .. -DBUILD_THIRDPARTY:BOOL=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local \
    && echo "building openjpeg ${OPENJPEG_VERSION}..." \
    && make --quiet -j${CPUS} && make --quiet install

ENV GDAL_SHORT_VERSION 3.2.1
ENV GDAL_VERSION 3.2.1
RUN wget -q https://download.osgeo.org/gdal/${GDAL_SHORT_VERSION}/gdal-${GDAL_VERSION}.tar.gz
RUN tar -xzf gdal-${GDAL_VERSION}.tar.gz && cd gdal-${GDAL_SHORT_VERSION} && \
    ./configure \
    --disable-debug \
    --prefix=/usr/local \
    --disable-static \
    --with-curl=/usr/local/bin/curl-config \
    --with-geos \
    --with-geotiff=/usr/local \
    --with-hide-internal-symbols=yes \
    --with-libtiff=/usr/local \
    --with-jpeg=/usr/local \
    --with-png \
    --with-openjpeg \
    --with-sqlite3 \
    --with-proj=/usr/local \
    --with-rename-internal-libgeotiff-symbols=yes \
    --with-rename-internal-libtiff-symbols=yes \
    --with-threads=yes \
    --with-webp=/usr/local \
    --with-zstd=/usr/local \
    --with-libdeflate \
    && echo "building GDAL ${GDAL_VERSION}..." \
    && make -j${CPUS} && make --quiet install

RUN ldconfig

# https://proj.org/usage/environmentvars.html#envvar-PROJ_NETWORK
ENV PROJ_NETWORK ON
