library(tidyverse)
library(lubridate)
library(Quandl)




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
auckland <- interval(arrive, leave) # Same as arrive %--% leave
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
# Hint: nested ifelse statements and the following %in%  function which is
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
