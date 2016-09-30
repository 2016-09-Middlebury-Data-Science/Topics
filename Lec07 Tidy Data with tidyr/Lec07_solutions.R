# Load packages
library(dplyr)
library(ggplot2)
library(tidyr)
library(babynames)


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







