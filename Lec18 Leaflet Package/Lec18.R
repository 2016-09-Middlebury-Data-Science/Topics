library(dplyr)
library(ggplot2)
library(rgdal)
library(maptools)
library(leaflet)



#-------------------------------------------------------------------------------
# Leaflet Basics
#-------------------------------------------------------------------------------
# Set up the base, just like using the function ggplot(). We see nothing shows 
# up:
m <- leaflet()
m 



#-------------------------------------------------------------------------------
# Layers i.e. Base Maps 
#-------------------------------------------------------------------------------
# More info here: https://rstudio.github.io/leaflet/basemaps.html

# We need to add "layers" i.e. features. The most fundamental one we need to add
# are "tiles", you can think of as a "base map". Kind of like ggplot, but we use
# the piping %>% operator instead of +
m <- leaflet() %>% 
  addTiles()
m

# The default tiling is using OpenStreetMap. You can switch this out to others
# as described in https://rstudio.github.io/leaflet/basemaps.html
# For example http://stamen.com/ is map/data visulization startup in San
# Francisco:
leaflet() %>% 
  addTiles() %>% 
  addProviderTiles("Stamen.Toner")



#-------------------------------------------------------------------------------
# Markers
#-------------------------------------------------------------------------------
# More info here: https://rstudio.github.io/leaflet/markers.html

# The next layer we consider are markers via addMarkers. They call out points on
# the map. Click on the resulting marker to see the popup message:
m <- leaflet() %>%
  addTiles() %>%
  addMarkers(lng=-73.177222, lat=44.008889, popup="Middlebury College")
m

# How did I get the coordinates?
# -I went to the Wikipedia page for Middlebury College 
# -In the righthand panel I clicked on the geographic coordinates under Location
# -I copied the WGS84 coordinates of 44.008889, -73.177222
#
# I could've also taken the (44°00′32″N 73°10′38″W) values and used a lat/long
# degrees to decimal converter, like this one:
# https://www.fcc.gov/media/radio/dms-decimal
# 
# Note: because we are
# -West of the Meridian Line in London, the longitude is negative
# -Above the equator, the latitude is positive

# You can add any number of markers
m <- leaflet() %>%
  addTiles() %>%
  addMarkers(lng=-73.177222, lat=44.008889, popup="Middlebury College") %>% 
  addMarkers(lng=-73.566667, lat=45.5, popup="Montréal")
m

# Or we can add a large number of markers. Show first 20 rows from the `quakes` 
# dataset that comes loaded by default in R
data(quakes)
View(quakes)

# Note the following works because quakes has columns named 
# -`lat` or `latitude`
# -`lng`, `long`, `lng`, or `longitude`
leaflet(data = quakes) %>% 
  addTiles() %>%
  addMarkers(~long, ~lat, popup = ~as.character(mag))



#-------------------------------------------------------------------------------
# Popups
#-------------------------------------------------------------------------------
# More info here: https://rstudio.github.io/leaflet/popups.html

# Popups are like markers, but you can messages. This does requires a little
# knowledge of HTML code:
content <- paste(
  "<b><a href='http://www.middlebury.edu'>Middlebury College</a></b>",
  "14 Old Chapel Rd",
  "Middlebury VT 05753",
  sep = "<br/>"
)
content

leaflet() %>% 
  addTiles() %>%
  addPopups(lng=-73.177222, lat=44.008889, content, options = popupOptions(closeButton = FALSE))



#-------------------------------------------------------------------------------
# Adding Vector Data 
#-------------------------------------------------------------------------------
# More info here: https://rstudio.github.io/leaflet/shapes.html

# Let's use the same shapefile data from Lec16 and read it in. You may or may
# need to change your working directory:
VT <- rgdal::readOGR("VT_shapefiles/tl_2015_50_tract.shp", layer = "tl_2015_50_tract")

# Recall we can view the data attributes that come attached in this shapefile by
# typing
VT@data %>% View()

# To add the VT shapefile, we need to specify it in the leaflet() call
leaflet(VT) %>%
  addTiles()

# Nothing! We need to specify a geom. 
leaflet(VT) %>%
  addTiles() %>% 
  addPolylines()

# Yuck, let's change the color of the lines to black
leaflet(VT) %>%
  addTiles() %>% 
  addPolylines(color="black", weight=1)

# Type ?addPolylines to see the full list of "geoms" and their arguments



#-------------------------------------------------------------------------------
# Exercise 
#-------------------------------------------------------------------------------
# Plot the equivalent of a geom_polygon choropleth where we map ALAND (land
# area) to each of the census tracts. Use the examples in
# https://rstudio.github.io/leaflet/shapes.html as a guide.
#
# Sanity check your ultimate plot by taking a deep breath, closing your eyes,
# and then seeing of the colors match the area sizes.


