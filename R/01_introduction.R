# priceR - Economics and pricing in R -----
library(priceR)
library(tidyverse)
library(ggthemes)
library(ggrepel)
source("R/utils.R")
options(scipen = 100, digits = 6)
Sys.getenv("EXCHANGERATEHOST_ACCESS_KEY")
fig_path <- "figures/"

## Current exchange rates ----
nrow(currency_info) # 191 currencies
colnames(currency_info)

# Among others, you can see:
# - the ISO 4217 currency codes (https://www.iso.org/iso-4217-currency-codes.html)
# - the currency symbols
# - the sub-units
# - the official name

# Get the current exchange rates in terms of RUB
# exchange_rate_latest(currency = "RUB") |> head(n = 10)

## Historical exchange rates ----
# Retrieve RUB to EUR exchange rates
re <- historical_exchange_rates(
  from = "RUB",
  to = "EUR",
  start_date = "2013-01-01",
  end_date = today()
)

# Retrieve RUB to USD exchange rates
ru <- historical_exchange_rates(
  from = "RUB",
  to = "USD",
  start_date = "2014-01-01",
  end_date = today()
)

# Combine the two historical exchange rate series
cur <- left_join(x = re, y = ru, by = join_by(date)) |> 
  rename(
    rub_to_eur = one_RUB_equivalent_to_x_EUR,
    rub_to_usd = one_RUB_equivalent_to_x_USD
  )

head(cur, n = 10)
# date, one_RUB_equivalent_to_x_EUR, one_RUB_equivalent_to_x_USD

# Plot the full historical exchange rates
cur |>
  pivot_longer(cols = c("rub_to_eur", "rub_to_usd")) |>
  mutate(date = as.Date(date)) |>
  ggplot(mapping = aes(x = date, y = value, color = name)) +
  geom_line(lwd = 1) +
  scale_color_manual(
    breaks = c("rub_to_eur", "rub_to_usd"),
    labels = c("RUB to EUR", "RUB to USD"),
    values = c("#02506A", "#03A5DC")
  ) +
  scale_x_date(date_labels = "%b %Y", date_breaks = "6 months") +
  scale_y_continuous(
    expand = c(0, 0),
    limits = c(0, 0.04)
  ) +
  labs(
    title = "RUB to EUR and USD since 2013",
    subtitle = "Plotting the Russian Ruble against the USD and Euro",
    y = "Exchange rate",
    x = ""
  ) +
  my_theme()

ggsave("rub-to-eur-and-usd.png", path = fig_path, width = 12, height = 8)
graphics.off()

# Plot RUB to EUR for the last 200 days
cur |>
  tail(200) |>
  rename(
    rub_to_eur = one_RUB_equivalent_to_x_EUR,
    rub_to_usd = one_RUB_equivalent_to_x_USD
  ) |>
  mutate(date = as.Date(date)) |>
  ggplot(mapping = aes(x = date, y = rub_to_eur, group = 1)) +
  geom_line(lwd = 1.2, color = "#F15B40") +
  geom_smooth(method = "loess", color = "#03A5DC") +
  scale_x_date(date_labels = "%b %Y", date_breaks = "1 month") +
  labs(
    title = "RUB to EUR over the last 200 days",
    subtitle = "RUB to EUR exchange rate; polynomial regression trendline",
    y = "Exchange rate",
    x = ""
  ) +
  my_theme()

ggsave(filename = "rub-to-eur-last-200-days.png", path = fig_path, width = 12, height = 8)
graphics.off()

# Plot RUB to EUR for the last eight years
cur |>
  tail(365 * 8) |>
  rename(
    rub_to_eur = one_RUB_equivalent_to_x_EUR,
    rub_to_usd = one_RUB_equivalent_to_x_USD
  ) |>
  mutate(date = as.Date(date)) |>
  ggplot(mapping = aes(x = date, y = rub_to_eur, group = 1)) +
  geom_line(lwd = 1.2, color = "#02506A") +
  geom_smooth(method = "loess", color = "#03A5DC", se = TRUE) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
  labs(
    title = "RUB to EUR over last 8 years",
    subtitle = "RUB to EUR exchange rate; polynomial regression trendline",
    y = "Exchange rate",
    x = ""
  ) +
  my_theme()

ggsave(filename = "rub-to-eur-last-8-years.png", width = 8, height = 4)
graphics.off()


## Inflation ----
# Adjust prices for inflation
# adjust_for_inflation() automatically converts nominal to real values.
# It currently works with 296 countries
as_tibble(show_countries())

# First we create some nominal prices from random numbers
set.seed(123)

nominal_prices <- rnorm(n = 10, mean = 10, sd = 3)
years          <- round(rnorm(n = 10, mean = 2006, sd = 5))

df <- tibble(years, nominal_prices)

print(df)

df$in_2008_dollars <- adjust_for_inflation(
  price     = nominal_prices,
  from_date = years,
  country   = "US",
  to_date   = 2008
)

print(df)

## Extraction helpers ----
# These helpers let you extract useful *numerical* data from
# messy free text (character) data.

# Extract salary from free text

# extract_salary() extracts salaries as useful numeric data from
# non-standard free text.
messy_salary_data <- c(
  "$90000 - $120000 per annum",
  "$90k - $110k p.a.",
  "$110k - $120k p.a. + super + bonus + benefits",
  "$140K-$160K + Super + Bonus/Equity",
  "$200,000 - $250,000 package",
  "c$200K Package Neg",
  "$700 p/d", # daily
  "$120 - $140 (Inc. Super) per hour", # hourly
  "Competitive" # nothing useful (will return NA)
)

print(messy_salary_data)

messy_salary_data |>
  extract_salary(include_periodicity = TRUE, salary_range_handling = "average")

## Formatting helpers ----
# Neatly format currencies
# format_currency() nicely formats numeric data
format_currency("22500000", "¥")

# format_dollars() does the same but only for USD
format_dollars(c("445.50", "199.99"), digits = 2)

# END