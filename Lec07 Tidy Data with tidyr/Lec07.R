# Load packages
library(dplyr)
library(ggplot2)
library(tidyr)
library(babynames)



#------------------------------------------------------------------------------
# tidy Data
#------------------------------------------------------------------------------
# We create 3 new data frames. pollution, cases, storms:
pollution <- data_frame(
  city = c("New York", "New York", "London", "London", "Beijing", "Beijing"),
  size = c("large", "small", "large", "small", "large", "small"),
  amount = c(23, 14, 22, 16, 121, 56)
  )

cases <- data_frame(
  country = c("FR", "DE", "US"),
  "2011" = c(7000, 5800, 15000),
  "2012" = c(6900, 6000, 14000),
  "2013" = c(7000, 6200, 13000)
)

storms <- data_frame(
  storm = c("Alberto", "Alex", "Allison", "Ana", "Arlene", "Arthur"),
  wind = c(110, 45, 65, 40, 50, 45),
  pressure = c(1007, 1009, 1005, 1013, 1010, 1010),
  date = as.Date(c("2000-08-03", "1998-07-27", "1995-06-03", "1997-06-30", "1999-06-11",
           "1996-06-17"))
)


# Look at their structure
pollution
cases
storms



#---------------------------------------------------------------
# Going from tidy (AKA narrow AKA tall) format to wide format and vice versa
# using gather() and separate()
#---------------------------------------------------------------
# Convert to tidy format i.e. gather them to tidy.
# All three of the following do the same:
# 1. set the new "key" variable that distinguishes the rows to be called year
# 2. set the new "value" variable in each of the rows to be called n
# 3. set the values to be from the 2nd thru 4th columns. This is done in three ways
cases
gather(data=cases, key=year, value=n, 2:4)
gather(data=cases, key=year, value=n, `2011`, `2012`, `2013`)
gather(data=cases, key=year, value=n, -country)

# Convert to wide format i.e. spread them out to wide format.
# 1. The "key" variable from tidy format to be spread across the rows is size
# 2. The "value" variable are the values in each row to spread out wide
# 3. In this case the city variable gets collapsed
pollution
spread(data=pollution, key=size, value=amount)

# Note: gather() and spread() are opposites of each other
cases
gather(cases, "year", n, -country) %>% spread(year, n)

# Note: I really have a hard time memorizing this. I usually refer to the cheatsheet
# but more often the help file examples on at the bottom of:
?gather



#---------------------------------------------------------------
# separate() and unite() columns
#---------------------------------------------------------------
# Separate the year, month, day from the date variable":
storms
storms2 <- separate(storms, date, c("year", "month", "day"), sep = "-")
storms2

# Undo the last change using unite()
unite(storms2, "date", year, month, day, sep = "-")



#-------------------------------------------------------------------------------
# EXERCISES
#-------------------------------------------------------------------------------
# From a previous version of this class: popdensity1990_00_10.csv
# Census data from 1990 with total population, land area, and population density
# in wide format.

# There are many ways to read in a CSV in RStudio
# 1. Using base R's read.csv()
# 1. Using readr::read_csv(). More intuitive default settings and much quicker
# 1. Using RStudio's Graphical User Interface (GUI):
#   -In the File panel, navigate to the file: popdensity1990_00_10.csv
#   -Click it and select "Import Dataset..."
#   -Under "Import Options" in the bottom left, name the data frame "census" and Import
#   -The data will load AND you'll get the command that loads it in your console for
#    future use


# Q1: Add varibles "county_name" and "state_name" to the census data
# frame, which are derived from the variable "QName".  Do this in a manner that
# keeps the variable "QName" in the data frame.


# Q2: Create a new variable FIPS_code that follows the federal standard:
# http://www.policymap.com/blog/wp-content/uploads/2012/08/FIPSCode_Part4.png
# As a sanity check, ensure that the county with FIPS code "08031" is Denver
# County, Colorado.  Hint: the stringr::str_pad() command might
# come in handy


# Q3: Plot histograms of the population per county, where we have the
# histograms facetted by year (1990, 2000, 2010).


# Now consider the babynames data set again which is in tidy format.  For
# example, consider the top male names from the 1880's:
babynames
filter(babynames, year >=1880 & year <= 1889, sex=="M") %>%
  group_by(name) %>%
  summarize(n=sum(n)) %>%
  ungroup() %>%
  arrange(desc(n))


# Q4: The most popular male and female names in the 1890's were John and Mary.
# Present the proportion for all males named John and all females named Mary
# (some males were recorded as females, for example) for each of the 10 years in
# the 1890's in wide format.  i.e. your table should have two rows, and 11
# columns: name and the one for each year







