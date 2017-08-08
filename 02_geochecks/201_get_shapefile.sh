#!/bin/bash

# download the shape file and extract it

wget http://biogeo.ucdavis.edu/data/gadm2.8/gadm28_levels.shp.zip
unzip gadm28_levels.shp.zip
rm gadm28_levels.shp.zip
mv gadm* shapes/
mv license.txt shapes/