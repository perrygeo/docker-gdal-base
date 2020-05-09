# Docker images for geospatial applications

[![Build Status](https://travis-ci.com/perrygeo/docker-gdal-base.svg?branch=master)](https://travis-ci.com/perrygeo/docker-gdal-base)

`docker-gdal-base` is a continuous integration system that

- builds a reliable base image for production geospatial applications in the **GDAL** family.
- relies on the official `debian` images and direct descendants like `python`.
- is built and distributed with the computing resources provided by github, travis-ci and dockerhub.
- uses only free and open source software.
- are up-to-date with recent versions of core libraries, built from source code for full control.
- is optimized for (but not obsessed with) runtime speed and small image size.
- has a reasonably full set of configuration options and drivers.
- is tested regularly, both with an automated test suite and in production systems.
- remain freely available.
- for this base image,
  - leverage caching by using separate `RUN` steps.
  - provide common shared libraries, a full C/C++ build environment, and Python 3.6.
  - install all compiled binaries and libs to `/usr/local`.
- for subsequent production images that inherit from it
  - use multistage builds to minimize the final image size; you don't need carry around the entire build environment in production.

See [`perrygeo/gdal-base` on Dockerhub](https://hub.docker.com/r/perrygeo/gdal-base)

## Packages and version numbers

Dockerfiles are based on [`python:3.6-slim-stretch`](https://github.com/docker-library/python/blob/master/3.6/stretch/slim/Dockerfile) which in turn is based on `debian:stretch-slim`.

The following versions built from source:

```
WEBP_VERSION 1.0.0
ZSTD_VERSION 1.3.4
GEOS_VERSION 3.8.1
SQLITE_VERSION 3270200
LIBTIFF_VERSION 4.1.0
CURL_VERSION 7.61.1
PROJ_VERSION 7.0.1
OPENJPEG_VERSION 2.3.1
GDAL_VERSION 3.1.0
```

## GDAL Drivers

- `GTiff` GeoTIFF with WEBP, ZSTD compression options.
- `JP2OpenJPEG` JPEG-2000 driver based on OpenJPEG library
- see `gdalinfo --formats` for the full list

## Using the image directly

To run the GDAL command line utilities on local files, on data in the current working directory:

```bash
docker run --rm -it \
    --volume $(shell pwd)/:/data \
    perrygeo/gdal-base:latest \
    gdalinfo /data/your.tif
```

You can set it as an alias to save typing

```bash
function with-gdal-base {
    docker run --rm -it --volume $(pwd)/:/data perrygeo/gdal-base:latest "$@"
}

with-gdal-base gdalinfo /data/your.tif
```

## Using the Makefile

- `make` builds the image
- `make test` tests the image
- `make shell` gets you into a bash shell with the current working directory mounted at `/app`

## Extending the image

Use a multistage build to pull your binaries and shared library objects in `/usr/local` onto a fresh image.

Example:

```Dockerfile
FROM perrygeo/gdal-base:latest as builder

# Python dependencies that require compilation
COPY requirements.txt .
RUN python -m pip install cython numpy -c requirements.txt
RUN python -m pip install --no-binary fiona,rasterio,shapely -r requirements.txt
RUN pip uninstall cython --yes

# ------ Second stage
# Start from a clean image
FROM python:3.6-slim-stretch as final

# Install some required runtime libraries from apt
RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        libfreexl1 libxml2 \
    && rm -rf /var/lib/apt/lists/*

# Install the previously-built shared libaries from the builder image
COPY --from=builder /usr/local /usr/local
RUN ldconfig
```

## License

Docker image licensing [is a mess](https://opensource.stackexchange.com/a/7015).
In lieu of clear best practices, I'm making the source code and the associated images on dockerhub
available as **public domain**.

There is no warranty of any kind.
You're on your own if you choose to use any of these resources.
If the images work for you, great!
Please `docker pull` it, fork it, `git clone` it, download it, whatever.
Thanks to github, travis-ci and dockerhub
for donating the computing resources to support open source projects such as this.

## Contributing

Ideas for additional drivers or software? Bug fixes? Please create a pull request on this repo with:

- a description.
- code + an automated test for the new functionality.
- results of trying it in production.

If your proposal is aligned with the project's goals, I'll gladly consider it!
