FROM perrygeo/gdal-base:latest as builder

# Python dependencies that require compilation
RUN python -m pip install cython numpy
RUN python -m pip install --no-binary rasterio "rasterio==1.0.13"
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
