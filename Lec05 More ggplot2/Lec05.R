# Load packages
library(dplyr)
library(ggplot2)

# Install this package for Oxboys dataset.
library(nlme)



#------------------------------------------------------------------------------
# Solutions to Exercises from Lec04.R
#------------------------------------------------------------------------------
# Q1.  Create a plot that shows once again the relationship between carat,
# but now let the size of the points reflect the table of the diamond and have
# separate plots by clarity
data(diamonds)
n <- nrow(diamonds)

# Last time we sampled at random 500 rows of diamonds. i.e. instead of plotting
# them plot only a subset.

# set.seed() sets the seed value for R's random number generator so that we get 
# replicable randomness.  Compare the following two outputs
set.seed(76)
sample(10)

set.seed(76)
sample(10)

# Last time I sampled 500 rows as follows:
samp <- sample(1:n, size = 500)
diamonds <- diamonds[samp, ]

# A much more elegant way to sample 500 rows is using dplyr's sample_n() function:
data(diamonds)
diamonds <- sample_n(diamonds, size = 500)

# We
# - add the aesthetic size to be mapped from the variable "table
# - we facet plot them by clarity. 
# This way we can compare the relationship between carat and price, for
# different tables, AND split by different clarity.
#
# Facets are a VERY powerful tool.
ggplot(data=diamonds, aes(x = carat, y = price, colour = cut, size = table)) +
  geom_point() +
  facet_wrap(~clarity, nrow=2) +
  ggtitle("Second example")



# Q2. A friend wants to know if cars in 1973-1974 that have bigger cylinders
# (the variable displacement in cu. in.) have better mileage (in mpg). Two
# important factors they want to consider are the # of cylinders and whether the
# car has an automatic or manual transmission.  Answer your friend's question
# using a visualization. As added bonus, use google to add detailed x-labels and
# y-labels
data(mtcars)
table(mtcars$cyl)

# There are many ways to do this: 

# Here the variable cyl is treated as a continuous varible, so we get a
# continous color gradient
ggplot(data=mtcars, aes(x=disp, y=mpg, color=cyl)) +
  geom_point() +
  facet_wrap(~am) +
  xlab("Cylinder size (displacement in cubic inches)") +
  ylab("MPG")

# Here we convert the variable cyl to a categorical variable, with three
# levels: 4, 6, and 8.
ggplot(data=mtcars, aes(x=disp, y=mpg, color=as.factor(cyl))) +
  geom_point() +
  facet_wrap(~am) +
  xlab("Cylinder size (displacement in cubic inches)") +
  ylab("MPG")

# So it appears that as cars have bigger cylinders, they have worse mileage,
# for both automatic and manual transmissions, and while taking into account
# the number of cylinders. Note, this plot still needs polish b/c some of the
# text is still non-informative.





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


# The default aesthetic mapping carat to the y-axis is based on count.  Note,
# since "count" is not a variable name in our dataset, we need to put ".."
# around it. Note here we defined the aesthetic within the geom. So
# -the aes(x=carat) is global to the entire plot
# -the aes(y=..count..) is specific to the geom_histogram
ggplot(data=diamonds, aes(x=carat)) +
  geom_histogram(aes(y = ..count..))

# Instead of count, we can have density, so that the areas of the boxes sum to
# 1 i.e. it is a probability distribution.
ggplot(data=diamonds, aes(x=carat)) +
  geom_histogram(aes(y = ..density..))





#------------------------------------------------------------------------------
# geom_line() and the group aesthetic
#------------------------------------------------------------------------------
data(Oxboys)

# We consider the height of Oxford boys data set. We have 9 observations from 26
# boys at different ages. Say we are interested in studying the growth of these
# 26 boys over time.
?Oxboys
Oxboys <- Oxboys %>% tbl_df()
Oxboys

# For simplicity, let's consider Subject 1 only for now:
subject_1 <- Oxboys %>% 
  filter(Subject == 1)
subject_1

# We plot a geom_line(). Easy enough!
p <- ggplot(subject_1, aes(x=age, y=height)) + 
  geom_line()
p

# We can also add a regression line:
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
UCB <- as.data.frame(UCBAdmissions)
UCB


# Q2: Investigate how male vs female acceptance varied by department.


# Q3. Investigate the "competitiveness" of different departments as measured by acceptance rate.









