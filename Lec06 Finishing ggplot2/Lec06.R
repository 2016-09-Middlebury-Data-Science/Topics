# Load packages
library(dplyr)
library(ggplot2)
library(nlme)



# GEOM BOXPLOT!!!!!




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
# geom_line() and the "group" aesthetic
#------------------------------------------------------------------------------
data(Oxboys)

# We consider the height of Oxford boys data set. We have 9 observations from 26
# boys at different ages. Say we are interested in studying the growth of these
# 26 boys over time.
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


p + stat_smooth(se=FALSE)

# We can also add a regression line. lm stands for linear model:
p + stat_smooth(method="lm")
p + stat_smooth(method="lm", se=FALSE, col="red") # without standard error bars

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
# geom_bar(), position adjusments, and which stat to use:
#------------------------------------------------------------------------------
# Titanic Survival Data
data(Titanic)
Titanic

# The original data is not in "tidy" format, so we tidy it.
# Here tidying was super easy, but typically it won't be (more next Lecture)
Titanic <- as.data.frame(Titanic)
Titanic

# KEY OBSERVATION:
# Each row corresponds to
# -a "binned" count for each of the 32 categories a passenger could be:
#  Class (4 levels) x Sex (2 levels) x Age (2 levels) X Survived (2 levels)
# -and not individual people on the boat. If the rows corresponded to
#  individuals, the data set would be 2201 rows long.

# Simple barplot: survival by Class:
survival_by_class <- Titanic %>%
  group_by(Survived, Class) %>%
  summarize(Freq=sum(Freq))
survival_by_class

# We want
# -x aesthetic: separate bars by Class
# -y aesthetic: to represent frequency
# -fill aesthetic: the fill color of the bars to be split by Survived
p <- ggplot(data=survival_by_class, aes(x=Class, y=Freq, fill = Survived))

# Assign geom_bar to it:
p + geom_bar()

# KEY POINT: This doesn't work b/c the default stat for geom_bar is "bin". i.e.
# it takes multiple observatinons and assigns bins to them, like a histogram.
# In our case, the data is already binned! So we need to override the default
# stat to "stat=identity". i.e. f(x)=x i.e. take the data as they are!
p + geom_bar(stat="identity")

# We can also make position adjustments to the geom_bar. The default position
# is "stack". Let's also look at two others:
p + geom_bar(stat="identity", position="stack")
p + geom_bar(stat="identity", position="dodge")
p + geom_bar(stat="identity", position="fill")

# For fun, let's flip the coordinate-axes
p + geom_bar(stat="identity", position="fill") + coord_flip()





#------------------------------------------------------------------------------
# Exercises:
#------------------------------------------------------------------------------
# Q1: Modify the Titanic code above to show a visualization that can answer the
# question of if the "Women and children first" policy of who got on the
# lifeboats held true. Hint: the answer is yes.


# We now load the UC Berkeley Admissions Data
data(UCBAdmissions)
UCB <- UCBAdmissions %>% as.data.frame()
UCB


# Q2: Investigate how male vs female acceptance varied by department.


# Q3. Investigate the "competitiveness" of different departments as measured by
# acceptance rate.









