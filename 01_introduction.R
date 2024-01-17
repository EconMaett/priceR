# priceR ----

# Economics and pricing in R

# GitHub: https://github.com/stevecondylios/priceR
# CRAN https://cran.r-project.org/web/packages/priceR/index.html
# Website: https://www.bryanshalloway.com/2022/06/16/converting-between-currencies-using-pricer/#

# The priceR package contains 4 capabilities:

# - Exchange rates - retrieve exchange rates for immediate use

# - Inflation - deflate nominal values to real prices

# - Formatting - handle currencies in written work such as RMarkdown documents


# Previously the package would extract exchange rate data from
# the World Bank (WB) API and from the European Central Bank (ECB)'s
# Statistical Warehouse https://data.ecb.europa.eu/

# Nowadays the data is retrieved from https://exchangerate.host/

# Inflation adjustment calculations are performed according to the
# textbook "Principles of Macroeconomics" by Gregory Mankiw et al. (2014).


## Setup ----

# Go to https://exchangerate.host/ and create a free account.

# The API allows you to 1,000 requests per calendar month.

# Save the API key as "EXCHANGERATEHOST_ACCESS_KEY" in your
# .Renviron file, which you open with a call to
usethis::edit_r_environ()

# Then restart your R session.

# Check if R recognizes the API key with
Sys.getenv("EXCHANGERATEHOST_ACCESS_KEY")


## Installation ----

# The package is available on CRAN

# install.packages("priceR")

library(priceR)

library(tidyverse)

options(scipen = 100, digits = 6)


## Current exchange rates ----

# Get access on 191 currencies
colnames(currency_info)

# Among others, you can see:

# - the ISO 4217 currency codes
#   https://www.iso.org/iso-4217-currency-codes.html

# - the currency symbols

# - the sub-units

# - the official name


# Get the current exchange rates in terms of USD
exchange_rate_latest(currency = "USD") |> 
  head(n = 10)


## Historical exchange rates ----

# Get some currency pairs

# Retrieve AUD to USD exchange rates
au <- historical_exchange_rates(
  from = "AUD",
  to = "USD",
  start_date = "2013-01-01",
  end_date = "2023-06-30"
)


# Retrieve AUD to EUR exchange rates
ae <- historical_exchange_rates(
  from = "AUD",
  to = "EUR",
  start_date = "2013-01-01",
  end_date = "2023-06-30"
)


# Combine the two historical exchange rate series
cur <- au |> 
  left_join(ae, by = "date")

head(cur, n = 10)


# Plot the exchange rate data

library(ggthemes)
library(ggrepel)

cur |> 
  rename(
    aud_to_usd = one_AUD_equivalent_to_x_USD,
    aud_to_eur = one_AUD_equivalent_to_x_EUR
  ) |> 
  pivot_longer(cols = c("aud_to_usd", "aud_to_eur")) |> 
  mutate(date = as.Date(date)) |> 
  ggplot(mapping = aes(x = date, y = value, color = name)) +
  geom_line(linewidth = 1) +
  scale_color_manual(
    breaks = c("aud_to_usd", "aud_to_eur"),
    labels = c("AUD to USD", "AUD to EUR"),
    values = c("#02506A", "#03A5DC")
  ) +
  scale_x_date(date_labels = "%b %Y", date_breaks = "6 months") +
  scale_y_continuous(
    expand = c(0, 0),
    limits = c(0, 1.5)
  ) +
  labs(
    title = "AUD to USD and EUR 2013 to 2023",
    subtitle = "Plotting the Australian Dollar against the USD and Euro",
    y = "Exchange rate",
    x = ""
  ) +
  theme_economist() +
  theme(
    plot.title = element_text(size = 18, margin = margin(0, 0, 8, 0)),
    axis.title.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
    axis.title.y = element_text(vjust = 3.5),
    legend.position = "bottom",
    legend.title = element_blank()
  )


ggsave(filename = "aud-to-usd-and-eur.png", width = 8, height = 4)
graphics.off()


cur |> 
  tail(200) |> 
  rename(
    aud_to_usd = one_AUD_equivalent_to_x_USD,
    aud_to_eur = one_AUD_equivalent_to_x_EUR
  ) |> 
  mutate(date = as.Date(date)) |> 
  ggplot(mapping = aes(x = date, y = aud_to_usd, group = 1)) +
  geom_line(color = "#F15B40") +
  geom_smooth(method = "loess", color = "#03A5DC") +
  scale_x_date(date_labels = "%b %Y", date_breaks = "1 month") +
  labs(
    title = "AUD to USD over the last 200 days",
    subtitle = "AUD to USD exchange rate; polynomial regression trendline",
    y = "Exchange rate", 
    x = ""
  ) +
  theme_economist() +
  theme(
    plot.title = element_text(size = 18, margin = margin(0, 0, 8, 0)),
    axis.title.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
    axis.title.y = element_text(vjust = 3.5),
    legend.position = "bottom",
    legend.title = element_blank()
  )

ggsave(filename = "aud-to-usd-last-200-days.png", width = 8, height = 4)
graphics.off()


cur |> 
  tail(365 * 8) |> 
  rename(
    aud_to_usd = one_AUD_equivalent_to_x_USD,
    aud_to_eur = one_AUD_equivalent_to_x_EUR
    ) |> 
  mutate(date = as.Date(date)) |> 
  ggplot(mapping = aes(x = date, y = aud_to_eur, group = 1)) +
  geom_line() +
  geom_smooth(method = 'loess', se = TRUE) + 
  geom_line(colour = "#02506A") +
  geom_smooth(method = 'loess', colour="#03A5DC") + 
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
  labs(
    title = "AUD to EUR over last 8 years",
    subtitle = "AUD to EUR exchange rate; polynomial regression trendline",
    y = "Exchange rate",
    x = ""
  ) +
  theme_economist() + 
  theme(
    plot.title = element_text(size = 18, margin = margin(0, 0, 8, 0)),
    axis.title.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
    axis.title.y = element_text(vjust = 3.5),
    legend.position="bottom",
    legend.title = element_blank()
  )

ggsave(filename = "aud-to-eur-last-8-years.png", width = 8, height = 4)
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

df <- data.frame(years, nominal_prices)

print(df)

df$in_2008_dollars <- adjust_for_inflation(
  price = nominal_prices, 
  from_date = years, 
  country = "US", 
  to_date = 2008
  )

print(df)


## Extraction helpers ----

# These helpers let you extract useful *numerical* data from
# messy free text (character) data.

# Extract salary from free text

# extract_salary() extracts salaries as useful numeric data from
#non-standard free text.

messy_salary_data <- c(
  "$90000 - $120000 per annum",
  "$90k - $110k p.a.",
  "$110k - $120k p.a. + super + bonus + benefits",
  "$140K-$160K + Super + Bonus/Equity",
  "$200,000 - $250,000 package",
  "c$200K Package Neg",
  "$700 p/d",                            # daily
  "$120 - $140 (Inc. Super) per hour",  # hourly
  "Competitive"                         # nothing useful (will return NA)
)

print(messy_salary_data)

messy_salary_data |> 
  extract_salary(
    include_periodicity = TRUE, 
    salary_range_handling = "average"
    )


## Formatting helpers ----

# Neatly format currencies

# format_currency() nicely formats numeric data
format_currency("22500000", "¥")

# format_dollars() does the same but only for USD
format_dollars(c("445.50", "199.99"), digits = 2)
