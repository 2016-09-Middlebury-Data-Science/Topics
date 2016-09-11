# Load dplyr and ggplot2 packages
library(dplyr)
library(ggplot2)

#------------------------------------------------------------------------------
# dplyr: Viewing data
#------------------------------------------------------------------------------
# We're going to work with the diamonds and mtcars data set. Note that the 
# diamonds data frame is in tidy format: rows are observations, columns are 
# variables, and the table contains a single type of observational unit. Ex: it
# doesn't mix diamonds and rings.
data(diamonds)
diamonds

# Some other useful viewing tools.  The View command is the same as going to the
# Environment panel in RStudio and clicking on the name of a variable: it shows
# it in spreadsheet format.
glimpse(diamonds)
View(diamonds)

# One of your best friends going forth: the help file. Ex: the help file for the
# glimpse command.
?glimpse


#------------------------------------------------------------------------------
# The 5 "verbs" of data manipulation and piping
#------------------------------------------------------------------------------
# Look at the dplyr version of the help file.
?filter

# Filter out ROWS so that only those of "Ideal" cut remain.
# NOTE:  equality in computer programming is with a "==" and not "="
filter(diamonds, cut == "Ideal")
filter(diamonds, cut == "Ideal", color == "E")
filter(diamonds, cut == "Ideal", color == "E" | color == "I")
filter(diamonds, price >= 326)
filter(diamonds, price >= 326 & price <= 350)

# Select columns i.e. variables
?select
select(diamonds, carat)
select(diamonds, carat, x)
# What do you think the minus does?
select(diamonds, -x, -y, -z)

# Arrange. Look at the dplyr version of a the arrange help file
?arrange
arrange(diamonds, price)
arrange(diamonds, desc(price))
# What do you think this does?
arrange(diamonds, desc(cut), carat)

# mutate. What's the difference between these two?
mutate(diamonds, price.squared=price^2)
transmute(diamonds, price.squared=price^2)

# summarise
summarise(diamonds, mean(price), sd(price))
summarise(diamonds, mean=mean(price), sd=sd(price))
# This gives an error:
summarise(diamonds, mean price=mean(price), sd=sd(price))
# You need to treat mean price as a string:
summarise(diamonds, "mean price"=mean(price), sd=sd(price))




#------------------------------------------------------------------------------
# Piping
#------------------------------------------------------------------------------
# Now for an example of "piping" using the "then" command
# NOTE:  when piping, we assume what gets piped goes into the first argument
# of the next command.  i.e. note how we don't indicate the data set 
# is diamond on the second line
filter(diamonds, cut == "Ideal")
filter(diamonds, cut == "Ideal") %>% select(carat, price)
filter(diamonds, cut == "Ideal") %>% select(carat, price) %>% arrange(carat, price)

# We can also pipe to a specific spot using the period. Useful when we want to 
# pipe the previous output to somewhere other than the first argument. Ex:
# the lm() linear regression command
filter(diamonds, cut == "Ideal") %>% lm(price~carat, data=.)

# You can also stagger commands across multiple lines to make it easier to read.
# Say out loud what happening:  take diamonds, filter to keep only those with ideal
# cut THEN select ...
filter(diamonds, cut == "Ideal") %>%
  select(carat, price) %>%
  arrange(carat, price)

# See how the above would look if you didn't use piping!  What a nightmare!
arrange(select(filter(diamonds, cut == "Ideal"), carat, price), carat, price)




#------------------------------------------------------------------------------
# Grouping via group_by()
#------------------------------------------------------------------------------
# This is a very VERY convenient feature of dplyr since we are often not
# interested in summarizing variables across all observations, but for groups of
# observations. You can "group by" a categorical variable
data(Titanic)
Titanic <- as.data.frame(Titanic)
Titanic

# Say your group of interest is the categorical variable "Survived". Note now the
# output says there is a Groups: Survived grouping
group_by(Titanic, Survived)

# The following sums the "Freq" variable but keeps the grouping varible
# "Survived" i.e. it "collapses" or "aggregates" over the rest
group_by(Titanic, Survived) %>% summarise(sum(Freq))

# Same but give the new variable the name "count"
group_by(Titanic, Survived) %>% summarise(Count=sum(Freq))

# Now group by the variable "Class" as well. i.e. collapse over the rest
group_by(Titanic, Survived, Class) %>% summarise(Count=sum(Freq))




#------------------------------------------------------------------------------
# Exercise
#------------------------------------------------------------------------------
# We load the Motor Trend cars data set.
data(mtcars)
mtcars

# Make the rownames an explicit variable (column) in the data set. The missing
# variable is a flaw in the dataset as originally loaded.
mtcars <- mtcars %>% 
  add_rownames() %>% 
  rename("make_model"=rowname)


# Using the help file and the commands above, do the following:
# -Identify the cars with 4 forward gears in decreasing order of horse power.
# Don't show all variables, but car make and model name and the horse power.
# -Compute the average miles per gallon (mpg) for automatic vs manual transmission

