# Now we only need to do this:
library(tidyverse)
# And not all these:
# library(ggplot2)
# library(dplyr)
# library(readr)

# These packages we still need to load individually however:
# For string manipulation:
library(stringr)
# For pretty model summaries:
library(broom)



#-------------------------------------------------------------------------------
# Load Data & Preprocess It
#-------------------------------------------------------------------------------
# Set the working directory of R to wherever the profiles.csv file then run. The
# rownames_to_column(var="id") function from the tibble package adds a column 
# (which we specify to be called "id") of the rownames. We are going to use this
# later as an ID variable to identify users.
profiles <- 
  read_csv("profiles.csv") %>% 
  tibble::rownames_to_column(var="id")

# Let's focus only on the non-essay data: split off the essays into a separate
# data frame
essays <- profiles %>% 
  select(id, contains("essay"))
profiles <- profiles %>% 
  select(-contains("essay"))

# Look at our data
View(profiles)
glimpse(profiles)

# Define a binary outcome variable is_female
# 1 if female
# 0 if male
profiles <- profiles %>% 
  mutate(is_female = ifelse(sex=="f", 1, 0))

# Preview of things to come:  The variable "last online" includes the time.  We
# remove them by using the str_sub() function from the stringr package.  i.e.
# take the "sub-string" from position 1 to 10 of each string.  Then we convert
# them to dates.
profiles$last_online[1:10]
profiles <- profiles %>% 
  mutate(
    last_online = stringr::str_sub(last_online, 1, 10),
    last_online = lubridate::ymd(last_online)
  )
profiles$last_online[1:10]



#---------------------------------------------------------------
# Exercise: Scenario 1 - No predictors
#---------------------------------------------------------------
# Say you have to guess a user's sex using no information. What proportion of
# the time should you guess female? Keep in mind, you are not making guesses 
# about person chosen from the general population, but rather these 59946 of SF 
# OkCupid users.



#---------------------------------------------------------------
# Exercise: Scenario 2 - One Categorical Predictor
#---------------------------------------------------------------
# Now say you have access to said user's sexual orientation as listed in the
# 3-level categorical variable orientation (note that OkCupid has since relaxed
# the 3 choices to cover a broader spectrum of choices). CONDITIONAL on knowing
# a user's sex, what proportion of the time should you guess female? 




#---------------------------------------------------------------
# Exercise: Scenario 3 - One Numerical Predictor
#---------------------------------------------------------------
# For the purposes of today's exercise only, delete the 
# -3 users who did not enter a height
# -all users who listed "unreasonable" heights
# Hint: check out the dplyr::between() command. Ex:
x <- c(1:6)
x
between(x, 2, 5)




# a) Compare the heights of females and males using a density geom_histogram().
# Set bidwidth argument in your geom_histogram so that there are no gaps
# Notice anything weird about the distribution of male heights? Remember, these
# are self-reported heights, not actual heights.




# b) Make a line graph where the
# -x-axis represents height
# -y-axis represents the proportion of users who are female GIVEN a particular height
#
# Note:
# -You might need to sketch out the dplyr steps on paper first
# -After you've made your plot, step back, take a breath, and make sure your
# plots fit with common sense about male vs female heights


# Assign your ggplot to p here:
p <- 

# So that when you run the next line, the plot shows
p






#---------------------------------------------------------------
# Preview for Lec12
#---------------------------------------------------------------
# Run the following for today. No need to understand everything; just see if 
# you can make connections with the earlier exercises

# Logistic regresion with intercept only; no predictors
model_1 <- glm(is_female ~ 1, data=profiles, family="binomial")
broom::tidy(model_1)
1/(1+exp(-(  -0.3944313  )))

# Recognize that last number?




# Logistic regresion with one categorical predictor: orientation
model_2 <- glm(is_female ~ orientation, data=profiles, family="binomial")
broom::tidy(model_2)
1/(1+exp(-(  0.952807  )))
1/(1+exp(-(  0.952807-1.873376  )))
1/(1+exp(-(  0.952807-1.365479  )))

# Recognize those last three numbers?




# Logistic regresion with one numerical predictor: height
model_3 <- glm(is_female ~ height, data=profiles, family="binomial")
broom::tidy(model_3)
f <- function(height) {
  1/(1+exp(-(  44.4486093 -0.6619036*height  )))
  }
p +
  stat_function(fun = f, col="red")

# See a correspondence?