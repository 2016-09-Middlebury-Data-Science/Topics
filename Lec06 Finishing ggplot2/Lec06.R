# Load packages
library(dplyr)
library(ggplot2)




#------------------------------------------------------------------------------
# geom_histogram()
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
# geom_boxplot()
#------------------------------------------------------------------------------
# Let's compare mileage (miles per gallon) for a set of automatic vs manual
# cars
data(mtcars)

# A boxplot has as x-aesthetic a categorical variable. What's wrong with the
# code below?
ggplot(data=mtcars, aes(x=am, y=mpg)) + 
  geom_boxplot()

# We should convert am, which is coded as numerical 0 and 1's, to a categorical
# variable, i.e. a factor in R
ggplot(data=mtcars, aes(x=as.factor(am), y=mpg)) + 
  geom_boxplot()

# Better yet, let's transform the variable, and pipe the data fram directly
# into the ggplot() call and add labels
mtcars %>% 
  mutate(am=ifelse(am==0, "automatic", "manual")) %>% 
  ggplot(data=., aes(x=as.factor(am), y=mpg)) + 
  geom_boxplot() +
  labs(x="Transmission", y="Mileage (in mpg)", title="")
  
# If you don't know, look on the internet or ask your neighbor how to interpret
# boxplots!



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
p + 
  geom_bar()

# KEY POINT: This doesn't work b/c the default stat for geom_bar is "bin". i.e. 
# it takes multiple observatinons and assigns bins to them and returns a count
# for each bin, like a histogram. In our case, the data is already binned! So we
# need to override the default stat to "stat=identity". 
p + 
  geom_bar(stat="identity")

# We can also make position adjustments to the geom_bar. The default position
# is "stack". Let's also look at two others:
p + 
  geom_bar(stat="identity", position="stack")
p + 
  geom_bar(stat="identity", position="dodge")
p + 
  geom_bar(stat="identity", position="fill")

# For fun, let's flip the coordinate-axes
p + 
  geom_bar(stat="identity", position="fill") + 
  coord_flip()





#------------------------------------------------------------------------------
# Exercises:
#------------------------------------------------------------------------------
# Q1: Modify the Titanic code above to show a visualization that can answer the
# question of if the "Women and children first" policy of who got on the
# lifeboats held true. Hint: the answer is yes.

# We now load the UC Berkeley Admissions Data
data(UCBAdmissions)
UCB <- UCBAdmissions %>% 
  as.data.frame()
UCB


# Q2: When creating the boxplot comparing mileage for automatic vs manual cars, 
# we could've had facetted histograms as below. What could be one reason for
# favoring the boxplot over the histograms?
ggplot(data=mtcars, aes(x=mpg)) +
  geom_histogram(bins=10) +
  facet_wrap(~am)


# Q3: Investigate how male vs female acceptance varied by department.


# Q4. Investigate the "competitiveness" of different departments as measured by
# acceptance rate.




