library(dplyr)
library(ggplot2)
library(broom)
library(maptools)

library(USAboundaries)
library(sp)



#-------------------------------------------------------------------------------
# Load SpatialPolygons data
#-------------------------------------------------------------------------------
# Let's get the map of US states as is (i.e. no need to specify a date)
states_shp <- us_states()

# Let's plot this using base R plotting
plot(states_shp, axes=TRUE)

# This object is of class SpatialPolygonsDataFrame
states_shp %>% class()

# We look at the polygons stored: 
# Note for SpatialPolygonsDataFrame we access this via @polygons, and not
# $polygons (Don't ask me why, I don't know).
states_shp@polygons
states_shp@polygons %>% length()

# Let's look the contents. Lots of lat/long points
states_shp@polygons[1]



#-------------------------------------------------------------------------------
# Convert to Tidy Data Format
#-------------------------------------------------------------------------------
# 1. We pull the state data associated with each polygon, in this case state.
# Again, note the @data and not $data
states_data <- states_shp@data

# Let's take a closer look. We see that the variable "geoid" is a unique ID'ing
# variable for each polygon, i.e. state
View(states_data)

# 2. The broom::tidy() function automagically converts many different data 
# formats to tidy data format, including SpatialPolygonsDataFrame. We used 
# broom::tidy() earlier to convert logistic regression output to tidy format. 
# For SpatialPolygonsDataFrame objects, we specify the region argument to be
# used to ID each of the polygons
states_polygon <- tidy(states_shp, region="geoid")

# Let's take a closer look. We see that the points defining the polygons are 
# stored in tidy format. We see
# -The "group" associates points to the same polygon
# -The "id" variable is the "geoid" variable in states_data
View(states_polygon)

# 3. So now let's join the polygon data with the state data 
states <- left_join(states_polygon, states_data, by=c("id"="geoid"))

# Let's take a closer look. Same as View(states_polygon), but with the state
# data appended
View(states)

# Let's only consider the lower 48 and DC
states <- states %>%
  filter( !name %in% c("Alaska", "Hawaii", "Puerto Rico"))



#-------------------------------------------------------------------------------
# Plot Tidy Map Data using ggplot
#-------------------------------------------------------------------------------
# Let's make this map!
ggplot(states, aes(x=long, y=lat)) +
  geom_line() 

# For maps, we aren't plotting a line per se, but tracing out a polygon in order
# that the polygons' points are listed. Say hello to geom_path()
ggplot(states, aes(x=long, y=lat)) +
  geom_path() 

# Close, but why the extra lines? Because this isn't a single polygon, but 
# several. So we need to define the group aesthetic to keep points in the same
# polygon together
ggplot(states, aes(x=long, y=lat, group=group)) +
  geom_path() 

# Tada! Now let's get fancy. Let's make the aspect ratio between the x and y
# axes match that of maps by changing the coordinate system to map()
ggplot(states, aes(x=long, y=lat, group=group)) +
  geom_path() +
  coord_map()

# What if we like a spherical projection of the map. (10, -90) define the center
# and the 0 is the rotation angle.
ggplot(states, aes(x=long, y=lat, group=group)) +
  geom_path() +
  coord_map(projection="ortho", orientation = c(10, -90, 0))

# Now let's make a choropleth map
# https://en.wikipedia.org/wiki/Choropleth_map
# i.e. fill in the polygons using land area using the variable aland and a 
# geom_polygon
ggplot(states, aes(x=long, y=lat, group=group, fill=aland)) +
  geom_path() +
  geom_polygon() +
  coord_map()

# Whoops, aland was not numeric:
ggplot(states, aes(x=long, y=lat, group=group, fill=as.numeric(aland))) +
  geom_path() +
  geom_polygon() + 
  coord_map()

# But why can't we see the state boundaries? i.e. the geom_path()? Because the
# geom_polygons are overwriting the geom_paths. So we reverse the order of what
# we plot first
ggplot(states, aes(x=long, y=lat, group=group, fill=as.numeric(aland))) +
  geom_polygon() + 
  geom_path() +
  coord_map()




#-------------------------------------------------------------------------------
# Exercise 1: Plot a map of the county outlines (no fill for now) for all
# ~3000 counties in the US
#-------------------------------------------------------------------------------




#-------------------------------------------------------------------------------
# Exercise 2: Plot a map of both county (red) and state (black) outlines (no
# fill) but with the state outlines clearly visible. Hint: define geom_ specific
# data and aes()
#-------------------------------------------------------------------------------






