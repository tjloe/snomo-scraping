## Project: Snomo-Scraping
## Author: Tyler J. Loewenstein

## Purpose: Generates CSV file containing URLs to use for scraping technical
## specifications of various snowmobile models.

## NOTE: The "host" domain has been redacted to avoid misuse.

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
library(progressr)
library(parallelly)

# Setup for parallel processing
ncores <- availableCores() - 1
plan(multisession, workers = ncores)

# Retrieve URL for each model --------------------------------------------------

# Define function
ScrapeLinks <- function(year){
  
  # check model year is within acceptable range
  if (as.numeric(year) > 2022 | as.numeric(year) < 2016) {
    stop("\"year\" outside acceptable range")
  }
  
  # Say hello to main web page
  host <- # Redacted
  session <- bow(host, force = TRUE) %>% 
    nod(path=paste0(host, year))
  
  # Scrape (politely) for HTML nodes containing snowmobile model name and link
  nodes <- scrape(session) %>% 
    html_elements(
      css = ".wholegood-archive-listing__display-family-model-family-model-wrap"
      )
  
  # Get list of all snowmobile models for given model year
  models <- html_text(nodes) %>% 
    trimws() %>% 
    str_replace_all("\\\"", " in")
  
  # Retrieve all links for each model, adding host domain
  urls <- str_replace_all(host, "/en-us/", "") %>% 
    paste0(html_attr(nodes, "href"))
  
  # Build tbl with model names and links
  tbl <- tibble(year = year, model = models, url = urls)
  return(tbl)
  
}

# Scrape links for models years, combine into one tbl
range <- as.character(c(2016:2022))
with_progress({
  lst <- future_map(range, ScrapeLinks, .options = furrr_options(seed = 1276))})
model_tbl <- bind_rows(lst)

# Write model tbl to disk
# model_tbl %>% write_csv("data/snowmobiles_nospecs.csv")
