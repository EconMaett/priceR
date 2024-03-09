# priceR

Retrieve exchange rates from https://exchangerate.host/.

The `priceR` R package is maintained by [stevecondylios](https://github.com/stevecondylios) and available on [CRAN](https://cran.r-project.org/web/packages/priceR/index.html) and [GitHub](https://github.com/stevecondylios/priceR).

The blog post [Convertinb Between Currencies Using priceR](https://www.bryanshalloway.com/2022/06/16/converting-between-currencies-using-pricer/) by Bryan Shalloway provides a useful instruction.

The package provides helpers for:
  - Exchange rates: Retrieve exchange rates for immediate use
  - Inflation: Deflate nominal values to real prices
  - Formatting: Handle currencies in written work like RMarkdown

Previous versions of the package relied on the World Bank (WB) API and the European Central Bank (ECB)'s Statistical Warehouse https://data.ecb.europa.eu/.

The latest versions of the package retrieve all data from https://exchangerate.host/.

Inflation adjustment calculations are performed according to the textbook "Principles of Macroeconomics" by Gregory Mankiw et al. (2014).

The package follows the [ISO 4217 currency codes](https://www.iso.org/iso-4217-currency-codes.html).

## Setup

  1. Go to https://exchangerate.host/ and create a free account.
     The API allows you to 100 requests per calendar month.

  2. Save the API key as `EXCHANGERATEHOST_ACCESS_KEY` in your `.Renviron` file, which you open with a call to `usethis::edit_r_environ()`

  3. Then restart your R session.

  4. Check if R recognizes the API key with a call to `Sys.getenv("EXCHANGERATEHOST_ACCESS_KEY")`.
  
  5. Then install the R package with `install.packages("priceR")` and load it with `library(priceR)`

## Citation

Condylios S (2023). _priceR: Economics and Pricing Tools_. R package version 1.0.1,
<https://CRAN.R-project.org/package=priceR>.