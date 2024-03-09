# 02 - Converting Between Currencies Using priceR ----
# URL: https://gist.github.com/brshallo/650c1ad3f4bd9b74076592c6bc4ff8ae

# Improved version of blog post: 
# https://www.bryanshalloway.com/2022/06/16/converting-between-currencies-using-pricer/# 
library(priceR)
library(tidyverse)
library(ggthemes)
library(ggrepel)
source("R/utils.R")
options(scipen = 100, digits = 6)
Sys.getenv("EXCHANGERATEHOST_ACCESS_KEY")
fig_path <- "figures/"

# Create rates lookup table

pminmax <- function(x, y) {
  paste(pmin.int(x, y), pmax.int(x, y), sep = ".")
}

from_to_dates_rates <- function(from, to, dates) {
  priceR::historical_exchange_rates(
    from = from,
    to = to,
    start_date = dates[[1]],
    end_date = dates[[2]]
  ) |>
    set_names("date", "rate")
}

convert_currencies <- function(price_from,
                               from,
                               to,
                               date = lubridate::today(),
                               floor_unit = "day") {
  
  
  rates_start <- tibble(
    from = from,
    to = to,
    date = date |> 
      as.Date() |> 
      floor_date(floor_unit)
  ) |> 
    mutate(from_to = pminmax(from, to)) |>
    distinct(from_to, date, .keep_all = TRUE)
  
  # When passing things to the priceR API it is MUCH faster to send over a range
  # of dates rather than doing this individually for each date. Doing such
  # reduces API calls.
  
  rates_end <- rates_start |> 
    group_by(from_to) |> 
    summarise(date_range = list(range(date)),
              from = from[[1]],
              to = to[[1]],
              rates_lookup = pmap(
                .l = list(from, to, date_range),
                .f = from_to_dates_rates
              )
    ) |> 
    select(-date_range) |> 
    unnest(rates_lookup)
  
  rates_lookup <- rates_end |> 
    semi_join(rates_start, "date")
  
  # this step makes it so could convert either "from" or "to" currency
  rates_lookup <- bind_rows(rates_lookup,
                            rates_lookup |>
                              rename(from = to, to = from) |>
                              mutate(rate = 1 / rate)) |> 
    distinct()
  
  tibble(price = price_from, 
         from = from, 
         to = to, 
         date = date) |> 
    left_join(rates_lookup, c("from", "to", "date")) |> 
    mutate(output = price * rate) |> 
    pull(output)
}
