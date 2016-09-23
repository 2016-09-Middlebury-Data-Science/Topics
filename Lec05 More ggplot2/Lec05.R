# Load packages
library(dplyr)
library(ggplot2)
library(nlme)



#------------------------------------------------------------------------------
# geom_line() and its derivatives
#------------------------------------------------------------------------------
# Here is a toy example
example <-
  data_frame(
    x = seq(from=0, to=10, by=0.1),
    y = sin(x) + rnorm(length(x), mean = 0, sd = 0.5)
  )

# geom_line() isn't that different from geom_point()
base_plot <- ggplot(data=example, aes(x=x, y=y)) +
  geom_line()
base_plot

# Let's add a "smoother" using geom_smooth()
base_plot +
  geom_smooth()

# This allows us to pick out the "signal" from the "noise" by smoothing out the
# curve. They grey bars correspond to standard error bars, which we can remove:
base_plot +
  geom_smooth(se=FALSE)


# We can also add a regression line: lm stands for linear model.
base_plot +
  stat_smooth(method="lm")
base_plot +
  stat_smooth(method="lm", se=FALSE)





#------------------------------------------------------------------------------
# aes(group=VARIABLE) aesthetic
#------------------------------------------------------------------------------
# Setting the group aesthetic is a very powerful tool to break up elements

# We consider the height of Oxford boys data set. We have 9 observations from 26
# boys at different ages. Say we are interested in studying the growth of these
# 26 boys over time.
data(Oxboys)
?Oxboys
Oxboys <- Oxboys %>% tbl_df()
Oxboys

# For simplicity, let's consider Subject 17 only for now:
subject_17 <- Oxboys %>%
  filter(Subject == 1)
subject_17

# We plot a geom_line(). Easy enough!
p <- ggplot(data=subject_17, aes(x=age, y=height)) +
  geom_line()
p

# Now let's consider ALL boys, and not just Subject 1:
ggplot(data=Oxboys, aes(x=age, y=height)) +
  geom_line()

# This plot does not make much sense, as there is a single line for all 26 boys.
# We resolve this by having separate lines for each by setting the group
# aesthetic of the geom_line(). Much better:
ggplot(data=Oxboys, aes(x=age, y=height, group = Subject)) +
  geom_line()

# We could've equally done this using the color aesthetic, but there the large
# number of subjects makes the legend a bit unwieldy.
ggplot(data=Oxboys, aes(x=age, y=height, col = Subject)) +
  geom_line()




#------------------------------------------------------------------------------
# geom_histogram() and the group aesthetic
#------------------------------------------------------------------------------
# For the diamond dataset, let's look at a histogram of carat.
data(diamonds)
ggplot(data=diamonds, aes(x=carat)) +
  geom_histogram()

# We can change the # of bins or change the bin width
ggplot(data=diamonds, aes(x=carat)) +
  geom_histogram(bins=50)
ggplot(data=diamonds, aes(x=carat)) +
  geom_histogram(binwidth = 0.1)


# The default behavior of geom_histogram() is to map "count" to the y aesthetic.
# So the two following plots are identical, because of the way the defaults are
# set:
ggplot(data=diamonds, aes(x=carat)) +
  geom_histogram()
ggplot(data=diamonds, aes(x=carat, y=..count..)) +
  geom_histogram()

# Note, "count" is not a variable in our dataset, but rather something ggplot
# creates internally, hence we need to put ".." around it. Why does this matter?
# When we want to create a density/probability histogram, where the areas of the
# boxes sum to 1. i.e. it is a probability distribution.
ggplot(data=diamonds, aes(x=carat, y = ..density..)) +
  geom_histogram()





#------------------------------------------------------------------------------
# EXERCISE
#------------------------------------------------------------------------------
library(babynames)
data(babynames)
View(babynames)

# Using the babynames dataset above, plot the popularity of your favorite male
# and female name from 1880-2014 on the same plot



