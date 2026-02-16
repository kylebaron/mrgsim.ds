
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mrgsim.ds

<!-- badges: start -->

<!-- badges: end -->

About mrgsim.ds -

## Installation

You can install the development version of mrgsim.ds from
[GitHub](https://github.com/kylebaron/mrgsim.ds) with:

``` r
# install.packages("devtools")
devtools::install_github("kylebaron/mrgsim.ds")
```

## Example

We will illustrate mrgsim.ds by doing a simulation.

``` r
library(mrgsim.ds)
library(dplyr)

mod <- modlib_ds("popex", Req = "IPRED", end = 24)

data <- expand.ev(amt = 100, ID = 1:1000)
```

mrgsim.ds provides a new `mrgsim()` variant - `mrgsim_ds()`:

``` r
out <- mrgsim_ds(mod, data)

out
. Model: popex
. Dim  : 50,000 9
. Files: 1 [1.9 Mb]
.     ID time       GUT     CENT       CL        V       ECL     IPRED        DV
. 1:   1  0.0   0.00000  0.00000 1.072391 24.06577 0.0698906 0.0000000 0.0000000
. 2:   1  0.0 100.00000  0.00000 1.072391 24.06577 0.0698906 0.0000000 0.0000000
. 3:   1  0.5  84.78394 15.04319 1.072391 24.06577 0.0698906 0.6250866 0.6250866
. 4:   1  1.0  71.88317 27.46594 1.072391 24.06577 0.0698906 1.1412864 1.1412864
. 5:   1  1.5  60.94538 37.67428 1.072391 24.06577 0.0698906 1.5654713 1.5654713
. 6:   1  2.0  51.67190 46.01229 1.072391 24.06577 0.0698906 1.9119390 1.9119390
. 7:   1  2.5  43.80947 52.77156 1.072391 24.06577 0.0698906 2.1928054 2.1928054
. 8:   1  3.0  37.14339 58.19913 1.072391 24.06577 0.0698906 2.4183361 2.4183361
```

The output object doesn’t actually carry the simulated data, but rather
a pointer to the data in parquet files on your disk.

``` r
out$files
. [1] "/private/var/folders/zv/v6tkdhrn1_bb1ndrc0c0j31w0000gp/T/RtmpwbZdoE/mrgsims-ds-764077a82b63.parquet"
```

But, we can do a lot of the typical things we would with any mrgsim
output object.

``` r
plot(out)
```

<img src="man/figures/README-plot_head_tail_dim-1.png" alt="" width="100%" />

``` r
head(out)
. # A tibble: 6 × 9
.      ID  time   GUT  CENT    CL     V    ECL IPRED    DV
.   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl> <dbl> <dbl>
. 1     1   0     0     0    1.07  24.1 0.0699 0     0    
. 2     1   0   100     0    1.07  24.1 0.0699 0     0    
. 3     1   0.5  84.8  15.0  1.07  24.1 0.0699 0.625 0.625
. 4     1   1    71.9  27.5  1.07  24.1 0.0699 1.14  1.14 
. 5     1   1.5  60.9  37.7  1.07  24.1 0.0699 1.57  1.57 
. 6     1   2    51.7  46.0  1.07  24.1 0.0699 1.91  1.91
tail(out)
. # A tibble: 6 × 9
.      ID  time      GUT  CENT    CL     V   ECL IPRED    DV
.   <dbl> <dbl>    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
. 1  1000  21.5 2.93e- 9  75.5 0.227  16.6 -1.48  4.53  4.53
. 2  1000  22   1.67e- 9  75.0 0.227  16.6 -1.48  4.50  4.50
. 3  1000  22.5 9.48e-10  74.4 0.227  16.6 -1.48  4.47  4.47
. 4  1000  23   5.39e-10  73.9 0.227  16.6 -1.48  4.44  4.44
. 5  1000  23.5 3.07e-10  73.4 0.227  16.6 -1.48  4.41  4.41
. 6  1000  24   1.75e-10  72.9 0.227  16.6 -1.48  4.38  4.38
dim(out)
. [1] 50000     9
```

This includes coercing to different types of objects. We can get the
usual R data frames

``` r
as_tibble(out)
. # A tibble: 50,000 × 9
.       ID  time   GUT  CENT    CL     V    ECL IPRED    DV
.    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl> <dbl> <dbl>
.  1     1   0     0     0    1.07  24.1 0.0699 0     0    
.  2     1   0   100     0    1.07  24.1 0.0699 0     0    
.  3     1   0.5  84.8  15.0  1.07  24.1 0.0699 0.625 0.625
.  4     1   1    71.9  27.5  1.07  24.1 0.0699 1.14  1.14 
.  5     1   1.5  60.9  37.7  1.07  24.1 0.0699 1.57  1.57 
.  6     1   2    51.7  46.0  1.07  24.1 0.0699 1.91  1.91 
.  7     1   2.5  43.8  52.8  1.07  24.1 0.0699 2.19  2.19 
.  8     1   3    37.1  58.2  1.07  24.1 0.0699 2.42  2.42 
.  9     1   3.5  31.5  62.5  1.07  24.1 0.0699 2.60  2.60 
. 10     1   4    26.7  65.9  1.07  24.1 0.0699 2.74  2.74 
. # ℹ 49,990 more rows
```

Or stay in the arrow ecosystem

``` r
as_arrow_ds(out)
. FileSystemDataset with 1 Parquet file
. 9 columns
. ID: double
. time: double
. GUT: double
. CENT: double
. CL: double
. V: double
. ECL: double
. IPRED: double
. DV: double
. 
. See $metadata for additional Schema metadata
```

We’ve integrated into the dplyr ecosystem as well

``` r
dd <- 
  out %>% 
  group_by(time) %>% 
  summarise(Median = median(IPRED, na.rm = TRUE))
. Warning: median() currently returns an approximate median in Arrow
. This warning is displayed once per session.

dd
. FileSystemDataset (query)
. time: double
. Median: double
. 
. See $.data for the source Arrow object
```

``` r
collect(dd)
. # A tibble: 49 × 2
.     time Median
.    <dbl>  <dbl>
.  1   0    0    
.  2   0.5  0.885
.  3   1    1.55 
.  4   1.5  2.04 
.  5   2    2.38 
.  6   2.5  2.61 
.  7   3    2.76 
.  8   3.5  2.87 
.  9  16.5  2.10 
. 10  17.5  2.01 
. # ℹ 39 more rows
```

This workflow is particularly useful when running replicate simulations
in parallel

``` r
library(future.apply)
. Loading required package: future

plan(multisession, workers = 2L)

out2 <- future_lapply(1:10, \(x) {
  mrgsim_ds(mod, data)  
}, future.seed = TRUE)

out2 <- reduce_ds(out2)

out2
. Model: popex
. Dim  : 500.0K 9
. Files: 10 [18.9 Mb]
.     ID time       GUT     CENT       CL        V       ECL    IPRED       DV
. 1:   1  0.0   0.00000  0.00000 1.323299 15.42988 0.2801279 0.000000 0.000000
. 2:   1  0.0 100.00000  0.00000 1.323299 15.42988 0.2801279 0.000000 0.000000
. 3:   1  0.5  70.76088 28.58579 1.323299 15.42988 0.2801279 1.852625 1.852625
. 4:   1  1.0  50.07102 47.61347 1.323299 15.42988 0.2801279 3.085796 3.085796
. 5:   1  1.5  35.43069 59.92811 1.323299 15.42988 0.2801279 3.883899 3.883899
. 6:   1  2.0  25.07107 67.54079 1.323299 15.42988 0.2801279 4.377272 4.377272
. 7:   1  2.5  17.74051 71.87256 1.323299 15.42988 0.2801279 4.658010 4.658010
. 8:   1  3.0  12.55334 73.92700 1.323299 15.42988 0.2801279 4.791157 4.791157
```

All arrow files are stored in the tempdir in parquet format

``` r
list_temp()
. 11 files [20.8 Mb]
. - mrgsims-ds-764077a82b63.parquet
. - mrgsims-ds-767d41ce9a67.parquet
.    ...
. - mrgsims-ds-767e4ce3313d.parquet
. - mrgsims-ds-767e5e4ca85f.parquet
```

This directory is eventually removed when the R session ends. Tools are
provided to manage the space.

``` r
retain_temp(out2)
. Discarding 1 files.

list_temp()
. 10 files [18.9 Mb]
. - mrgsims-ds-767d41ce9a67.parquet
. - mrgsims-ds-767d4938775a.parquet
.    ...
. - mrgsims-ds-767e4ce3313d.parquet
. - mrgsims-ds-767e5e4ca85f.parquet
```

We also put a finalizer on each object so that, when it goes out of
scope, the files are automatically cleaned up.

``` r
purge_temp()
. Discarding 10 files.

plan(multisession, workers = 2L)

out1 <- mrgsim_ds(mod, data) %>% rename_ds("out1")

out2 <- future_lapply(1:10, \(x) {
  mrgsim_ds(mod, data)  
}, future.seed = TRUE)

out2 <- reduce_ds(out2) %>% rename_ds("out2")

out3 <- mrgsim_ds(mod, data) %>% rename_ds("out3")
```

``` r
list_temp()
. 12 files [22.7 Mb]
. - mrgsims-ds-out1-0001.parquet
. - mrgsims-ds-out2-0001.parquet
.    ...
. - mrgsims-ds-out2-0010.parquet
. - mrgsims-ds-out3-0001.parquet

rm(out2)
```

As soon as the garbage collecter is called, the leftover files are
cleaned up.

``` r
gc()
.           used (Mb) gc trigger  (Mb) limit (Mb) max used  (Mb)
. Ncells 1695819 90.6    2912040 155.6         NA  2912040 155.6
. Vcells 3106010 23.7    8388608  64.0      16384  6728500  51.4

list_temp()
. 2 files [3.8 Mb]
. - mrgsims-ds-out1-0001.parquet
. - mrgsims-ds-out3-0001.parquet
```
