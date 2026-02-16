
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
. 1:   1  0.0   0.00000  0.00000 2.064612 26.25991 0.7249425 0.0000000 0.0000000
. 2:   1  0.0 100.00000  0.00000 2.064612 26.25991 0.7249425 0.0000000 0.0000000
. 3:   1  0.5  88.21274 11.55383 2.064612 26.25991 0.7249425 0.4399798 0.4399798
. 4:   1  1.0  77.81488 21.30040 2.064612 26.25991 0.7249425 0.8111376 0.8111376
. 5:   1  1.5  68.64264 29.46990 2.064612 26.25991 0.7249425 1.1222393 1.1222393
. 6:   1  2.0  60.55156 36.26473 2.064612 26.25991 0.7249425 1.3809925 1.3809925
. 7:   1  2.5  53.41419 41.86281 2.064612 26.25991 0.7249425 1.5941720 1.5941720
. 8:   1  3.0  47.11812 46.42045 2.064612 26.25991 0.7249425 1.7677308 1.7677308
```

The output object doesn’t actually carry the simulated data, but rather
a pointer to the data in parquet files on your disk.

``` r
out$files
. [1] "/private/var/folders/zv/v6tkdhrn1_bb1ndrc0c0j31w0000gp/T/Rtmp84CDe9/mrgsims-ds-74a86ffd2ab7.parquet"
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
.      ID  time   GUT  CENT    CL     V   ECL IPRED    DV
.   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
. 1     1   0     0     0    2.06  26.3 0.725 0     0    
. 2     1   0   100     0    2.06  26.3 0.725 0     0    
. 3     1   0.5  88.2  11.6  2.06  26.3 0.725 0.440 0.440
. 4     1   1    77.8  21.3  2.06  26.3 0.725 0.811 0.811
. 5     1   1.5  68.6  29.5  2.06  26.3 0.725 1.12  1.12 
. 6     1   2    60.6  36.3  2.06  26.3 0.725 1.38  1.38
tail(out)
. # A tibble: 6 × 9
.      ID  time      GUT  CENT    CL     V    ECL IPRED    DV
.   <dbl> <dbl>    <dbl> <dbl> <dbl> <dbl>  <dbl> <dbl> <dbl>
. 1  1000  21.5 1.08e-10  56.5 0.842  30.5 -0.172  1.85  1.85
. 2  1000  22   5.70e-11  55.7 0.842  30.5 -0.172  1.82  1.82
. 3  1000  22.5 3.00e-11  55.0 0.842  30.5 -0.172  1.80  1.80
. 4  1000  23   1.58e-11  54.2 0.842  30.5 -0.172  1.77  1.77
. 5  1000  23.5 8.33e-12  53.5 0.842  30.5 -0.172  1.75  1.75
. 6  1000  24   4.39e-12  52.7 0.842  30.5 -0.172  1.73  1.73
dim(out)
. [1] 50000     9
```

This includes coercing to different types of objects. We can get the
usual R data frames

``` r
as_tibble(out)
. # A tibble: 50,000 × 9
.       ID  time   GUT  CENT    CL     V   ECL IPRED    DV
.    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
.  1     1   0     0     0    2.06  26.3 0.725 0     0    
.  2     1   0   100     0    2.06  26.3 0.725 0     0    
.  3     1   0.5  88.2  11.6  2.06  26.3 0.725 0.440 0.440
.  4     1   1    77.8  21.3  2.06  26.3 0.725 0.811 0.811
.  5     1   1.5  68.6  29.5  2.06  26.3 0.725 1.12  1.12 
.  6     1   2    60.6  36.3  2.06  26.3 0.725 1.38  1.38 
.  7     1   2.5  53.4  41.9  2.06  26.3 0.725 1.59  1.59 
.  8     1   3    47.1  46.4  2.06  26.3 0.725 1.77  1.77 
.  9     1   3.5  41.6  50.1  2.06  26.3 0.725 1.91  1.91 
. 10     1   4    36.7  52.9  2.06  26.3 0.725 2.02  2.02 
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
.  2   0.5  0.926
.  3   1    1.59 
.  4   1.5  2.07 
.  5   2    2.43 
.  6   2.5  2.69 
.  7   3    2.85 
.  8   3.5  2.94 
.  9  16.5  2.13 
. 10  17.5  2.05 
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
.     ID time       GUT     CENT        CL        V        ECL    IPRED       DV
. 1:   1  0.0   0.00000  0.00000 0.7738041 20.88353 -0.2564365 0.000000 0.000000
. 2:   1  0.0 100.00000  0.00000 0.7738041 20.88353 -0.2564365 0.000000 0.000000
. 3:   1  0.5  85.17372 14.68615 0.7738041 20.88353 -0.2564365 0.703241 0.703241
. 4:   1  1.0  72.54562 26.92531 0.7738041 20.88353 -0.2564365 1.289309 1.289309
. 5:   1  1.5  61.78980 37.08523 0.7738041 20.88353 -0.2564365 1.775812 1.775812
. 6:   1  2.0  52.62867 45.47903 0.7738041 20.88353 -0.2564365 2.177747 2.177747
. 7:   1  2.5  44.82579 52.37334 0.7738041 20.88353 -0.2564365 2.507878 2.507878
. 8:   1  3.0  38.17979 57.99515 0.7738041 20.88353 -0.2564365 2.777077 2.777077
```

All arrow files are stored in the tempdir in parquet format

``` r
list_temp()
. 11 files [20.8 Mb]
. - mrgsims-ds-74a86ffd2ab7.parquet
. - mrgsims-ds-74fa2e62a152.parquet
.    ...
. - mrgsims-ds-74fb50448f34.parquet
. - mrgsims-ds-74fb58f1b0ee.parquet
```

This directory is eventually removed when the R session ends. Tools are
provided to manage the space.

``` r
retain_temp(out2)
. Discarding 1 files.
list_temp()
. 10 files [18.9 Mb]
. - mrgsims-ds-74fa2e62a152.parquet
. - mrgsims-ds-74fa30c69370.parquet
.    ...
. - mrgsims-ds-74fb50448f34.parquet
. - mrgsims-ds-74fb58f1b0ee.parquet
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
. Ncells 1695816 90.6    2912034 155.6         NA  2912034 155.6
. Vcells 3106005 23.7    8388608  64.0      16384  6728335  51.4
list_temp()
. 2 files [3.8 Mb]
. - mrgsims-ds-out1-0001.parquet
. - mrgsims-ds-out3-0001.parquet
```
