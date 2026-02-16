
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

mod <- modlib_ds("popex", end = 240, outvars = c("CL,CENT,IPRED"))

data <- expand.ev(amt = 100, ii = 24, total = 6, ID = 1:1000)
```

mrgsim.ds provides a new `mrgsim()` variant - `mrgsim_ds()`:

``` r
out <- mrgsim_ds(mod, data)

out
. Model: popex
. Dim  : 482.0K 5
. Files: 1 [8 Mb]
.     ID time     CENT       CL     IPRED
. 1:   1  0.0  0.00000 1.151629 0.0000000
. 2:   1  0.0  0.00000 1.151629 0.0000000
. 3:   1  0.5 16.74061 1.151629 0.5493976
. 4:   1  1.0 30.33797 1.151629 0.9956393
. 5:   1  1.5 41.32930 1.151629 1.3563553
. 6:   1  2.0 50.16086 1.151629 1.6461919
. 7:   1  2.5 57.20341 1.151629 1.8773161
. 8:   1  3.0 62.76491 1.151629 2.0598348
```

The output object doesn’t actually carry the simulated data, but rather
a pointer to the data in parquet files on your disk.

``` r
out$files
. [1] "/private/var/folders/zv/v6tkdhrn1_bb1ndrc0c0j31w0000gp/T/RtmpGELVzL/mrgsims-ds-7eca78ffa049.parquet"
```

But, we can do a lot of the typical things we would with any mrgsim
output object.

``` r
plot(out)
```

<img src="man/figures/README-plot_head_tail_dim-1.png" alt="" width="100%" />

``` r
head(out)
. # A tibble: 6 × 5
.      ID  time  CENT    CL IPRED
.   <dbl> <dbl> <dbl> <dbl> <dbl>
. 1     1   0     0    1.15 0    
. 2     1   0     0    1.15 0    
. 3     1   0.5  16.7  1.15 0.549
. 4     1   1    30.3  1.15 0.996
. 5     1   1.5  41.3  1.15 1.36 
. 6     1   2    50.2  1.15 1.65
tail(out)
. # A tibble: 6 × 5
.      ID  time  CENT    CL IPRED
.   <dbl> <dbl> <dbl> <dbl> <dbl>
. 1  1000  238.  5.10 0.817 0.216
. 2  1000  238   5.01 0.817 0.212
. 3  1000  238.  4.93 0.817 0.208
. 4  1000  239   4.84 0.817 0.205
. 5  1000  240.  4.76 0.817 0.201
. 6  1000  240   4.68 0.817 0.198
dim(out)
. [1] 482000      5
```

This includes coercing to different types of objects. We can get the
usual R data frames

``` r
as_tibble(out)
. # A tibble: 482,000 × 5
.       ID  time  CENT    CL IPRED
.    <dbl> <dbl> <dbl> <dbl> <dbl>
.  1     1   0     0    1.15 0    
.  2     1   0     0    1.15 0    
.  3     1   0.5  16.7  1.15 0.549
.  4     1   1    30.3  1.15 0.996
.  5     1   1.5  41.3  1.15 1.36 
.  6     1   2    50.2  1.15 1.65 
.  7     1   2.5  57.2  1.15 1.88 
.  8     1   3    62.8  1.15 2.06 
.  9     1   3.5  67.1  1.15 2.20 
. 10     1   4    70.4  1.15 2.31 
. # ℹ 481,990 more rows
```

Or stay in the arrow ecosystem

``` r
as_arrow_ds(out)
. FileSystemDataset with 1 Parquet file
. 5 columns
. ID: double
. time: double
. CENT: double
. CL: double
. IPRED: double
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
. # A tibble: 481 × 2
.     time Median
.    <dbl>  <dbl>
.  1   0    0    
.  2   0.5  0.901
.  3   1    1.58 
.  4   1.5  2.07 
.  5   2    2.42 
.  6   2.5  2.65 
.  7   3    2.81 
.  8   3.5  2.92 
.  9  16.5  2.15 
. 10  17.5  2.07 
. # ℹ 471 more rows
```

This workflow is particularly useful when running replicate simulations
in parallel

``` r
library(future.apply)
. Loading required package: future

plan(multisession, workers = 5L)

out2 <- future_lapply(1:10, \(x) {
  mrgsim_ds(mod, data)  
}, future.seed = TRUE)

out2 <- reduce_ds(out2)

out2
. Model: popex
. Dim  : 4.8M 5
. Files: 10 [80.2 Mb]
.     ID time     CENT        CL     IPRED
. 1:   1  0.0  0.00000 0.9594254 0.0000000
. 2:   1  0.0  0.00000 0.9594254 0.0000000
. 3:   1  0.5 22.04630 0.9594254 0.9796388
. 4:   1  1.0 38.71305 0.9594254 1.7202345
. 5:   1  1.5 51.20927 0.9594254 2.2755104
. 6:   1  2.0 60.47425 0.9594254 2.6872049
. 7:   1  2.5 67.23771 0.9594254 2.9877427
. 8:   1  3.0 72.06648 0.9594254 3.2023117
```

All arrow files are stored in the tempdir in parquet format

``` r
list_temp()
. 11 files [88.3 Mb]
. - mrgsims-ds-7eca78ffa049.parquet
. - mrgsims-ds-7f071002c2aa.parquet
.    ...
. - mrgsims-ds-7f0b1457847b.parquet
. - mrgsims-ds-7f0b2aee909a.parquet
```

This directory is eventually removed when the R session ends. Tools are
provided to manage the space.

``` r
retain_temp(out2)
. Discarding 1 files.

list_temp()
. 10 files [80.2 Mb]
. - mrgsims-ds-7f071002c2aa.parquet
. - mrgsims-ds-7f07253a2f1c.parquet
.    ...
. - mrgsims-ds-7f0b1457847b.parquet
. - mrgsims-ds-7f0b2aee909a.parquet
```

We also put a finalizer on each object so that, when it goes out of
scope, the files are automatically cleaned up.

``` r
purge_temp()
. Discarding 10 files.

plan(multisession, workers = 5L)

out1 <- mrgsim_ds(mod, data) %>% rename_ds("out1")

out2 <- future_lapply(1:10, \(x) {
  mrgsim_ds(mod, data)  
}, future.seed = TRUE)

out2 <- reduce_ds(out2) %>% rename_ds("out2")

out3 <- mrgsim_ds(mod, data) %>% rename_ds("out3")
```

``` r
list_temp()
. 12 files [96.3 Mb]
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
. Ncells 1695832 90.6    2914462 155.7         NA  2914462 155.7
. Vcells 5555322 42.4   12241802  93.4      16384 10573259  80.7

list_temp()
. 2 files [16 Mb]
. - mrgsims-ds-out1-0001.parquet
. - mrgsims-ds-out3-0001.parquet
```
