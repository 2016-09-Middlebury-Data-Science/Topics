# Load packages
library(dplyr)
library(ggplot2)
library(rvest)


#------------------------------------------------------------------------------
# Solutions to Exercises from Lec03.R
#------------------------------------------------------------------------------
# Before going over the solutions, let's reload the wp_data:
# -Re-run lines 23-55 from Lec03.R to load the wp_data
# -Load the states.csv as instructed at the end of Lec03

# Q1. Which region (south, NE, west, or midwest) has the highest proportion of
# its colleges being private?  (This is a tricky one!)

# We first join using left_join? Why left_join? Because in this case we don't
# want a lot of missing values that could arrive from full_join() for example,
# we only care about matching information that exists in wp_data.
wp_data <- left_join(wp_data, states, by=c("state"="state_abbrev"))

# First we get the # of schools per region i.e. the denominator
# Note we use the tally() command to count. What do you think is causing the
# missing values?
num_per_region <- wp_data %>%
  group_by(region) %>%
  tally() %>%
  rename(num_in_region = n)
num_per_region

# Next we get the # of schools per region AND per section i.e. the numerator.
# So here we group_by() region AND sector
num_per_region_sector <- wp_data %>%
  group_by(region, sector) %>%
  tally() %>%
  rename(num_in_region_and_sector = n)
num_per_region_sector

# Lastly we join the two datasets and compute the proportion. It appears the NE
# has the highest proportion of private schools.
left_join(num_per_region_sector, num_per_region, by="region") %>%
  mutate(prop = round(num_in_region_and_sector/num_in_region,3))



# Q2. For each region, compute the values necessary to draw a whisker-less boxplot
#  of the annual tuition fees.

# The box portion of a boxplot consists of the 3 quartiles. We group_by region
# only in this case, and summarise() using the quantile() and median() functions
group_by(wp_data, region) %>%
  summarise(
    first_quart = quantile(comp_fee, 0.25),
    median = median(comp_fee),
    third_quart = quantile(comp_fee, 0.75)
  )





#------------------------------------------------------------------------------
# ggplot exploration
#------------------------------------------------------------------------------
# We will consider the diamonds data set
data(diamonds)
head(diamonds)
?diamonds
n <- nrow(diamonds)
n

# Since the diamonds data set is too big, let's only consider a randomly chosen
# sample of 500 of these points
diamonds <- dplyr::sample_n(diamonds, size = 500)


# We build up the plot incrementally from the base:
# -data: is the data considered
# -aes() is the function that maps variables to aesthetics
ggplot(data=diamonds, aes(x = carat, y = price))

# Nothing shows. We need a geometry: points.  We add it with a + sign
ggplot(data=diamonds, aes(x = carat, y = price)) +
  geom_point()

# Look at the help file for geom_point(), in particular the aesthetics it
# understands
?geom_point

# The default value (i.e. if you don't set it to anything) for the "color"
# aesthetic is black.  Let's map the "cut" variable to color
ggplot(data=diamonds, aes(x = carat, y = price, colour = cut)) +
  geom_point()

# scale: put the y-axis on a log-scale
ggplot(data=diamonds, aes(x = carat, y = price, colour = cut)) +
  geom_point() +
  scale_y_log10()

# facet: break down the plot by cut
ggplot(data=diamonds, aes(x = carat, y = price, colour = cut)) +
  geom_point() +
  scale_y_log10() +
  facet_wrap(~cut, nrow=2)

# extra: add title
ggplot(data=diamonds, aes(x = carat, y = price, colour = cut)) +
  geom_point() +
  scale_y_log10() +
  facet_wrap(~cut, nrow=2) +
  ggtitle("First example")

# Note all the above could've been added incrementally to a variable
p <- ggplot(data=diamonds, aes(x = carat, y = price, colour = cut))
p <- p + geom_point()
p <- p + scale_y_log10()
p <- p + facet_wrap(~cut, nrow=2)
p <- p + ggtitle("First example")
p





#------------------------------------------------------------------------------
# EXERCISE
#------------------------------------------------------------------------------
# Q1.  Create a plot that shows once again the relationship between
# carat/price/cut, but now let the size of the points reflect the table of the
# diamond and have separate plots by clarity

# Q2. A friend wants to know if cars in 1973-1974 that have bigger
# cylinders (the variable displacement in cu. in.) have better mileage (in mpg).
# Two important factors they want to consider are the # of cylinders and whether
# the car has an automatic or manual transmission.  Answer your friend's
# question using a visualization. As added bonus, use google to add detailed
# x-labels and y-labels
data(mtcars)
?mtcars




