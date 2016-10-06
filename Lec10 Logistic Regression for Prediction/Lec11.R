library(ggplot2)
library(dplyr)
# Used for string manipulation:
library(stringr)
# Set random number generator seed value
set.seed(76)


#-------------------------------------------------------------------------------
# Load Data & Preprocess It (Same as Previous)
#-------------------------------------------------------------------------------
# Load data and take random sample
profiles <- read.csv("profiles.csv", header=TRUE) %>% 
  tbl_df() %>% 
  sample_frac(0.1)

# Split off the essays into a separate data.frame
essays <- select(profiles, contains("essay"))
profiles <- select(profiles, -contains("essay"))

# Define a binary outcome variable
# y_i = 1 if female
# y_i = 0 if male
profiles <- mutate(profiles, is_female = ifelse(sex=="f", 1, 0))

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



#-------------------------------------------------------------------------------
# Solutions:
#-------------------------------------------------------------------------------
# Q1: If you had to guess a user's sex via coin flips (i.e. using no information),
# where getting heads = declaring user is female, what should be the probability
# of heads?

# Answer: Since the sample proportion = 40% of the observations are female, this
# should be the "probability that a randomly chosen person is female".  Logistic
# regression (and all regression for that matter) is all about guessing better
# than this mean value by incorporating other information.
mean(profiles$is_female)

# Q3: Compare the heights of females and males using geom_histogram()
ggplot(data=profiles, aes(x=height)) + 
  geom_histogram(aes(y=..density..)) + 
  facet_wrap(~sex, nrow=2)

# Q4: Plot the binary variable is.female over height (i.e. height on the
# x-axis).  What's wrong with this basic visualization? What function from the
# can alleviate this problem?

# Answer: The problem is so many points are superimposed on top of each other,
# we don't know how many there are
ggplot(data=profiles, aes(x=height, y=is.female)) +
  geom_point()
# The solution is to jitter the points a little:
ggplot(data=profiles, aes(x=height, y=is.female)) +
  geom_jitter(height=0.2)
# We can add an alpha to thin the points out a little: only when there are 
# several points on top of each other do they get darker
ggplot(data=profiles, aes(x=height, y=is.female)) +
  geom_jitter(height=0.2, alpha=0.1)








#-------------------------------------------------------------------------------
# Model0: Naive Model Using No Information
#-------------------------------------------------------------------------------
# Recall: if you had to guess a user's sex via coin flips (i.e. using no
# information), where getting heads = declaring user is female, the probability 
# of heads should be about 40%, the proportion of the dataset that is female.

# Regression, coefficients, and fitted values:  This situation is akin to
# fitting a regression with only an intercept. This is done in R by
# 1. Setting the predictor variables to just "1" (the number one)
# 2. The command to run logistic regression is "glm" for "generalized linear
# model", where the family is set to "binomial"

model0 <- glm(is_female ~ 1, data=profiles, family=binomial)
summary(model0)

# We apply the inverse logit formula to the intercept coefficient b0:
# What does this equal?
b0 <- coefficients(model0)
b0
1/(1+exp(-b0))

# We obtain the fitted values using the fitted() command
fitted(model0)
table(fitted(model0))

# Plot:  Not useful when we don't have any predictors
ggplot(data=profiles, aes(x=1, y=is_female)) + 
  geom_point()








#-------------------------------------------------------------------------------
# Model1: One Categorical Variable
#-------------------------------------------------------------------------------
#------------------------------------------------
# Is using the word "wine" predictive of sex?
#------------------------------------------------
# The following two functions allow us to search each row of a data.frame for
# a string.  (More when we cover text mining).
find.query <- function(char.vector, query){
  which.has.query <- grep(query, char.vector, ignore.case = TRUE)
  length(which.has.query) != 0
}
profile.has.query <- function(data.frame, query){
  query <- tolower(query)
  has.query <- apply(data.frame, 1, find.query, query=query)
  return(has.query)
}

# Search for the string "wine"
profiles$has_wine <- profile.has.query(data.frame = essays, query = "wine")

# Regression to the mean (i.e. proportion): in this case, the means are the
# sample proportions of the two groups: those with the word wine in their
# profile, and those without.  Compare these to the model0 mean.  Are we doing
# better?
group_by(profiles, has_wine) %>% 
  summarise(prop_female=mean(is_female))


# Regression, coefficients, and fitted values: we now include the has_wine
# predictor variable
model1 <- glm(is_female ~ has_wine, data=profiles, family=binomial)
summary(model1)

# We apply the inverse logit formula to the two cases of the regression
# equation:  when the profile has wine, i.e. x=1, or when it doesn't, i.e. x=0
b1 <- coefficients(model1)
b1
1/(1+exp(-(b1[1] + 0*b1[2])))
1/(1+exp(-(b1[1] + 1*b1[2])))

# The inverse-logit of the two cases of the regression equation match the fitted
# values.  Compare to the means from part a)
table(fitted(model1))

# Plot.
p1 <- ggplot(data=profiles, aes(x=has_wine, y=is_female)) + 
  xlab("has wine") + ylab("is female?")
p1 +
  geom_point()

# Oops! We need to use jitter. What do the four sets of points correspond to?
p1 +
  geom_jitter(width=0.5, height=0.5)

# We add the fitted probabilities:
# -blue line for those with "wine" (left column)
# -red for those without (right column)
p1 +
  geom_jitter(width=0.5, height=0.5) + 
  geom_hline(yintercept=1/(1+exp(-(b1[1] + 0*b1[2]))), col="red", size=2)+
  geom_hline(yintercept=1/(1+exp(-(b1[1] + 1*b1[2]))), col="blue", size=2)








#-------------------------------------------------------------------------------
# Model2: One Continuous Variable
#-------------------------------------------------------------------------------
#------------------------------------------------
# Is height predictive of sex?
#------------------------------------------------
# Let's look at height by sex again
ggplot(data=profiles, aes(x=height, y=..density..)) +
  geom_histogram() +
  facet_wrap(~sex, ncol=1) +
  xlim(c(50, 80))


# Regression to the mean (i.e. proportion): Looking at the above histograms, the
# heights of the men are higher, but is the difference significant?  What is SE?
# How does this help us tell if there is a significant difference?
group_by(profiles, is_female) %>% 
  summarise(mean=mean(height), SE=sd(height)/n())


# Regression, coefficients, and fitted values
model2 <- glm(is_female ~ height, data=profiles, family=binomial)
summary(model2)
b2 <- coefficients(model2)

# How do we interpret the slope coefficient here?
b2[2]
exp(b2)[2]

# Histogram of fitted p.hat's.  What is the range of the p.hats?  How does this
# compare to our original model0 p.hat?
hist(fitted(model2))

# Plot:  Again, we add some jitter so we can better visualize the number of
# points involved for each height.
p2 <- ggplot(data=profiles, aes(x=height, y=is_female)) +
  xlab("height") + ylab("is female") +
  xlim(c(50, 80)) + 
  geom_jitter(height=0.2) 
p2

# We now add the regression line. We apply the inverse logit function to the
# regression equation.
regression_line <- function(x, b){
  # Pick out intercept and slope
  linear.equation <- b[1] + b[2]*x
  
  # Inverse logit
  1/(1+exp(-linear.equation))
}

# We plot this using the stat_function() function. i.e. we specify our own
# function and its inputs. For what height does our model say we have a 50/50
# chance the user is female?
p2 + 
  stat_function(fun = regression_line, args=list(b=b2), color="blue", size=2)