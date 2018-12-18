#!/bin/bash

python --version
echo "rasterio" $(python -c "import rasterio; print(rasterio.__version__)")

exit 0
