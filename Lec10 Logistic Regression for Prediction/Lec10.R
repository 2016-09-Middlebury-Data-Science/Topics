library(ggplot2)
library(dplyr)
# Used for string manipulation:
library(stringr)
# Set random number generator seed value
set.seed(76)



#-------------------------------------------------------------------------------
# Load Data & Preprocess It
#-------------------------------------------------------------------------------
# Set the working directory of R to wherever the profiles.csv file is
profiles <- read.csv("profiles.csv", header=TRUE) %>% tbl_df()
nrow(profiles)

# 60K rows is a bit unwieldy to work with, so let's take a random sample of 10%
# of the rows. This is a common trick used in the early stage of analysis:
# -take a random subsample to that things load quicker
# -once we're happy with our work, run the analysis on all the observations
profiles <- profiles %>% sample_frac(0.1)

# Split off the essays into a separate data.frame
essays <- select(profiles, contains("essay"))
profiles <- select(profiles, -contains("essay"))

# Look at our data
names(profiles)
glimpse(profiles)

# Because essays is of tbl_df() format, we can't see all the essays of the 9th
# user.
essays[9, ]
# Use print.data.frame() to see all that person's essays
print.data.frame(essays[9, ])

# Define a binary outcome variable
# y_i = 1 if female
# y_i = 0 if male
profiles <- mutate(profiles, is.female = ifelse(sex=="f", 1, 0))

# Preview of things to come:  The variable "last online" includes the time.  We
# remove them by using the str_sub() function from the stringr package.  i.e.
# take the "sub-string" from position 1 to 10 of each string.  Then we convert
# them to dates.
profiles$last_online[1:10]
profiles <- profiles %>% 
  mutate(
    last_online = str_sub(last_online, 1, 10),
    last_online = as.Date(last_online)
  )
profiles$last_online[1:10]



#---------------------------------------------------------------
# Exercise 1:
#---------------------------------------------------------------
# If you had to guess a user's sex via coin flips (i.e. using no information),
# where getting heads = declaring user is female, what should be the probability
# of heads?







#-------------------------------------------------------------------------------
# Search for strings i.e. words
#-------------------------------------------------------------------------------
# The following two functions allow us to search each row of a data frame for
# a string.  Don't worry about how they work for now; we'll explore this more 
# when we cover text mining).
find_query <- function(char.vector, query){
  which.has.query <- grep(query, char.vector, ignore.case = TRUE)
  length(which.has.query) != 0
}
profile_has_word <- function(data.frame, query){
  query <- tolower(query)
  has.query <- apply(data.frame, 1, find_query, query=query)
  return(has.query)
}

# Search for the string "wine"
profiles$has.wine <- profile_has_word(data.frame = essays, query = "wine")
x <- table(profiles$has.wine)
x
# Quick and dirty barplot, w/o using ggplot
barplot(x, xlab="Has 'wine'?")

# Contingency table:
y <- table(profiles$sex, profiles$has.wine)
y
# mosaicplot.  What do the bar widths mean?
mosaicplot(y, xlab="sex", ylab="Has 'wine'?")

#---------------------------------------------------------------
# Exercise 2:
#---------------------------------------------------------------
# Visualize the relationship between the presence of the word "wine"and the
# presence of the word "food" in users' profiles







#-------------------------------------------------------------------------------
# Is height predictive of sex?
#-------------------------------------------------------------------------------
#---------------------------------------------------------------
# Exercises
#---------------------------------------------------------------
# 3. Compare the heights of females and males using geom_histogram()


# 4. Plot the binary variable is.female over height (i.e. height on the
# x-axis).  What's wrong with this basic visualization? What function from the
# can alleviate this problem?


# 5. Sketch out in your mind what the best fitting function through
# these points are where the function doesn't have to be linear.  Recall a
# function maps each value of x to a single value.







#-------------------------------------------------------------------------------
# Additional Changing Levels of a Factor
#-------------------------------------------------------------------------------
# Let's say you want to create a binary variable smokes vs not using:
levels(profiles$smokes)
count(profiles, smokes)

# You can do this be reassigning the levels of the variable
profiles$is.smoker <- profiles$smokes
levels(profiles$is.smoker) <- c("NA", "no", "yes", "yes", "yes", "yes")
count(profiles, is.smoker)

mosaicplot(table(profiles$sex, profiles$is.smoker))







#-------------------------------------------------------------------------------
# Exercise
#-------------------------------------------------------------------------------
# Do an exploratory data analysis (EDA) of all the varibles in this dataset. 
# You will be using this dataset for HW02!