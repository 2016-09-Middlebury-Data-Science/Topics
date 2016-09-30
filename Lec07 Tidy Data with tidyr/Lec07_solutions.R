# Load packages
library(dplyr)
library(ggplot2)
library(tidyr)
library(readr)
library(babynames)
library(stringr)


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
census <- read.csv("./Lec07 Tidy Data with tidyr/popdensity1990_00_10.csv")

# Note there needs to be a space
census <-
  separate(census, QName, c("county_name", "state_name"), sep=", ", remove=FALSE)
select(census, county_name, state_name) %>%
  head()





# Q2: Create a new variable FIPS_code that follows the federal standard:
# https://www.policymap.com/wp-content/uploads/2012/08/FIPSCode_Part4.png
# As a sanity check, ensure that the county with FIPS code "08031" is Denver
# County, Colorado.  Hint: the stringr::str_pad() command might
# come in handy

# We can't treat STATE and COUNTY as numerical variables, b/c we need the single
# digit ID's, like Alabama having STATE code 1.  Rather we treat them as
# character strings "padded with 0's".  Then we use the unite() command.
census <- census %>%
  mutate(
    state_code = str_pad(STATE, 2, pad="0"),
    county_code = str_pad(COUNTY, 3, pad="0")
  )
census <- unite(census, "FIPS_code", state_code, county_code, sep = "")

# Denver county has STATE code 8 and COUNTY code 31, but we see we've correctly
# padded them with 0's.
filter(census, FIPS_code=="08031")





# Q3: Plot histograms of the population per county, where we have the
# histograms facetted by year (1990, 2000, 2010).

# For ggplot to work cleanly, we need to first convert the data into
# tidy format.  We create a new data frame consisting of county_name,
# state_name, FIPS_code, and total population and gather() it in long format
# "keyed" by year.
totalpop <- census %>%
  select(county_name, state_name, contains("totalpop"))

totalpop <- totalpop %>%
  gather("year", totalpop, contains("totalpop")) %>%
  mutate(year=factor(year, labels=c("1990", "2000", "2010")))

# Now that we have a keying variable "year", we can easily facet this plot
ggplot(totalpop, aes(x=totalpop, y=)) +
  geom_histogram() +
  facet_wrap(~year) +
  scale_x_log10() +
  xlab("County population (log-scale)") +
  ggtitle("County populations for different years")





# Q4: The most popular male and female names in the 1890's were John and Mary.
# Present the proportion for all males named John and all females named Mary
# (some males were recorded as females, for example) for each of the 10 years in
# the 1890's in wide format.  i.e. your table should have two rows, and 11
# columns: name and the one for each year

# We remove the "n" and "sex" variable to keep the table looking clean.
babynames %>%
  filter(
    (name=="Mary" & sex=="F") | (name=="John" & sex=="M"),
    year >=1880 & year <= 1889
  ) %>%
  select(-n, -sex) %>%
  spread(year, prop)






