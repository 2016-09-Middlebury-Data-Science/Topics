# Load dplyr and ggplot2 packages
library(dplyr)
library(ggplot2)



#------------------------------------------------------------------------------
# Solutions to Exercises from Lec01.R
#------------------------------------------------------------------------------
# We load the Motor Trend cars data set.
data(mtcars)
mtcars

# Make the rownames an explicit variable (column) in the data set. The missing
# variable is a flaw in the dataset as originally loaded.
mtcars <- mtcars %>%
  tibble::rownames_to_column() %>%
  rename("make_model" = rowname)


# Using the help file and the commands above, do the following:
# -Identify the cars with 4 forward gears in decreasing order of horse power.
# Don't show all variables, but car make and model name and the horse power.
mtcars %>%
  filter(gear==4) %>%
  arrange(desc(hp)) %>%
  select(make_model, hp)

# Notes:
# -The 1st two lines above are equilavent to
filter(mtcars, gear==4)
# b/c %>% by default pipes to the first argument of the function
# -We then arrange in decreasing order of hp
# -We then select the appropriate columns
# -Also, observe that we are not saving the output of these commands to anything
#  If we want to save this output, we need to save it to a new variable as follows:
car_list <- mtcars %>%
  filter(gear==4) %>%
  arrange(desc(hp)) %>%
  select(make_model, hp)
car_list

# -Compute the average miles per gallon (mpg) for automatic vs manual transmission
# We need to inject a grouping structure to the mtcars data frame via group_by(am)
# which R will treat as a categorical variable with 2 levels.
mtcars %>%
  group_by(am) %>%
  summarize(avg_mpg = mean(mpg))



#------------------------------------------------------------------------------
# More dplyr practice: Financial Aid Data
#------------------------------------------------------------------------------
library(rvest)
webpage <- "http://apps.washingtonpost.com/g/page/local/college-grants-for-the-affluent/1526/"
wp_data <- webpage %>%
  read_html() %>%
  html_nodes("table") %>%
  .[[1]] %>%
  html_table()
View(wp_data)

# Let's view the data in the console
wp_data

# This is unwieldy, so let's convert to tbl_df format so that the output isn't overwhelming
wp_data <- wp_data %>% tbl_df()
wp_data



#------------------------------------------------------------------------------
# Step 0: Data Cleaning
#------------------------------------------------------------------------------
# The column names are a little unwieldy. Let's rename them
# using: rename(data_frame, NEW_NAME = OLD_NAME)
#
# Some of the variable names have spaces, and dealing with spaces in
# programming is a pain in the ass (PITA). Note how we treat the variable names
# that have spaces differently: we surround them with ` (top left of keyboard).
wp_data <- wp_data %>%
  rename(
    school = School,
    state = State,
    sector = Sector,
    comp_fee = `Tuition, fees, room and board 2013-14`,
    p_no_need_grant = `Percent of freshmen receiving no-need grants from school`,
    ave_no_need_grant = `Average no-need award to freshmen`,
    p_need_grant = `Percent receiving need-based grants from school`
  )
wp_data

# All money related values are not numerical variables but rather character
# strings (note the chr under the variables comp_fee and ave_no_need_grant).
# We need to convert these character strings to numerical using a function.
# Don't worry about understanding this function for now, we'll talk about
# manipulating text data later.

currency_to_numeric <- function(x){
  # Convert currencies to numeric i.e. strip dollar signs and commas
  x <- gsub('\\$','', as.character(x))
  x <- gsub('\\,','', as.character(x))
  x <- as.numeric(x)
  return(x)
}
currency_to_numeric("$19,999")

# mutate the data set to change all currency values.
wp_data <- wp_data %>%
  mutate(
    comp_fee = currency_to_numeric(comp_fee),
    ave_no_need_grant = currency_to_numeric(ave_no_need_grant)
  )
wp_data



