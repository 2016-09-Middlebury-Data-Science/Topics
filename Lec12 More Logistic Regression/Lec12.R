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
# Reload Profiles Data & Preprocess It
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
glimpse(profiles)

# Define a binary outcome variable is_female
# 1 if female
# 0 if male
profiles <- profiles %>%
  mutate(is_female = ifelse(sex=="f", 1, 0)) %>%
  mutate(
    last_online = stringr::str_sub(last_online, 1, 10),
    last_online = lubridate::ymd(last_online)
  )





#---------------------------------------------------------------
# Exercise: Scenario 1 - No predictors
#---------------------------------------------------------------
# Say you have to guess a user's sex using no information. What proportion of
# the time should you guess female? Keep in mind, you are not making guesses
# about person chosen from the general population, but rather these 59946 of SF
# OkCupid users.

# Answer:
mean(profiles$is_female)

# Logistic regresion with intercept only; no predictors
model_1 <- glm(is_female ~ 1, data=profiles, family="binomial")
broom::tidy(model_1)

# i.e. just an intercept
# log(p/(1-p)) = -0.3958406 + 0
intercept <- tidy(model_1)$estimate[1]

# Solve for p. It's the same as above!
1/(1+exp(-(  intercept  )))



#---------------------------------------------------------------
# Exercise: Scenario 2 - One Categorical Predictor
#---------------------------------------------------------------
# Now say you have access to said user's sexual orientation as listed in the
# 3-level categorical variable orientation (note that OkCupid has since relaxed
# the 3 choices to cover a broader spectrum of choices). CONDITIONAL on knowing
# a user's sex, what proportion of the time should you guess female?

# Answer:
profiles %>%
  group_by(orientation) %>%
  summarise(prop_female=mean(is_female))

# Logistic regresion with one categorical predictor: orientation
model_2 <- glm(is_female ~ orientation, data=profiles, family="binomial")
broom::tidy(model_2)

# i.e. intercept and different "slopes" for categorical variables
# If you're not sure how this works, ask around.
# log(p/(1-p)) = intercept + slope
intercept <- tidy(model_2)$estimate[1]
slope_gay <- tidy(model_2)$estimate[2]
slope_straight <- tidy(model_2)$estimate[3]

# Solve for p. They're the same as above!
1/(1+exp(-(  intercept  )))
1/(1+exp(-(  intercept+slope_gay  )))
1/(1+exp(-(  intercept+slope_straight  )))



#---------------------------------------------------------------
# Exercise: Scenario 3 - One Numerical Predictor
#---------------------------------------------------------------
# For the purposes of today's exercise only, delete the
# -3 users who did not enter a height
# -all users who listed "unreasonable" heights
profiles_clean <- profiles %>%
  filter(!is.na(height)) %>%
  filter(between(height, 55, 80))

# a) Compare the heights of females and males using a density geom_histogram().
# Set bidwidth argument in your geom_histogram so that there are no gaps
# Notice anything weird about the distribution of male heights? Remember, these
# are self-reported heights, not actual heights.

# Answer
ggplot(data=profiles_clean, aes(x=height, y=..density..)) +
  geom_histogram(binwidth=1) +
  facet_wrap(~sex, ncol=1)


# b) Make a line graph where the
# -x-axis represents height
# -y-axis represents the proportion of users who are female GIVEN a particular height
#
# Note:
# -You might need to sketch out the dplyr steps on paper first
# -After you've made your plot, step back, take a breath, and make sure your
# plots fit with common sense about male vs female heights

# Answer
prop_female_height <- profiles_clean %>%
  select(is_female, height) %>%
  group_by(height) %>%
  summarise(prop_female = mean(is_female))

# Plot
p <- ggplot(data=prop_female_height, aes(height, prop_female)) +
  geom_line()
p

# Logistic regresion with one numerical predictor: height
model_3 <- glm(is_female ~ height, data=profiles_clean, family="binomial")
broom::tidy(model_3)

# i.e. intercept and different "slopes", in this case intercept adjustments
# log(p/(1-p)) = 44.4486093 - 0.6619036*height
intercept <- tidy(model_3)$estimate[1]
slope_height <- tidy(model_3)$estimate[2]

# Solve for p, and make it a function. Note how the value of the curve
# corresponds almost exactly to the proportion of females for any given height.
f <- function(height) {
  1/(1+exp(-(  intercept + slope_height*height  )))
  }
p +
  stat_function(fun = f, col="red")





#-------------------------------------------------------------------------------
# Get Fitted Probabilities p-hat
#-------------------------------------------------------------------------------
# Let's re-run all three models on the same data set for consistency
model_1 <- glm(is_female ~ 1, data=profiles_clean, family="binomial")
model_2 <- glm(is_female ~ orientation, data=profiles_clean, family="binomial")
model_3 <- glm(is_female ~ height, data=profiles_clean, family="binomial")

# To extract the value of the linear regression equation beta_0 + beta_1*x + ...:
predict(model_1)

# However these are clearly not probabilities. To return probabilities, i.e. by
# applying 1/(1 + exp(-(linear regression equation))), use:
fitted(model_1)

# Create data frame of predictors, truth and predicted values
predictions <- profiles_clean %>%
  select(orientation, height, is_female) %>%
  mutate(
    p_hat1 = fitted(model_1),
    p_hat2 = fitted(model_2),
    p_hat3 = fitted(model_3)
  )

predictions_tidy <- predictions_wide_format %>%
  gather(type, fitted_prob, -c(is_female, orientation, height))





#-------------------------------------------------------------------------------
# For each of our three models, compute
#
# -the proportion of predictions that are wrong
# -the proportion of "female" predictions that are wrong
# -the proportion of "male" predictions that are wrong
#
# Discuss amongst yourselves how you would do this.
#-------------------------------------------------------------------------------

