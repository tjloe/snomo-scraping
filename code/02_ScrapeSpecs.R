## Project: Snomo-Scraping
## Author: Tyler J. Loewenstein

## Purpose: Uses web scraped data to build table of snowmobile models with
## technical specifications.

# Setup ------------------------------------------------------------------------

# Packages
library(polite)
library(rvest)
library(dplyr)
library(tidyr)
library(readr)
library(purrr)
library(furrr)
library(stringr)
library(janitor)
library(readxl)
library(progressr)
library(parallelly)

# Setup for parallel processing
ncores <- availableCores() - 1
plan(multisession, workers = ncores)

# Scrape each page for individual model specs ----------------------------------

# Define function for to scrape specs
ScrapeSpecs <- function(url){
  
  # Say hello to main web page
  session <- bow(url)
  
  # Scrape page for vector with snowmobile specs
  specs <- scrape(session) %>%
    html_nodes(".col-sm-6") %>%
    html_text()
  
  # Separate spec names from spec values
  name <- specs[seq(1, length(specs), 2)]
  value <- specs[seq(2, length(specs), 2)]
  tbl <- tibble(name, value)
  
  # Print
  return(tbl)
  
}

# Set up new function to run ScrapeSpecs in parallel
Links2Specs <- function(x){
  p <- progressor(along = x) 
  future_map(x, ~{
    p()
    ScrapeSpecs(.x)
  },
  .options = furrr_options(seed = 1276))
}

# Load model names with URLs
models <- read_csv("data/snowmobiles_nospecs.csv", show_col_types = FALSE)
links <- models$url

# Scrape each link for specs with progress updates
with_progress({
  df_lst <- Links2Specs(links)
})
names(df_lst) <- links

# Merge and tidy up specs ------------------------------------------------------

# Remove duplicated specs within a single model
df_lst_cln <- future_map(df_lst, ~ summarize(group_by(., name), value = first(value)))

# Convert each item into a single row, then bind together
sno <- future_map_dfr(df_lst_cln, ~ pivot_wider(., names_repair = "minimal"), .id = "url")

# Combine redundant cols with different names, tidy up NAs, and add models names
sno_cln <- sno %>%
  clean_names() %>% 
  mutate(handlebar = coalesce(handlebar_hooks, handlebar_type),
                 passenger_seat = coalesce(seat_support_with_luggage, passenger_seat),
                 engine_type = coalesce(engine_type, engine_type_cooling),
                 storage = coalesce(storage, storage_system),
                 fuel_system = coalesce(fuel_system_battery),
                 .keep = "unused") %>% 
  mutate(across(where(is_character), ~ recode(., "N/A" = "Not Applicable"))) %>% 
  mutate(across(where(is_character), ~ replace_na(., "Unknown"))) %>% 
  left_join(models, by = "url") %>% 
  select(year, model, url, everything())

# Write to disk
# sno_cln %>% write_excel_csv("data/snowmobiles.csv")
