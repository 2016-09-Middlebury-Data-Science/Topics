library(dplyr)
library(ggplot2)
library(forcats)

# This exercise was lifted from the links in the last slide of the Lec10 slides.
# Today's data: a sample of categorical variables from the General Social survey
gss_cat



# Task 1: Change the values of a factor

# We see there are many levels to the religion variable
gss_cat %>%
  count(relig)

# Say we'd rather have the categories be abrahamic religions (judaism,
# christianity, islam) vs other. We can recode the variables using the
# fct_recode() function.
#
# Tip -I used: relig$relig %>% unique() %>% dput()
# to extract the names
gss_cat %>%
  mutate(relig = fct_recode(relig,
                            # New name = old name
                            "abrahamic" = "No answer",
                            "other" = "Don't know",
                            "other" = "Inter-nondenominational",
                            "other" = "Native american",
                            "abrahamic" = "Christian",
                            "abrahamic" = "Orthodox-christian",
                            "abrahamic" = "Moslem/islam",
                            "other" = "Other eastern",
                            "other" = "Hinduism",
                            "other" = "Buddhism",
                            "other" = "Other",
                            "other" = "None",
                            "abrahamic" = "Jewish",
                            "abrahamic" = "Catholic",
                            "abrahamic" = "Protestant",
                            "other" = "Not applicable"
  )) %>%
  count(relig)



# Task 2: Change ordering of factors in a plot

# Let's summarise age and hours of TV watching per religious group
relig <- gss_cat %>%
  group_by(relig) %>%
  summarise(
    age = mean(age, na.rm = TRUE),
    tvhours = mean(tvhours, na.rm = TRUE),
    n = n()
  )
relig

# A raw ggplot is in a super unhelpful order:
ggplot(data=relig, aes(x=tvhours, y=relig)) +
  geom_point()

# Let's reorder the factor variable, relig, by the numerical variable tvhours.
# Much easier to read. Note we could either
# -mutate() the relig variable in the relig data frame first, and then plot
# -or just reorder at plot time
ggplot(data=relig, aes(x=tvhours, y=fct_reorder(relig, tvhours))) +
  geom_point()

# Let's look at the median age for each religious group.
gss_cat %>%
  group_by(relig) %>%
  summarise(median=median(age)) %>%
  arrange(desc(median))

# Whoops, we forgot there are missing values, so let's na.rm them. IMPORTANT
# NOTE: We may be biasing our results by doing this! For example, say older
# people are much more reluctant to share their age, then by sweeping all NA's
# under the rug and treating the median at face value, we may be under-reporting
# the median age!
#
# But for sake of this exercise, let's just push forward. Lots of older hebrews
# and shebrews!
gss_cat %>%
  group_by(relig) %>%
  summarise(median=median(age, na.rm=TRUE)) %>%
  arrange(desc(median))

# A raw geom_boxplot is unsorted, which is a bit jarring
ggplot(data=gss_cat, aes(x=relig, y=age)) +
  geom_boxplot() +
  coord_flip()

# Let's look at the help file for fct_reorder
?fct_reorder

# So let's reorder the boxplots by median: fct_reorder(f=relig, x=age, fun=median)
ggplot(data=gss_cat, aes(x=fct_reorder(f=relig, x=age, fun=median), y=age)) +
  geom_boxplot() +
  coord_flip()

# Wait, why aren't the bars sorted? Recall there were missing values for age!
# The ... in the help file for fct_reorder correspond to extra arguments to whatever
# function you are using. So let's add the na.rm=TRUE
ggplot(data=gss_cat, aes(x=fct_reorder(f=relig, x=age, fun=median, na.rm=TRUE), y=age)) +
  geom_boxplot() +
  coord_flip()

# FANTASTIC!


