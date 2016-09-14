# Load requisite packages
#
# GOOD PRACTICE:
#
# Try to do all the package loading at the beginning of any R script file or
# any .Rmd R Markdown file, so that anyone else who wants to run this analysis
# can see in one shot which packages they will need to install.

# This is good practice so people know which packages they need installed. For
# example, I didn't know I needed a particular package before I boarded a 5 hour
# flight because the package loading was buried deep in the file.
library(dplyr)
library(ggplot2)
library(rvest)




#------------------------------------------------------------------------------
# Solutions to Exercises from Lec02.R
#------------------------------------------------------------------------------
# Function to clean currency entries
currency_to_numeric <- function(x){
  # Convert currencies to numeric i.e. strip dollar signs and commas
  x <- gsub('\\$','', as.character(x))
  x <- gsub('\\,','', as.character(x))
  x <- as.numeric(x)
  return(x)
}

# Load data
webpage <- "http://apps.washingtonpost.com/g/page/local/college-grants-for-the-affluent/1526/"
wp_data <- webpage %>%
  read_html() %>%
  html_nodes("table") %>%
  .[[1]] %>%
  html_table() %>%
  tbl_df()

# Clean data in one shot
wp_data <- wp_data %>%
  rename(
    school = School,
    state = State,
    sector = Sector,
    comp_fee = `Tuition, fees, room and board 2013-14`,
    p_no_need_grant = `Percent of freshmen receiving no-need grants from school`,
    ave_no_need_grant = `Average no-need award to freshmen`,
    p_need_grant = `Percent receiving need-based grants from school`
  ) %>%
  mutate(
    comp_fee = currency_to_numeric(comp_fee),
    ave_no_need_grant = currency_to_numeric(ave_no_need_grant),
    p_need_grant = currency_to_numeric(p_need_grant)
  )


# 1. I want to know which states have the highest average no need grants
# (averaged over schools). Create the smallest data frame (i.e. least number of
# rows, least number of columns) that answers this question.

# We use the group_by() function on the categorical variable state:
wp_data %>%
  group_by(state) %>%
  summarise(state_avg = mean(ave_no_need_grant)) %>%
  arrange(desc(state_avg))

# 2. For southern states, repeat the above exercises without looking at the above code:
# a) Display a list of southern schools, their sector, and the average no need grant,
# sorted in increasing order of the average no need grant.
# b) Compute the mean and median
#   + Percent of freshmen receiving no-need grants from school
#   + Percent receiving need-based grants from school
# for both southern and non-southern schools

# Add south variable
south_states <- c('AL', 'AR', 'FL', 'GA', 'KY', 'LA', 'NC', 'SC', 'TN', 'TX')
wp_data <- wp_data %>%
  mutate(south = ifelse(state %in% south_states, 'south', 'non-south'))

# a) we arrange in increasing order, which is the default
wp_data %>%
  filter(south == "south") %>%
  select(school, sector, ave_no_need_grant) %>%
  arrange(ave_no_need_grant)

# b) Again, we highlight the fact that we are dropping rows with any missing
# value, which might impact any ultimate conclusion.
wp_data %>%
  filter(!is.na(p_no_need_grant)) %>%
  group_by(south) %>%
  summarise_each(
    funs(mean(.), median(.)),
    p_no_need_grant,	p_need_grant)





#------------------------------------------------------------------------------
# Learning the join command
#------------------------------------------------------------------------------
# Let's test out join commands on these data sets.  Setting stringsAsFactors =
# FALSE treats the letters A, B, C, D as character strings, and not factors
# (i.e. categorical variables)
x <- data_frame(x1=c("A","B","C"), x2=c(1,2,3))
y <- data_frame(x1=c("A","B","D"), x3=c(TRUE,FALSE,TRUE))
z <- data_frame(x1=c("B","C","D"), x2=c(2,3,4))

# Look at the data frames
x
y
z

# Compare the outputs of the following 6 commands to the Venn Diagrams from:
# https://twitter.com/yutannihilation/status/551572539697143808
left_join(x, y, by="x1")
right_join(x, y, by="x1")
inner_join(x, y, by="x1")
semi_join(x, y, by="x1")
full_join(x, y, by="x1")
anti_join(x, y, by="x1")

# Other useful set operations (included on your cheat sheet).
intersect(x, z)
union(x, z)
setdiff(x, z)
bind_rows(x, y)
bind_rows(x, x) %>% dplyr::distinct()

# Refresher: we prefaced the distinct() command with dplyr::, indicating that
# this command is from the dplyr package. While not necessary in this case, it
# can be useful when
# -you might have two packages loaded that share function names and you need to
#  specify which one to use
# -to quickly inform other users which package a particular command comes from.





#------------------------------------------------------------------------------
# EXERCISE: Back to Washington Post Data
#------------------------------------------------------------------------------
# Import the states.csv file and look at its contents.
#
# Merge it with the Washington Post data to answer the following questions:
#
# -Which region (south, NE, west, or midwest) has the highest proportion of its
#  colleges being private
# -For each region, compute the values necessary to draw a whisker-less boxplot
#  of the annual tuition fees.

