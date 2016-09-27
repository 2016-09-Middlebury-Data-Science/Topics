# Install these packages:
library(Quandl)
library(lubridate)

library(dplyr)
library(ggplot2)

#-------------------------------------------------------------------------------
# Data for Today: Bitcoin Price vs USD Dollar
# https://www.quandl.com/data/BAVERAGE/USD-USD-BITCOIN-Weighted-Price
#-------------------------------------------------------------------------------
bitcoin <- Quandl("BAVERAGE/USD") %>% tbl_df()
bitcoin

# We rename the variables so that they don't have spaces. You do that as follows
# using ` marks (next to the "1" key):
bitcoin <- rename(bitcoin, Avg = `24h Average`, Total.Volume = `Total Volume`)



#-------------------------------------------------------------------------------
# Parsing dates and times
#-------------------------------------------------------------------------------
# EXERCISE Q1: As it is, the dates in the bitcoin data are simply character 
# strings.  Convert the date variable from character strings to date/time 
# objects (using the mutate() function) and plot a time series of the avg price
# of bitcoins relative to USD vs date.  What is the overall trend?

# We convert them to date/time objects using the ymd()
bitcoin <- bitcoin %>% 
  mutate(Date = ymd(Date))
bitcoin$Date

# Time series
ggplot(data=bitcoin, aes(x=Date, y=Avg)) + 
  geom_line() +
  xlab("Date") + 
  ylab("Bitcoin price vs US Dollar") + 
  geom_smooth(se=FALSE)

# The trend is a rollercoaster!



#-------------------------------------------------------------------------------
# Setting and Extracting information
#-------------------------------------------------------------------------------
# EXERCISE Q2: Create a new variable day_of_week which specifies the day of week
# and compute the mean trading value split by day of week.  Which day of the 
# week is there on average the most trading of bitcoins?
bitcoin <- bitcoin %>% 
  mutate(day_of_week = wday(Date, label=TRUE))
bitcoin %>% 
  group_by(day_of_week) %>%
  summarise_each(funs(mean, sd), Total.Volume) %>%
  arrange(desc(mean))

# Wednesday is the busiest day, but the difference with the other weekdays does
# not appear to be significant...
bitcoin %>% 
  group_by(day_of_week) %>%
  ggplot(data=., aes(x=day_of_week, y=Total.Volume)) +
  geom_boxplot() +
  xlab("Day of Week") +
  ylab("Trading Volume") +
  ylim(0, 2*10^5) +
  ggtitle("Bitcoin Trading Volume")
  coord_flip() 





#---------------------------------------------------------------
# Interval functions
#---------------------------------------------------------------
# EXERCISE Q3: Using the interval and %within% commands, plot the times series
# for the price of bitcoin to dates in 2013 and on.
date_range <- interval(ymd(20130101), ymd(20150601))
bitcoin <- bitcoin %>% 
  filter(Date %within% date_range)

ggplot(data=bitcoin, aes(x=Date, y=Avg)) + 
  geom_line() +
  xlab("Date") + 
  ylab("Bitcoin price vs US Dollar") + 
  geom_smooth()


# EXERCISE Q4: Replot the above curve so that the 4 seasons are in different
# colors.  For simplicity assume Winter = (Jan, Feb, Mar), etc.  Don't forget
# the overall smoother.
#
# Hint: nested ifelse statements and the following %in%  function which is
# similar to %within% but for individual elements, not intervals.
c(3,5) %in% c(1,2,3)

# This gets a bit nasty in the second mutate below:  we have a series of nested
# ifelse() statements
bitcoin <- bitcoin %>% 
  mutate(
    month=month(Date),
    Season = ifelse(month %in% c(1,2,3), "spring",
                    ifelse(month %in% c(4,5,6), "summer",
                           ifelse(month %in% c(7,8,9), "fall", "winter")
                    ))
  )

# We could alternatively using piping, but needs to be outside the dplyr piping
# or else things will get confused
bitcoin$Season <-
  ifelse(bitcoin$month %in% c(7,8,9), "fall", "winter") %>%
  ifelse(bitcoin$month %in% c(4,5,6), "summer", .) %>%
  ifelse(bitcoin$month %in% c(1,2,3), "spring", .)


# Reorder the factors
bitcoin$Season <- factor(bitcoin$Season, levels=c("spring", "summer", "fall", "winter"))

ggplot(data=bitcoin, aes(x=Date, y=Avg)) +
  geom_point(aes(col=Season)) +
  xlab("Date") + ylab("Bitcoin price vs US Dollar (log10-scale)") +
  scale_y_log10() +
  geom_smooth()

# Or alternatively I could define "Quarters" which are a combination of the year
# and the season and plot a separate linear smoother for each by setting the
# group aesthetic.  We'll learn more about the paste() command when we learn
# about text manipulation
bitcoin <- bitcoin %>% 
  mutate(Quarter=paste(year(Date), Season))

ggplot(data=bitcoin, aes(x=Date, y=Avg, group=Quarter)) +
  geom_point(aes(col=Season)) +
  xlab("Date") + 
  ylab("Bitcoin price vs US Dollar") +
  scale_y_log10() +
  geom_smooth(method="lm")
