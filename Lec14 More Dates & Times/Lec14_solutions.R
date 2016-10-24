library(tidyverse)
library(lubridate)
library(Quandl)




#-------------------------------------------------------------------------------
# Solutions to Lec14.R Exercises
#-------------------------------------------------------------------------------
# Reload bitcoin
bitcoin <- Quandl("BAVERAGE/USD") %>%
  tbl_df() %>%
  rename(
    Avg = `24h Average`,
    Total_Volume = `Total Volume`
  )



# EXERCISE Q3: Using the interval() and %within% commands, plot the times series
# of the weekly average for the price of bitcoin to dates in 2013 and on.
bitcoin %>%
  filter(Date %within% interval(ymd("2013-01-01"), ymd("2016-12-31"))) %>%
  mutate(weekly = floor_date(Date, "week")) %>%
  group_by(weekly) %>%
  summarise(Avg=mean(Avg)) %>%
  ggplot(data=., aes(x=weekly, y=Avg)) +
  geom_line()



# EXERCISE Q4: Recreate the plot from Exercise 1 above, but with
# -Dates pre 2015-01-01 in one color, and post in another
# -A SINGLE black smoother line. A tough one!
bitcoin %>%
  mutate(blah = Date %within% interval(ymd("2015-01-01"), ymd("2016-12-31"))) %>%
  ggplot(data=., aes(x=Date, y=Avg)) +
  geom_line(aes(col=blah)) +
  geom_smooth(se=FALSE, size=0.5, col="black")













