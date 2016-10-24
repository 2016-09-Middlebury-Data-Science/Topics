library(dplyr)
library(ggplot2)
library(broom)
library(maptools)
library(USAboundaries)
library(sp)



#-------------------------------------------------------------------------------
# Get states map
#-------------------------------------------------------------------------------
# Get states SpatialPolygonsDataFrame object from USAboundaires
states_shp <- us_states()
# Get states data
states_data <- states_shp@data
# Get states polygon data and convert to tidy data format
states_polygon <- tidy(states_shp, region="geoid")
# Join states data and polygons into a single tidy data frame
states <- left_join(states_polygon, states_data, by=c("id"="geoid"))
# Let's only consider the lower 48 and DC
states <- states %>%
  filter( !name %in% c("Alaska", "Hawaii", "Puerto Rico"))



#-------------------------------------------------------------------------------
# Get counties map
#-------------------------------------------------------------------------------
counties_shp <- us_counties()
counties_data <- counties_shp@data
counties_polygon <- tidy(counties_shp, region="geoid")
counties <- left_join(counties_polygon, counties_data, by=c("id"="geoid"))
counties <- counties %>%
  filter(!state_name %in% c("Alaska", "Hawaii", "Puerto Rico"))



#-------------------------------------------------------------------------------
# Plot both, where each geom_path() has it's own data and aes(x=long, y=lat,
# group=group).
# We can't forget the group aesthetic as this is what keeps different polygons
# separate from each other.
# Note also, we plot the states with a thicker outline AFTER we plot the
# counties
#-------------------------------------------------------------------------------
ggplot() +
  geom_path(data=counties, aes(x=long, y=lat, group=group), size=0.1, col="red") +
  geom_path(data=states, aes(x=long, y=lat, group=group), size=0.4) +
  coord_map()


