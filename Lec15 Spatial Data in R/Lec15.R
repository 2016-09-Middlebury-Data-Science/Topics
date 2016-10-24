library(rgeos)
library(rgdal)
library(maptools)





library(dplyr)
library(ggplot2)
library(broom)

library(USAboundaries)
library(sp)

states_1840 <- us_states("1840-03-12")
plot(states_1840, axes=TRUE)
title("U.S. state boundaries on March 3, 1840")

# Go to data.gov and download the 2015 State Geodatabase for Vermont ZIP file
# for the census tracts in Vermont then unzip:
# https://catalog.data.gov/dataset/tiger-line-shapefile-2015-state-vermont-current-census-tract-state-based-shapefile
# https://catalog.data.gov/dataset/2015-state-geodatabase-for-vermont



states_shp <- us_states()
states_map <- tidy(states_shp)
states_data <- states_shp@data %>% tibble::rownames_to_column(var="id")
states <- left_join(states_map, states_data, by="id")


# states$name %>% unique() %>% sort() %>% dput()
lower_48 <- c("Alabama", "Arizona", "Arkansas", "California", "Colorado",
  "Connecticut", "Delaware", "District of Columbia", "Florida",
  "Georgia",  "Idaho", "Illinois", "Indiana", "Iowa",
  "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts",
  "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana",
  "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico",
  "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma",
  "Oregon", "Pennsylvania", "Rhode Island", "South Carolina",
  "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia",
  "Washington", "West Virginia", "Wisconsin", "Wyoming")

states <- states %>%
  filter(name %in% lower_48)

ggplot(states, aes(x=long, y=lat, group=group)) +
  geom_path() +
  coord_map()



counties_shp <- us_counties()



counties_map <- tidy(counties_shp, region="geoid")
counties_data <- counties_shp@data

counties <- left_join(counties_map, counties_data, by=c("id"="geoid"))


counties <- counties %>%
  filter(state_name %in% lower_48)

ggplot(counties, aes(x=long, y=lat, group=group)) +
  geom_path() +
  coord_map()

ggplot() +
  geom_path(data=counties, aes(x=long, y=lat, group=group), size=0.1) +
  geom_path(data=states, aes(x=long, y=lat, group=group), size=0.4) +
  coord_map()



ggplot(counties, aes(x=long, y=lat, group=group)) +
  geom_path(size=0.1) +
  coord_map(projection="ortho", orientation = c(10,-80,0))

ggplot() +
  geom_path(data=counties, aes(x=long, y=lat, group=group), size=0.1, col="red") +
  geom_path(data=states, aes(x=long, y=lat, group=group), size=0.4) +
  coord_map(projection="ortho", orientation = c(0,-90,0))











counties <- us_counties()
plot(counties, axes=TRUE)


counties_map <- tidy(counties)
counties_data <- counties@data %>% tbl_df()

counties_map <- left_join(counties_map, counties_data,)



# Loading Shapefiles ------------------------------------------------------

# There are two ways

# 1. Set shapefile_path precisely, including last backslash, then use readOGR
# from rgdal package. Note the layer name is the prefix for all the files
shapefile_path <- "/Users/rudeboybert/Downloads/tl_2015_50_tract/"
map_obj <- readOGR(dsn = shapefile_path, layer = "tl_2015_50_tract")

# 2. Or by setting your current working directory:
# In Files panel, navigate to folder with all the files.
# Click More -> Set As Working Directory.
# Note the "." below is UNIX speak for "current directory"
map_obj <- readOGR(dsn = ".", layer = "tl_2015_50_tract")



# Convert Shapefile to ggplot Data Frame ----------------------------------

# The following bit of code
# -Assigns a unique id to each census tract
# -fortify() and inner_join() to create a ggplot'able data frame. You don't need
#  to understand these functions.
map_obj$id <- rownames(map_obj@data)
map_points <- fortify(map_obj, region="id")
map_df <- inner_join(map_points, map_obj@data, by="id")

# Let's view it
View(map_df)




# Plot --------------------------------------------------------------------

# Each row in the data frame consists of a (longitude, latitude) point in a
# particular polygon, where each polygon corresponds to a census tract. Let's
# trace out the geom_path of the polygons. Recall, geom_path traces out a line.
ggplot(map_df, aes(x=long, y=lat)) +
  labs(x="longitude", y="latitude", title="Vermont Census Tracts") +
  geom_path()

# What a mess! The different polygons are ID'ed by the group variable, so we
# set the group_aesthetic
ggplot(map_df, aes(x=long, y=lat, group=group)) +
  labs(x="longitude", y="latitude", title="Vermont Census Tracts") +
  geom_path()

# Why does Vermont look so fat? b/c the aspect ratio (wikipedia this if you
# don't know what this means) is not reflective of standard maps. So let's set
# the coordinate system to be coord_map:
ggplot(map_df, aes(x=long, y=lat, group=group)) +
  labs(x="longitude", y="latitude", title="Vermont Census Tracts") +
  geom_path() +
  coord_map()

# We can also fill in the polygons
ggplot(map_df, aes(x=long, y=lat, group=group)) +
  labs(x="longitude", y="latitude", title="Vermont Census Tracts") +
  geom_path() +
  coord_map() +
  geom_polygon(fill="dark green")

# What happened to the contour lines? Unfortunately, here the plot order matters.
# Let's plot the geom_polygon first then the geom_path
ggplot(map_df, aes(x=long, y=lat, group=group)) +
  labs(x="longitude", y="latitude", title="Vermont Census Tracts") +
  coord_map() +
  geom_polygon(fill="dark green") +
  geom_path()

# Now let's make a https://en.wikipedia.org/wiki/Choropleth_map using
# one of the variables. We don't seem to have very exciting ones. Let's plot
# AWATER which I'm guessing is Water Area.
# Note: we now set fill to be an aes() based on the variable AWATER, and not the
# constant "dark green"
ggplot(map_df, aes(x=long, y=lat, group=group)) +
  labs(x="longitude", y="latitude", title="Vermont Census Tracts", fill="Water Area") +
  coord_map() +
  geom_polygon(aes(fill=AWATER)) +
  geom_path()

# Not bad. Maybe plotting log10 Area Water is more informative? Your call
ggplot(map_df, aes(x=long, y=lat, group=group)) +
  labs(x="longitude", y="latitude", title="Vermont Census Tracts", fill="Water Area") +
  coord_map() +
  geom_polygon(aes(fill=log10(AWATER))) +
  geom_path()




# Exercise ----------------------------------------------------------------

# Create an account on socialexplorer.com and start figuring out how to download
# census data.
