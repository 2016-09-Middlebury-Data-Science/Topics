library(tidyverse)
library(lubridate)
library(Quandl)


#-------------------------------------------------------------------------------
# Bitcoin Price vs USD Dollar
# Check out this page: 
# https://www.quandl.com/data/BAVERAGE/USD-USD-BITCOIN-Weighted-Price
#-------------------------------------------------------------------------------
bitcoin <- Quandl("BAVERAGE/USD") %>% 
  tbl_df()
bitcoin

# We rename the variables so that they don't have spaces. You do that as follows
# using ` marks (next to the "1" key):
bitcoin <- bitcoin %>% 
  rename(
    Avg = `24h Average`, 
    Total_Volume = `Total Volume`
    )



#-------------------------------------------------------------------------------
# Exercise for today: based off browseVignettes("lubridate")
#-------------------------------------------------------------------------------
# What date is it?
Sys.Date()
# This is an object of class "Date"
Sys.Date() %>% class()

# What time is it? 
Sys.time()
# This is an object of class "POSIX" since it can be computed as the number of seconds
# since Jan 1st, 1970 00:00:00 (midnight)
Sys.time() %>% class()

# Converting strings to dates to strings when the formating is obvious:
ymd("20110604")
mdy("06-04-2011")
dmy("04/06/2011")

# So where as "20110604" is of class character string, ymd makes it a date
"20110604" %>% class()
ymd("20110604") %>% class()

# Converting strings to dates and times. Note that a time zone UTC gets added by
# default since we didn't specify one. More on time zones later...
arrive <- ymd_hms("2011-06-04 12:00:00")
leave <- ymd_hms("2011-08-10 14:00:00")
arrive
leave

# If we convert Date and POSIX objects back to numerical values, we get what we
# expect
ymd("1970-01-01") %>% as.numeric()
ymd_hms("1970-01-01 00:00:01") %>% as.numeric()

# But ymd() and ymd_hms() are cookie-cutter functions, meaning they're really easy
# to use, but are not all that powerful at dealing with special cases.

# Example say we have a string where the date/time is not "clean"...
x <- "Sun 2003 Nov 30 19:48:20"

# ... we use parse_date_time(), which is much more versatile, but harder to use.
parse_date_time(x, "a Y b d HMS")

# What is all this? Look at the help file ?parse_date_time
# Scroll down to Details to see that
# -a: abbreviated weekday
# -Y: year with century
# -b: Abbreviated month name
# -d: Day of the month as decimal number
# -etc...
# 
# Where are there so many different cases? Because there are many many different
# ways people write dates!

# Try this:
x <- "Sunday 03 Nov 30 19:48:20"
parse_date_time(x, "a y b d HMS")


# EXERCISE Q1: As it is, the dates in the bitcoin data are already dates. How 
# do we know? The variable type is listed.
glimpse(bitcoin)
# Plot a time series of the avg price of bitcoins relative to USD vs date.  What
# is the overall trend?





#-------------------------------------------------------------------------------
# Setting and Extracting information
#-------------------------------------------------------------------------------
# Recall we defined arrive above:
arrive

# We can extract all sorts of information
second(arrive)
minute(arrive)
hour(arrive)
day(arrive)
year(arrive)
week(arrive)

# Month is a special case since we can express it as a number or text
month(arrive)
month(arrive, label=TRUE)
month(arrive, label=TRUE, abbr=FALSE)

# As is weekday
wday(arrive)
wday(arrive, label = TRUE)
wday(arrive, label = TRUE, abbr=FALSE)

# Change by number of seconds
arrive
arrive + 1
arrive + 3600

# Change individual components
arrive
day(arrive) <- day(arrive) + 365
arrive

# Change it back
month(arrive) <- month(arrive) - 12
arrive



# EXERCISE Q2: Create a new variable day_of_week in the bitcoin data which
# specifies the day of week and compute the mean trading value split by day of
# week.  Which day of the week is there on average the most trading of bitcoins?



# EXERCISE Q3: Convert the following to POSIX format. Tricky!
x <- "Sunday 06-05-2016 2:15:04 PM" # June 5th, 2016



