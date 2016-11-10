library(twitteR)
library(stringr)

# Note the news events below were current as of 2016/4/22!

# Make sure you've run the setup_twitter_oauth() function once first. If you've
# already done this, you may skip this step.
setup_twitter_oauth(
  "API key", 
  "API secret", 
  "Access token", 
  "Access token secret"
)

# R.I.P. Prince:
some_tweets <- searchTwitter("prince", n=100, lang="en")

# The function returns a "list", not a vector, with 100 tweets.  You access them
# individually using [[]] and not [] like with vectors
some_tweets
some_tweets[[1]]

# Andrew Jackson has been in the news of late as he will no longer by on the $20
# bill
some_tweets <- searchTwitter("andrew jackson", n=100, lang="en")
some_tweets

# Check out help file:
?searchTwitter

# We can pull out geo-coded tweets within a certain distance of a long/lat
# point.  Search "37.781157, -122.39720" in google maps to see where the center
# of the search is.
some_tweets <- searchTwitter("prince", n=100, lang="en", 
                             geocode='37.781157,-122.39720,100mi')
some_tweets

# Press tab after the dollar sign to see what info is stored for each list
# element.
some_tweets[[1]]$

# For example, the following lines extract the text and the author
some_tweets[[1]]$text
some_tweets[[1]]$screenName

# If we want to extract the text for each tweet, i.e. each list element, and
# convert this to a vector of strings, we use the sapply() command.  i.e. it
# applies the function we define to each element of the list.
tweets_vector <- sapply(some_tweets, function(x){x$text})
tweets_vector



# EXERCISE:
# Look at the help file ?searchTwitter and toy with the parameters.
# Also toy with the outputs as we did on lines 33-40 using the str_ functions
# from the stringr package.
