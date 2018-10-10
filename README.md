
<!-- README.md is generated from README.Rmd. Please edit that file -->
FromQuandl
==========

The goal of FromQuandl is to easy the search, download and data preprocessing that often happen when using the `Quandl` package in R.

Installation
------------

You can install FromQuandl from github with:

``` r
# install.packages("devtools")
devtools::install_github("Reckziegel/FromQuandl")
```

Example2
--------

Suppose you would like to download the Current Account Balance (as % of GDP) for all countries of a specific region or with a similar economic characteristic, like the G7, for example. Use the `imf_search()` function to discover the Current Accounts code.

``` r
library(FromQuandl)
imf_search('account')
#> # A tibble: 2 x 2
#>   indicator                             code     
#>   <chr>                                 <chr>    
#> 1 current account balance, % of gdp     BCA_NGDPD
#> 2 current account balance, usd billions BCA
```

Next use `imf_from_quandl()` to download this data.

``` r
library(FromQuandl)
ca <- imf_from_quandl(countries = 'g7', indicators = 'BCA_NGDPD', start_date = '2008-01-01')
ca
#> # A tibble: 105 x 6
#>    date       iso   country indicator  value name                         
#>    <date>     <fct> <fct>   <fct>      <dbl> <fct>                        
#>  1 2008-12-31 CAN   Canada  BCA_NGDPD  0.099 Current Account Balance, % o~
#>  2 2009-12-31 CAN   Canada  BCA_NGDPD -2.95  Current Account Balance, % o~
#>  3 2010-12-31 CAN   Canada  BCA_NGDPD -3.61  Current Account Balance, % o~
#>  4 2011-12-31 CAN   Canada  BCA_NGDPD -2.77  Current Account Balance, % o~
#>  5 2012-12-31 CAN   Canada  BCA_NGDPD -3.60  Current Account Balance, % o~
#>  6 2013-12-31 CAN   Canada  BCA_NGDPD -3.22  Current Account Balance, % o~
#>  7 2014-12-31 CAN   Canada  BCA_NGDPD -2.43  Current Account Balance, % o~
#>  8 2015-12-31 CAN   Canada  BCA_NGDPD -3.40  Current Account Balance, % o~
#>  9 2016-12-31 CAN   Canada  BCA_NGDPD -3.34  Current Account Balance, % o~
#> 10 2017-12-31 CAN   Canada  BCA_NGDPD -2.92  Current Account Balance, % o~
#> # ... with 95 more rows
```

The result is a `tibble` that it's ready to be used in `ggplot2`.

``` r
library(ggplot2)
library(ggthemes)

ca %>%
  ggplot(aes(date, value, color = country)) + 
  geom_line(size = 1, show.legend = FALSE) + 
  geom_hline(aes(yintercept = 0), color = 'red', linetype = 'dashed', alpha = 0.3) + 
  facet_wrap(~country, scale = "free_y") + 
  labs(title    = "Current Account Balance (% of GDP)",
       subtitle = "G7 Countries From 2005-01-01 through 2018-09-10",
       caption  = "Source: International Monetary Found (IMF).") + 
  theme_fivethirtyeight() + 
  scale_color_gdocs()
```

![](README-example2-1.png)

There is no need to restrict the download to only one indicator, just add a vector or a list of characters strings in the `indicators` argument and the function will work in the same way. But be aware that may be safe using `Quandl.api_key()` if you want to get too many series.

As a second example imagine that you want to plot the poverty statistics from the World Bank for all countries in the Commonwealth of Independent States. Simply run

``` r
library(FromQuandl)
library(ggplot2)
library(ggthemes)

# download the data
poverty <- wb_from_quandl('cis', 'poverty')
poverty
#> # A tibble: 367 x 4
#>    date       country indicator                                       value
#>    <date>     <fct>   <fct>                                           <dbl>
#>  1 1996-12-31 Albania Number of poor at $1.25 a day (PPP) (millions)  0.495
#>  2 2002-12-31 Albania Number of poor at $1.25 a day (PPP) (millions)  0.450
#>  3 2004-12-31 Albania Number of poor at $1.25 a day (PPP) (millions)  0.390
#>  4 2005-12-31 Albania Number of poor at $1.25 a day (PPP) (millions)  0.337
#>  5 2008-12-31 Albania Number of poor at $1.25 a day (PPP) (millions)  0.179
#>  6 2012-12-31 Albania Number of poor at $1.25 a day (PPP) (millions)  0.194
#>  7 1988-12-31 Algeria Number of poor at $1.25 a day (PPP) (millions) 16.4  
#>  8 1995-12-31 Algeria Number of poor at $1.25 a day (PPP) (millions) 18.5  
#>  9 2000-12-31 Angola  Number of poor at $1.25 a day (PPP) (millions) 61.6  
#> 10 2008-12-31 Angola  Number of poor at $1.25 a day (PPP) (millions) 56.8  
#> # ... with 357 more rows
```

``` r
library(ggplot2)
library(ggthemes)

# If you want a plot
poverty %>%
  ggplot(aes(date, value)) +
  geom_line(aes(color = country), size = 1) +
  facet_wrap(~indicator, ncol = 3) +
  labs(title    = "Commonwealth of Independent States",
       subtitle = "Poverty Indicators From 2005-01-01 through 2018-09-10",
       caption  = "Source: World Bank (WB).",
       x        = "",
       y        = "") +
  theme_tufte() +
  scale_color_brewer(palette = 'Set3')
```

![](README-example%204-1.png)

Future Developments
-------------------

This is a work in progress. Very soon the package will have a function to download the components of the most important stock indexes in US. Suggestions are welcome, :-).
