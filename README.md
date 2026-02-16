
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
.     ID time        CL    IPRED
. 1:   1  0.0 0.5023461 0.000000
. 2:   1  0.0 0.5023461 0.000000
. 3:   1  0.5 0.5023461 1.761039
. 4:   1  1.0 0.5023461 2.736933
. 5:   1  1.5 0.5023461 3.269940
. 6:   1  2.0 0.5023461 3.553198
. 7:   1  2.5 0.5023461 3.695697
. 8:   1  3.0 0.5023461 3.758940
```

The output object doesn’t actually carry the simulated data, but rather
a pointer to the data in parquet files on your disk.

``` r
out$files
. [1] "/private/var/folders/zv/v6tkdhrn1_bb1ndrc0c0j31w0000gp/T/RtmpLImC8l/mrgsims-ds-871d3dccd5ee.parquet"
```

This means there is almost nothing inside the object itself

``` r
lobstr:::obj_size(out)
. 292.09 kB
dim(out)
. [1] 482000      4
```

What if we did the same simulation with regular `mrgsim()`?

``` r
x <- mrgsim(mod, data)

lobstr::obj_size(x)
. 15.45 MB
dim(x)
. [1] 482000      4
```

The object is very light weight despite carrying the same data.

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
. 1     1   0   0.502  0   
. 2     1   0   0.502  0   
. 3     1   0.5 0.502  1.76
. 4     1   1   0.502  2.74
. 5     1   1.5 0.502  3.27
. 6     1   2   0.502  3.55
tail(out)
. # A tibble: 6 × 4
.      ID  time    CL  IPRED
.   <dbl> <dbl> <dbl>  <dbl>
. 1  1000  238.  1.29 0.0796
. 2  1000  238   1.29 0.0782
. 3  1000  238.  1.29 0.0769
. 4  1000  239   1.29 0.0755
. 5  1000  240.  1.29 0.0742
. 6  1000  240   1.29 0.0729
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
.  1     1   0   0.502  0   
.  2     1   0   0.502  0   
.  3     1   0.5 0.502  1.76
.  4     1   1   0.502  2.74
.  5     1   1.5 0.502  3.27
.  6     1   2   0.502  3.55
.  7     1   2.5 0.502  3.70
.  8     1   3   0.502  3.76
.  9     1   3.5 0.502  3.78
. 10     1   4   0.502  3.77
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

We’ve integrated into the dplyr verbs as well

``` r
dd <- 
  out %>% 
  group_by(time) %>% 
  summarise(Mean = mean(IPRED, na.rm = TRUE))

dd
. FileSystemDataset (query)
. time: double
. Mean: double
. 
. See $.data for the source Arrow object
```

``` r
collect(dd)
. # A tibble: 481 × 2
.     time  Mean
.    <dbl> <dbl>
.  1   0    0   
.  2   0.5  1.10
.  3   1    1.79
.  4   1.5  2.26
.  5   2    2.57
.  6   2.5  2.79
.  7   3    2.94
.  8   3.5  3.04
.  9  16.5  2.21
. 10  17.5  2.13
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
. 1:   1  0.0 0.5439483 0.0000000
. 2:   1  0.0 0.5439483 0.0000000
. 3:   1  0.5 0.5439483 0.5103261
. 4:   1  1.0 0.5439483 0.9546902
. 5:   1  1.5 0.5439483 1.3409097
. 6:   1  2.0 0.5439483 1.6758834
. 7:   1  2.5 0.5439483 1.9656988
. 8:   1  3.0 0.5439483 2.2157278
```

All arrow files are stored in the tempdir in parquet format

``` r
list_temp()
. 11 files [44.7 Mb]
. - mrgsims-ds-871d3dccd5ee.parquet
. - mrgsims-ds-875a32394d6c.parquet
.    ...
. - mrgsims-ds-875e61e66c22.parquet
. - mrgsims-ds-875e64740858.parquet
```

This directory is eventually removed when the R session ends. Tools are
provided to manage the space.

``` r
retain_temp(out2)
. Discarding 1 files.

list_temp()
. 10 files [40.7 Mb]
. - mrgsims-ds-875a32394d6c.parquet
. - mrgsims-ds-875ad75a262.parquet
.    ...
. - mrgsims-ds-875e61e66c22.parquet
. - mrgsims-ds-875e64740858.parquet
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
.           used (Mb) gc trigger  (Mb) limit (Mb) max used  (Mb)
. Ncells 1695952 90.6    2815062 150.4         NA  2815062 150.4
. Vcells 7036759 53.7   14597925 111.4      16384 11090570  84.7

list_temp()
. 2 files [8.1 Mb]
. - mrgsims-ds-out1-0001.parquet
. - mrgsims-ds-out3-0001.parquet
```
