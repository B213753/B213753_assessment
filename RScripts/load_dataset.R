# Title: load_dataset
# Author details: B213753
# Script and data information: 
# This script will load the target dataset (LOS_model) from the NHSRdatasets 
# package, and save it as a raw csv file in a 'RawData' folder.
# It will then partition the data subset into training and testing data and 
# save them to a working ‘Data’ folder, # ready for downstream exploratory 
# and statistical analysis.
# Data consists of numerical data and character data from NHSRdatasets package.

# R Packages
library(NHSRdatasets)
library(tidyverse)
library(here)
library(knitr)
library(caret)

# Get the data into R environment
data(LOS_model)
LOS <- LOS_model

# Brief overview of data set. No obvious error values (e.g. negative numbers)
glimpse(LOS)
head(LOS)
summary(LOS)

# Check for missing data - none found.
LOS %>% 
  map(is.na) %>% 
  map(sum)

# Recode death from int to factor.
LOS <- LOS %>% 
  mutate(Death=recode(factor(Death),'1'='Died','0'='Alive'))

# There is already ID column that can be used as index for each row.
# So no need to add another for purposes of indexing and splitting the data.

# Tabulate and show first 10 rows.
LOS %>% 
  head(10) %>% 
  kable()

# No further cleaning or transformation required... save as raw csv file.
write_csv(LOS, here("RawData", "LOS_raw.csv"))

# Split into test and training datasets. Select around 10 random rows to be tested.
set.seed(777)
testIndex <- createDataPartition(LOS$ID, p = 10/nrow(LOS), 
                                  list = FALSE, 
                                  times = 1)

LOS_test <- LOS[testIndex,]
LOS_train <- LOS[-testIndex,]

# Save a row for assessment marking
LOS_test_marker <- LOS_test[1,]
LOS_test <- LOS_test[2:nrow(LOS_test),]

# Save test and train datasets as csv into 'Data' folder.
write_csv(LOS_train, here("Data", "LOS_train.csv"))
write_csv(LOS_test, here("Data", "LOS_test.csv"))
write_csv(LOS_test_marker, here("Data", "LOS_test_marker.csv"))

