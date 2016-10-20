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

# Hadley Wickham is from New Zealand, so he sets a Skype meeting for NZ time
meeting <- ymd_hms("2011-07-01 09:00:00", tz = "Pacific/Auckland")
meeting

# What time is this in Portland?
with_tz(meeting, "America/Los_Angeles")

# Let's change the time zone to ours permanently
meeting <- force_tz(meeting, "America/Los_Angeles")
meeting




#-------------------------------------------------------------------------------
# Time Intervals
#-------------------------------------------------------------------------------
arrive <- ymd_hms("2011-06-04 12:00:00")
leave <- ymd_hms("2011-08-10 14:00:00")

auckland <- interval(arrive, leave)
jsm <- interval(ymd(20110720, tz = "Pacific/Auckland"), ymd(20110831, tz = "Pacific/Auckland"))

# Compare these two time intervals.  A bit hard to read unfortunately
auckland
jsm




#-------------------------------------------------------------------------------
# Interval functions
#-------------------------------------------------------------------------------
int_overlaps(jsm, auckland)
int_start(jsm)
int_flip(jsm)
int_shift(jsm, duration(week=12))

x <- c(ymd(20110725, tz = "Pacific/Auckland"), ymd(20110901, tz = "Pacific/Auckland"))
x
x %within% jsm


# EXERCISE Q3: Using the interval and %within% commands, plot the times series
# for the price of bitcoin to dates in 2013 and on.


# EXERCISE Q4: Replot the above curve so that the 4 seasons are in different
# colors.  For simplicity assume Winter = (Jan, Feb, Mar), etc.  Don't forget
# the overall smoother.
#
# Hint: nested ifelse statements and the following %in% function which is
# similar to %within% but for individual elements, not intervals.
c(3,5) %in% c(1,2,3)

















## ------------------------------------------------------------------------
meeting <- ymd_hms("2011-07-01 09:00:00", tz = "Pacific/Auckland")
with_tz(meeting, "America/Chicago")

## ------------------------------------------------------------------------
mistake <- force_tz(meeting, "America/Chicago")
with_tz(mistake, "Pacific/Auckland")

## ------------------------------------------------------------------------
auckland <- interval(arrive, leave)
auckland
auckland <- arrive %--% leave
auckland

## ------------------------------------------------------------------------
jsm <- interval(ymd(20110720, tz = "Pacific/Auckland"), ymd(20110831, tz = "Pacific/Auckland"))
jsm

## ------------------------------------------------------------------------
int_overlaps(jsm, auckland)

## ------------------------------------------------------------------------
setdiff(auckland, jsm)

## ------------------------------------------------------------------------
minutes(2) ## period
dminutes(2) ## duration

## ------------------------------------------------------------------------
leap_year(2011) ## regular year
ymd(20110101) + dyears(1)
ymd(20110101) + years(1)

leap_year(2012) ## leap year
ymd(20120101) + dyears(1)
ymd(20120101) + years(1)

## ------------------------------------------------------------------------
meetings <- meeting + weeks(0:5)

## ------------------------------------------------------------------------
meetings %within% jsm

## ------------------------------------------------------------------------
auckland / ddays(1)
auckland / ddays(2)
auckland / dminutes(1)

## ------------------------------------------------------------------------
auckland %/% months(1)
auckland %% months(1)

## ------------------------------------------------------------------------
as.period(auckland %% months(1))
as.period(auckland)

## ------------------------------------------------------------------------
jan31 <- ymd("2013-01-31")
jan31 + months(0:11)
floor_date(jan31, "month") + months(0:11) + days(31)
jan31 %m+% months(0:11)

## ------------------------------------------------------------------------
last_day <- function(date) {
  ceiling_date(date, "month") - days(1)
}
