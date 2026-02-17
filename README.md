
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
.     ID time       CL     IPRED
. 1:   1  0.0 0.526841 0.0000000
. 2:   1  0.0 0.526841 0.0000000
. 3:   1  0.5 0.526841 0.1491338
. 4:   1  1.0 0.526841 0.2906852
. 5:   1  1.5 0.526841 0.4249810
. 6:   1  2.0 0.526841 0.5523346
. 7:   1  2.5 0.526841 0.6730461
. 8:   1  3.0 0.526841 0.7874033
```

## Very lightweight simulation output object

The output object doesn’t actually carry the simulated data, but rather
a pointer to the data in parquet files on your disk.

``` r
basename(out$files)
. [1] "mrgsims-ds-e76bd2fb3b1.parquet"
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
. 1     1   0   0.527 0    
. 2     1   0   0.527 0    
. 3     1   0.5 0.527 0.149
. 4     1   1   0.527 0.291
. 5     1   1.5 0.527 0.425
. 6     1   2   0.527 0.552

tail(out)
. # A tibble: 6 × 4
.      ID  time    CL IPRED
.   <dbl> <dbl> <dbl> <dbl>
. 1  3000  238. 0.739 1.01 
. 2  3000  238  0.739 1.00 
. 3  3000  238. 0.739 0.992
. 4  3000  239  0.739 0.984
. 5  3000  240. 0.739 0.976
. 6  3000  240  0.739 0.968

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
.  1     1   0   0.527 0    
.  2     1   0   0.527 0    
.  3     1   0.5 0.527 0.149
.  4     1   1   0.527 0.291
.  5     1   1.5 0.527 0.425
.  6     1   2   0.527 0.552
.  7     1   2.5 0.527 0.673
.  8     1   3   0.527 0.787
.  9     1   3.5 0.527 0.896
. 10     1   4   0.527 0.998
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

Or try your hand at duckdb

``` r
as_duckdb_ds(out)
. # Source:   table<arrow_001> [?? x 4]
. # Database: DuckDB 1.4.3 [kyleb@Darwin 24.6.0:R 4.5.2/:memory:]
.       ID  time    CL IPRED
.    <dbl> <dbl> <dbl> <dbl>
.  1     1   0   0.527 0    
.  2     1   0   0.527 0    
.  3     1   0.5 0.527 0.149
.  4     1   1   0.527 0.291
.  5     1   1.5 0.527 0.425
.  6     1   2   0.527 0.552
.  7     1   2.5 0.527 0.673
.  8     1   3   0.527 0.787
.  9     1   3.5 0.527 0.896
. 10     1   4   0.527 0.998
. # ℹ more rows
```

## Tidyverse-friendly

We’ve integrated into the `dplyr` ecosystem as well, allowing you to
`filter()`, `group_by()`, `mutate()`, or `select()` your way directly
into a pipeline to summarize your simulations using the power of Apache
Arrow.

``` r
dd <- 
  out %>% 
  group_by(time) %>% 
  summarise(Mean = mean(IPRED, na.rm = TRUE), n = n())

dd
. FileSystemDataset (query)
. time: double
. Mean: double
. n: int64
. 
. See $.data for the source Arrow object
```

``` r
collect(dd)
. # A tibble: 481 × 3
.     time  Mean     n
.    <dbl> <dbl> <int>
.  1  224. 0.444  3000
.  2  225  0.440  3000
.  3  226. 0.435  3000
.  4  226  0.431  3000
.  5  226. 0.427  3000
.  6  227  0.423  3000
.  7  228. 0.419  3000
.  8  228  0.415  3000
.  9  228. 0.411  3000
. 10  229  0.407  3000
. # ℹ 471 more rows
```

## Good for large simulations

This workflow is particularly useful when running replicate simulations
in parallel, with large outputs

``` r
library(future.apply, quietly = TRUE)

plan(multisession, workers = 5L)

out2 <- future_lapply(1:10, \(x) { mrgsim_ds(mod, data) }, future.seed = TRUE)

out2 <- reduce_ds(out2)

out2
. Model: popex
. Dim  : 14.5M 4
. Files: 10 [119.1 Mb]
.     ID time       CL    IPRED
. 1:   1  0.0 2.428887 0.000000
. 2:   1  0.0 2.428887 0.000000
. 3:   1  0.5 2.428887 2.051378
. 4:   1  1.0 2.428887 3.320291
. 5:   1  1.5 2.428887 4.053959
. 6:   1  2.0 2.428887 4.424850
. 7:   1  2.5 2.428887 4.553015
. 8:   1  3.0 2.428887 4.521773
```

## Files on disk are automagically managed

All `arrow` files are stored in the `tempdir()` in parquet format

``` r
list_temp()
. 11 files [131.1 Mb]
. - mrgsims-ds-e76bd2fb3b1.parquet
. - mrgsims-ds-e7a87e62d867.parquet
.    ...
. - mrgsims-ds-e7ac58d4fe2c.parquet
. - mrgsims-ds-e7ac77b2844.parquet
```

This directory is eventually removed when the R session ends. Tools are
provided to manage the space.

``` r
retain_temp(out2)
. Discarding 1 files.

list_temp()
. 10 files [119.1 Mb]
. - mrgsims-ds-e7a87e62d867.parquet
. - mrgsims-ds-e7a8cf45a85.parquet
.    ...
. - mrgsims-ds-e7ac58d4fe2c.parquet
. - mrgsims-ds-e7ac77b2844.parquet
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
. Ncells  1943254 103.8    3626711 193.7         NA  2898113 154.8
. Vcells 15229500 116.2   29075957 221.9      16384 27011559 206.1

list_temp()
. 2 files [23.8 Mb]
. - mrgsims-ds-out1-0001.parquet
. - mrgsims-ds-out3-0001.parquet
```
