
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

mod <- modlib_ds("popex", end = 240, outvars = c("IPRED,CL"))

data <- expand.ev(amt = 100, ii = 24, total = 6, ID = 1:1000)
```

mrgsim.ds provides a new `mrgsim()` variant - `mrgsim_ds()`:

``` r
out <- mrgsim_ds(mod, data)

out
. Model: popex
. Dim  : 482.0K 4
. Files: 1 [4.1 Mb]
.     ID time        CL     IPRED
. 1:   1  0.0 0.4269356 0.0000000
. 2:   1  0.0 0.4269356 0.0000000
. 3:   1  0.5 0.4269356 0.9261468
. 4:   1  1.0 0.4269356 1.5977554
. 5:   1  1.5 0.4269356 2.0829507
. 6:   1  2.0 0.4269356 2.4316377
. 7:   1  2.5 0.4269356 2.6803743
. 8:   1  3.0 0.4269356 2.8559408
```

The output object doesn’t actually carry the simulated data, but rather
a pointer to the data in parquet files on your disk.

``` r
out$files
. [1] "/private/var/folders/zv/v6tkdhrn1_bb1ndrc0c0j31w0000gp/T/RtmpHTQIUM/mrgsims-ds-814147d89002.parquet"
```

But, we can do a lot of the typical things we would with any mrgsim
output object.

``` r
plot(out, nid = 12)
```

<img src="man/figures/README-plot_head_tail_dim-1.png" alt="" width="100%" />

``` r
head(out)
. # A tibble: 6 × 4
.      ID  time    CL IPRED
.   <dbl> <dbl> <dbl> <dbl>
. 1     1   0   0.427 0    
. 2     1   0   0.427 0    
. 3     1   0.5 0.427 0.926
. 4     1   1   0.427 1.60 
. 5     1   1.5 0.427 2.08 
. 6     1   2   0.427 2.43
tail(out)
. # A tibble: 6 × 4
.      ID  time    CL    IPRED
.   <dbl> <dbl> <dbl>    <dbl>
. 1  1000  238. 0.987 0.000750
. 2  1000  238  0.987 0.000720
. 3  1000  238. 0.987 0.000691
. 4  1000  239  0.987 0.000663
. 5  1000  240. 0.987 0.000636
. 6  1000  240  0.987 0.000610
dim(out)
. [1] 482000      4
```

This includes coercing to different types of objects. We can get the
usual R data frames

``` r
as_tibble(out)
. # A tibble: 482,000 × 4
.       ID  time    CL IPRED
.    <dbl> <dbl> <dbl> <dbl>
.  1     1   0   0.427 0    
.  2     1   0   0.427 0    
.  3     1   0.5 0.427 0.926
.  4     1   1   0.427 1.60 
.  5     1   1.5 0.427 2.08 
.  6     1   2   0.427 2.43 
.  7     1   2.5 0.427 2.68 
.  8     1   3   0.427 2.86 
.  9     1   3.5 0.427 2.98 
. 10     1   4   0.427 3.06 
. # ℹ 481,990 more rows
```

Or stay in the arrow ecosystem

``` r
as_arrow_ds(out)
. FileSystemDataset with 1 Parquet file
. 4 columns
. ID: double
. time: double
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
.  2   0.5  0.915
.  3   1    1.59 
.  4   1.5  2.09 
.  5   2    2.42 
.  6   2.5  2.66 
.  7   3    2.83 
.  8   3.5  2.94 
.  9  16.5  2.16 
. 10  17.5  2.08 
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
. Dim  : 4.8M 4
. Files: 10 [40.7 Mb]
.     ID time        CL     IPRED
. 1:   1  0.0 0.3928659 0.0000000
. 2:   1  0.0 0.3928659 0.0000000
. 3:   1  0.5 0.3928659 0.4942487
. 4:   1  1.0 0.3928659 0.8972481
. 5:   1  1.5 0.3928659 1.2253647
. 6:   1  2.0 0.3928659 1.4920325
. 7:   1  2.5 0.3928659 1.7082777
. 8:   1  3.0 0.3928659 1.8831505
```

All arrow files are stored in the tempdir in parquet format

``` r
list_temp()
. 11 files [44.7 Mb]
. - mrgsims-ds-814147d89002.parquet
. - mrgsims-ds-817e309c5550.parquet
.    ...
. - mrgsims-ds-81823fd11713.parquet
. - mrgsims-ds-81827557f8ba.parquet
```

This directory is eventually removed when the R session ends. Tools are
provided to manage the space.

``` r
retain_temp(out2)
. Discarding 1 files.

list_temp()
. 10 files [40.7 Mb]
. - mrgsims-ds-817e309c5550.parquet
. - mrgsims-ds-817e67a5101e.parquet
.    ...
. - mrgsims-ds-81823fd11713.parquet
. - mrgsims-ds-81827557f8ba.parquet
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
. 12 files [48.8 Mb]
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
.           used (Mb) gc trigger  (Mb) limit (Mb) max used (Mb)
. Ncells 1695758 90.6    2920608 156.0         NA  2920608  156
. Vcells 5110276 39.0   12286145  93.8      16384  9164103   70

list_temp()
. 2 files [8.1 Mb]
. - mrgsims-ds-out1-0001.parquet
. - mrgsims-ds-out3-0001.parquet
```
