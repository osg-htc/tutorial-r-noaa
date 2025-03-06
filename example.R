#!/usr/bin/env Rscript

library(glue)
library(tidyverse)

# Load useful functions from my_functions.R :
#   - extract_temps_data()
#   - identify_seasons()
#   - create_histogram
source('my_functions.R')

# Read in arguments
args <- commandArgs(trailingOnly = TRUE)

# Get station ID from argument
station_id <- args[1]

# Read data from file
station_data_filename <- glue('{station_id}.csv')
station_df <- read_csv(station_data_filename, col_names=TRUE)

# Extract Min, Max Temperatures (in Fahrenheit)
temps_df <- extract_temps_data(station_df)
rm(station_df)

# Print summary of dataframe
summary(temps_df)

# Add "SEASON" column to label the meteorological season each date occurred in
temps_df <- temps_df %>% identify_seasons()

create_histogram(temps_df, station_id)

