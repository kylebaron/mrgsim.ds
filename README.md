
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mrgsim.ds

<!-- badges: start -->

<!-- badges: end -->

`mrgsim.ds` provides an [Apache
Arrow](https://arrow.apache.org/docs/r/)-backed simulation output object
for [mrgsolve](https://mrgsolve.org), greatly reducing the memory
footprint of large simulations and providing a high-performance pipeline
for summarizing huge simulation outputs.

## Installation

You can install the development version of `mrgsim.ds` from
[GitHub](https://github.com/kylebaron/mrgsim.ds) with:

``` r
# install.packages("devtools")
devtools::install_github("kylebaron/mrgsim.ds")
```

## Example

We will illustrate `mrgsim.ds` by doing a simulation.

``` r
library(mrgsim.ds)
library(dplyr)

mod <- modlib_ds("popex", end = 240, outvars = c("IPRED,CL"))

data <- expand.ev(amt = 100, ii = 24, total = 6, ID = 1:3000)
```

`mrgsim.ds` provides a new `mrgsim()` variant - `mrgsim_ds()`. The name
implies we are tapping into Apache Arrow
[Dataset](https://arrow.apache.org/docs/r/reference/Dataset.html)
functionality.

``` r
out <- mrgsim_ds(mod, data)

out
. Model: popex
. Dim  : 1.4M 4
. Files: 1 [11.9 Mb]
.     ID time        CL     IPRED
. 1:   1  0.0 0.9378183 0.0000000
. 2:   1  0.0 0.9378183 0.0000000
. 3:   1  0.5 0.9378183 0.3418841
. 4:   1  1.0 0.9378183 0.6537741
. 5:   1  1.5 0.9378183 0.9377534
. 6:   1  2.0 0.9378183 1.1957705
. 7:   1  2.5 0.9378183 1.4296478
. 8:   1  3.0 0.9378183 1.6410894
```

## Very lightweight simulation output object

The output object doesn’t actually carry the simulated data, but rather
a pointer to the data in parquet files on your disk.

``` r
out$files
. [1] "/private/var/folders/zv/v6tkdhrn1_bb1ndrc0c0j31w0000gp/T/RtmpBtQTkk/mrgsims-ds-980626131e90.parquet"
```

This means there is almost nothing inside the object itself

``` r
lobstr:::obj_size(out)
. 292.09 kB

dim(out)
. [1] 1446000       4
```

What if we did the same simulation with regular `mrgsim()`?

``` r
x <- mrgsim(mod, data)

lobstr::obj_size(x)
. 46.30 MB

dim(x)
. [1] 1446000       4
```

The object is very light weight despite carrying the same data.

## Handles like regular mrgsim output

But, we can do a lot of the typical things we would with any `mrgsim()`
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
. 1     1   0   0.938 0    
. 2     1   0   0.938 0    
. 3     1   0.5 0.938 0.342
. 4     1   1   0.938 0.654
. 5     1   1.5 0.938 0.938
. 6     1   2   0.938 1.20

tail(out)
. # A tibble: 6 × 4
.      ID  time    CL IPRED
.   <dbl> <dbl> <dbl> <dbl>
. 1  3000  238. 0.313  3.95
. 2  3000  238  0.313  3.93
. 3  3000  238. 0.313  3.91
. 4  3000  239  0.313  3.90
. 5  3000  240. 0.313  3.88
. 6  3000  240  0.313  3.87

dim(out)
. [1] 1446000       4
```

This includes coercing to different types of objects. We can get the
usual R data frames

``` r
as_tibble(out)
. # A tibble: 1,446,000 × 4
.       ID  time    CL IPRED
.    <dbl> <dbl> <dbl> <dbl>
.  1     1   0   0.938 0    
.  2     1   0   0.938 0    
.  3     1   0.5 0.938 0.342
.  4     1   1   0.938 0.654
.  5     1   1.5 0.938 0.938
.  6     1   2   0.938 1.20 
.  7     1   2.5 0.938 1.43 
.  8     1   3   0.938 1.64 
.  9     1   3.5 0.938 1.83 
. 10     1   4   0.938 2.00 
. # ℹ 1,445,990 more rows
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

## Tidyverse-friendly

We’ve integrated into the `dplyr` ecosystem as well

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
.  2   0.5  1.08
.  3   1    1.76
.  4   1.5  2.22
.  5   2    2.53
.  6   2.5  2.74
.  7   3    2.88
.  8   3.5  2.98
.  9  16.5  2.17
. 10  17.5  2.08
. # ℹ 471 more rows
```

## Good for large simulations

This workflow is particularly useful when running replicate simulations
in parallel, with large outputs

``` r
library(future.apply)

plan(multisession, workers = 5L)

out2 <- future_lapply(1:10, \(x) { mrgsim_ds(mod, data) }, future.seed = TRUE)

out2 <- reduce_ds(out2)

out2
.     ID time       CL    IPRED
. 1:   1  0.0 1.007791 0.000000
. 2:   1  0.0 1.007791 0.000000
. 3:   1  0.5 1.007791 2.113519
. 4:   1  1.0 1.007791 3.270806
. 5:   1  1.5 1.007791 3.881961
. 6:   1  2.0 1.007791 4.181733
. 7:   1  2.5 1.007791 4.304486
. 8:   1  3.0 1.007791 4.327114
```

## Files on disk are automagically managed

All `arrow` files are stored in the `tempdir()` in parquet format

``` r
list_temp()
. 11 files [131.1 Mb]
. - mrgsims-ds-980626131e90.parquet
. - mrgsims-ds-9843615e9a33.parquet
.    ...
. - mrgsims-ds-984723a0c38c.parquet
. - mrgsims-ds-9847afa021d.parquet
```

This directory is eventually removed when the R session ends. Tools are
provided to manage the space.

``` r
retain_temp(out2)
. Discarding 1 files.

list_temp()
. 10 files [119.1 Mb]
. - mrgsims-ds-9843615e9a33.parquet
. - mrgsims-ds-9843701e7bfe.parquet
.    ...
. - mrgsims-ds-984723a0c38c.parquet
. - mrgsims-ds-9847afa021d.parquet
```

We also put a finalizer on each object so that, when it goes out of
scope, the files are automatically cleaned up.

``` r
purge_temp()
. Discarding 10 files.

plan(multisession, workers = 5L)

out1 <- mrgsim_ds(mod, data) %>% rename_ds("out1")

out2 <- future_lapply(1:10, \(x) { mrgsim_ds(mod, data) }, future.seed = TRUE)

out2 <- reduce_ds(out2) %>% rename_ds("out2")

out3 <- mrgsim_ds(mod, data) %>% rename_ds("out3")
```

``` r
list_temp()
. 12 files [143 Mb]
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
.            used  (Mb) gc trigger  (Mb) limit (Mb) max used  (Mb)
. Ncells  1695895  90.6    3059958 163.5         NA  2663195 142.3
. Vcells 14761887 112.7   30250016 230.8      16384 26543927 202.6

list_temp()
. 2 files [23.8 Mb]
. - mrgsims-ds-out1-0001.parquet
. - mrgsims-ds-out3-0001.parquet
```
