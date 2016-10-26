library(dplyr)
library(ggplot2)
library(broom)
library(maptools)
library(sp)
library(rgdal)

# Recall: Goal
# A Choropleth Map of Vermont county populations based on 2010 Decennial Census counts.

# After unzipping the .zip file, be sure to either
# -change the file path in the readOGR() call below
# -set the working directory so that this is the relative file path
VT <- rgdal::readOGR("VT_shapefiles/tl_2015_50_tract.shp", layer = "tl_2015_50_tract")

# Plot using base R
plot(VT, axes=TRUE)

# Step 1: Convert VT SpatialPolygonsDataFrame object to tidy data

# Step 2: Get county-level census data for VT

# Step 3: ggplot() it!
