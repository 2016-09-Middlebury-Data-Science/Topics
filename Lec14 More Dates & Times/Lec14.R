library(tidyverse)
library(lubridate)
library(Quandl)




#-------------------------------------------------------------------------------
# Solutions to Lec13.R Exercises
#-------------------------------------------------------------------------------
# Reload bitcoin
bitcoin <- Quandl("BAVERAGE/USD") %>%
  tbl_df() %>%
  rename(
    Avg = `24h Average`,
    Total_Volume = `Total Volume`
  )

# EXERCISE Q1: As it is, the dates in the bitcoin data are already dates. How
# do we know? The variable type is listed.
glimpse(bitcoin)
# Plot a time series of the avg price of bitcoins relative to USD vs date.  What
# is the overall trend?

# SOLUTION Q1:
# Roller coaster!
ggplot(data=bitcoin, aes(x=Date, y=Avg)) +
  geom_line()



# EXERCISE Q2: Create a new variable day_of_week in the bitcoin data which
# specifies the day of week and compute the mean trading value split by day of
# week.  Which day of the week is there on average the most trading of bitcoins?

# SOLUTION Q2:
bitcoin %>%
  mutate(day_of_week = wday(Date, label = TRUE, abbr=FALSE)) %>%
  group_by(day_of_week) %>%
  summarise(`Avg Volume` = mean(Total_Volume))

# Better yet, a boxplot!
p <- bitcoin %>%
  mutate(day_of_week = wday(Date, label = TRUE, abbr=FALSE)) %>%
  ggplot(aes(x=day_of_week, y=Total_Volume)) +
  geom_boxplot()
p

# CRUCIAL:
# Note the difference, as indicated on the back of your ggplot cheatsheat, bottom
# right, Zooming:

# With point clipping. i.e. ylim IGNORES all points greater than 10^5
p + ylim(c(0,10^5))

# Without point clipping i.e. it only zooms in, so the boxplot is different!
p + coord_cartesian(ylim=c(0,10^5))



# EXERCISE Q3: Convert the following to POSIX format. Tricky!
x <- "Sunday 06-05-2016 2:15:04 PM" # June 5th, 2016

# SOLUTION Q3:
parse_date_time(x, "A m d Y IMS p")







#-------------------------------------------------------------------------------
# Time Zones
#-------------------------------------------------------------------------------
# This list all time zones:
OlsonNames()

# Hadley Wickham is from New Zealand, so he sets a Skype/FaceTime/Google Hangout
# meeting on NZ time, but doesn't tell you what time that is here!
meeting <- ymd_hms("2011-07-01 09:00:00", tz = "Pacific/Auckland")

# What time is this here?
with_tz(meeting, "America/New_York")

# Let's change the time zone to ours permanently
meeting <- force_tz(meeting, "America/New_York")
meeting

# Notice POSIX dates/times auto-adjusts for Daylight savings
ymd_hms("2016-11-06 00:59:59", tz = "America/New_York")
ymd_hms("2016-11-06 02:00:00", tz = "America/New_York")




#-------------------------------------------------------------------------------
# Time Intervals
#-------------------------------------------------------------------------------
# You're going to Auckland NZ to see your friends Brett and Jermaine
arrive <- ymd_hms("2011-06-04 12:00:00", tz = "Pacific/Auckland")
leave <- ymd_hms("2011-08-10 14:00:00", tz = "Pacific/Auckland")

# Define a time interval
auckland <- interval(arrive, leave)
auckland

# Same as above
auckland <- arrive %--% leave
auckland

# But Brett and Jermaine are goign to the Joint Statisical Meetings in Miami FL
# in late July!
jsm <- interval(ymd("2011-07-20", tz = "Pacific/Auckland"), ymd("2011-08-31", tz = "Pacific/Auckland"))




#-------------------------------------------------------------------------------
# Interval functions
#-------------------------------------------------------------------------------
# Oh no, your trip to Auckland overlaps with their trip to Miami!
int_overlaps(jsm, auckland)

# But there is a set difference! i.e. There are times that you will be in Auckland
# that Brett & Jermaine won't be in Miami
auckland
jsm
setdiff(auckland, jsm)

jsm %within% auckland


# Other weird interval and functions
int_start(jsm)
int_shift(jsm, duration(week=12))




#-------------------------------------------------------------------------------
# Durations. Frankly, I don't recall ever having to use them, but I know they
# exist. So if ever I need to use them, I'll learn it better then.
#-------------------------------------------------------------------------------
minutes(2) ## period
dminutes(2) ## duration

# Why does this matter?
# 2011 is not a leap year, but 2012 is!
leap_year(2011)
leap_year(2012)

dyears(1)
years(1)

ymd("2012-01-01") + dyears(1)
ymd("2012-01-01") + years(1)

# How many days will I be in Auckland?
auckland / ddays(1)
# How many minutes?
auckland / dminutes(1)




#-------------------------------------------------------------------------------
# floor_date() and ceiling_date()
# These are very useful!
#-------------------------------------------------------------------------------
bitcoin <- bitcoin %>%
  mutate(
    first_of_tha_month = floor_date(Date, "month")
  )

# Daily summary
bitcoin %>%
  ggplot(data=., aes(x=Date, y=Avg)) +
  geom_line()

# Monthly summary
bitcoin %>%
  group_by(first_of_tha_month) %>%
  summarise(Avg=mean(Avg)) %>%
  ggplot(data=., aes(x=first_of_tha_month, y=Avg)) +
  geom_line()





# EXERCISE Q3: Using the interval() and %within% commands, plot the times series
# of the weekly average for the price of bitcoin to dates in 2013 and on.





# EXERCISE Q4: Recreate the plot from Exercise 1 above, but with
# -Dates pre 2015-01-01 in one color, and post in another
# -A SINGLE black smoother line. A tough one!














