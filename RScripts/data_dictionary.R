# Title: data_dictionary.R
# Author details: B213753
# Script and data information: 
# This script will load the dataset collected using the data collection tool.
# It will then build a data dictionary in R using the dataMeta package and append
# the dictionary onto the dataset metadata.
# Data consists of numerical data and character data from NHSRdatasets package.

library(dataMeta)
library (tidyverse)
library(here)

# Read collected data
CollectedData=read_csv(here("RawData", "CollectedDataFinal.csv"))

glimpse(CollectedData)

# Create linker dataframe
variable_description <- c(
  'Integer value representing patient number - should be unique and allows referencing rows to the original raw data.',
  'A factor consisting of a string that represents a hospital or organisation e.g. "Trust1"',
  'Integer value representing age of the patient.',
  'Integer value representing the days a patient was in hospital.',
  'A factor consisting of a string that is either "Alive" or "Died", representing the status of the patient at the end of their hospital stay.',
  'A boolean value representing the consent from the end-user to process and share the data collected with the data capture tool.'
)
variable_type <- c(0,1,0,0,1,1)

linker<-build_linker(CollectedData, variable_description, variable_type)
linker

# Build dictionary
dictionary <- build_dict(my.data = CollectedData, linker = linker)

glimpse(dictionary)

# Add notes
dictionary[3,4]<-'Alive: The patient survived the hospital admission.'
dictionary[4,4]<-'Died: The patient died during hospital admission.'
dictionary[7,4]<-'Trust3: Name of hospital/organisation that admitted patient.'
dictionary[8,4]<-'Trust9: Name of hospital/organisation that admitted patient.'
dictionary[9,4]<-'Trust6: Name of hospital/organisation that admitted patient.'
dictionary[10,4]<-'Trust2: Name of hospital/organisation that admitted patient.'
dictionary[11,4]<-'Trust4: Name of hospital/organisation that admitted patient.'
dictionary[12,4]<-'Trust5: Name of hospital/organisation that admitted patient.'
dictionary[13,4]<-'Trust7: Name of hospital/organisation that admitted patient.'
dictionary[14,4]<-'Trust10: Name of hospital/organisation that admitted patient.'

# Save dictionary
write_csv(dictionary, here("RawData", "CollectedData_DataDictionary.csv"))

# Append dictionary onto main collected data.
main_string <- "This data describes the hospital length of stay (LOS) and outcome (death/survived) data from the *NHSRdatasets* package collected by the data capture tool."

complete_CollectedData <- incorporate_attr(my.data = CollectedData, 
                                           data.dictionary = dictionary,
                                           main_string = main_string)

# Change the author name
attributes(complete_CollectedData)$author[1]<-"B213753"

attributes(complete_CollectedData)

# Save as rds file
save_it(complete_CollectedData, here("RawData", "complete_CollectedData"))






