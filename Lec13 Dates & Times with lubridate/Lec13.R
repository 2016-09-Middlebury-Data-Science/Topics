library(dplyr)
library(ggplot2)

# Install these packages if you haven't already.
library(Quandl)
library(lubridate)


#-------------------------------------------------------------------------------
# Bitcoin Price vs USD Dollar
# https://www.quandl.com/data/BAVERAGE/USD-USD-BITCOIN-Weighted-Price
#-------------------------------------------------------------------------------
bitcoin <- Quandl("BAVERAGE/USD") %>% tbl_df()
bitcoin

# We rename the variables so that they don't have spaces. You do that as follows
# using ` marks (next to the "1" key):
bitcoin <- rename(bitcoin, Avg = `24h Average`, Total.Volume = `Total Volume`)



#-------------------------------------------------------------------------------
# Exercise for today
#-------------------------------------------------------------------------------
# Run this line, search for "lubridate", and click on HTML to get the "vignette"
# (example file).  You can also browse the source code.
browseVignettes()

# Go over this for today.
