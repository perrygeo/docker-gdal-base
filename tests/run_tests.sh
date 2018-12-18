#!/bin/bash

echo
echo "proj" $(proj 2>&1 | head -n 1)
echo "geos" $(geos-config --version)
gdalinfo --version
gdalinfo --formats | grep OpenJPEG

exit 0