#------------------------------------------------------------------------------
# Step 1: Creating a new variable
#------------------------------------------------------------------------------
# Now let's say we want to identify which schools are in the northeast i.e.
# create a categorical variable NE with levels: NE and non-NE.
# We define the list of NE states
NE_states <- c("CT", "DC", "DE", "MA", "MD", "ME", "NH", "NJ", "NY", "PA", "RI", "VT")

# A very handy function is the ifelse() function. Take a look at the help file
# for it. Ex:
ifelse(c(TRUE, TRUE, FALSE, TRUE, FALSE), "apple", "orange")

# Also recall the %in% function
c("TX", "VT", "NY", "WA") %in% NE_states

# We combine these two functions to mutate the desired variable
wp_data <- wp_data %>%
  mutate(NE = ifelse(state %in% NE_states, 'NE', 'non-NE'))
wp_data



#------------------------------------------------------------------------------
# Step 2: arrange() and select()
#------------------------------------------------------------------------------
# Arranging/sorting the data by region (NE)
# First let's sort the data by the NE region variable
wp_data <- wp_data %>%
  arrange(NE)
wp_data

# The default for arrange is ascending, let's put that in descending order instead
wp_data <- wp_data %>%
  arrange(desc(NE))
wp_data

# It might be more useful to sort the data by multiple variables
wp_data <- wp_data %>%
  arrange(desc(NE), ave_no_need_grant)
wp_data

# We can also create a NEW data frame with just these variables while executing this code.
# What important information is missing?
wp_data %>%
  arrange(desc(NE), ave_no_need_grant) %>%
  select(NE, ave_no_need_grant)

# Oops we forgot to include school name and sector
wp_data %>%
  arrange(desc(NE), ave_no_need_grant) %>%
  select(school, sector, NE, ave_no_need_grant)



#------------------------------------------------------------------------------
# Step 3: summarise() and filter()
#------------------------------------------------------------------------------
# Find the mean and standard deviation of each variable by region (NE)
wp_data %>%
  group_by(NE) %>%
  summarise(mean_merit = mean(ave_no_need_grant))

# summarise_each() is like summarise(), allows you to apply
# -multiple functions on
# -multiple columns
wp_data %>%
  group_by(NE) %>%
  summarise_each(
    funs(mean(.), median(.)),
    p_no_need_grant,	p_need_grant)

# Why the NA's? This how R treats missing data. Let's see which schools have
# missing values for p_no_need_grant is the is.na() function
wp_data %>%
  filter(is.na(p_no_need_grant))

# One way to deal with missing data is to simply eliminate rows that have them.
# DANGER: this may have implications for your analysis, especially if there is
# a systematic reason these values are missing? Maybe these schools have a very
# particular financial aid system, and don't want to share this info. Always
# think carefully before sweeping missing values under the rug, and be sure
# to acknowledge this in your reports.

# We repeat the above, but removing rows with missing values by setting
# !is.na().  The ! means "not".  i.e. not missing
wp_data %>%
  filter(!is.na(p_no_need_grant)) %>%
  group_by(NE) %>%
  summarise_each(
    funs(mean(.), median(.)),
    p_no_need_grant,	p_need_grant)




#------------------------------------------------------------------------------
# Exercise02
#------------------------------------------------------------------------------
# 1. I want to know which states have the highest average no need grants (averaged
# over schools). Create the smallest data frame (i.e. least number of rows, least number of
# columns) that answers this question.

# 2. For southern states, repeat the above exercises without looking at the above code:
# -Display a list of southern schools, their sector, and the average no need grant,
# sorted in increasing order of the average no need grant.
# -Compute the mean and median
#   + Percent of freshmen receiving no-need grants from school
#   + Percent receiving need-based grants from school
# for both southern and non-southern schools
south_states <- c('AL', 'AR', 'FL', 'GA', 'KY', 'LA', 'NC', 'SC', 'TN', 'TX')
