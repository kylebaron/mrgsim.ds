
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
.     ID time        CL    IPRED
. 1:   1  0.0 0.9198294 0.000000
. 2:   1  0.0 0.9198294 0.000000
. 3:   1  0.5 0.9198294 1.171837
. 4:   1  1.0 0.9198294 2.080260
. 5:   1  1.5 0.9198294 2.778163
. 6:   1  2.0 0.9198294 3.307970
. 7:   1  2.5 0.9198294 3.703703
. 8:   1  3.0 0.9198294 3.992643
```

## Very lightweight simulation output object

The output object doesn’t actually carry the simulated data, but rather
a pointer to the data in parquet files on your disk.

``` r
basename(out$files)
. [1] "mrgsims-ds-e42340c627a4.parquet"
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
. 1     1   0   0.920  0   
. 2     1   0   0.920  0   
. 3     1   0.5 0.920  1.17
. 4     1   1   0.920  2.08
. 5     1   1.5 0.920  2.78
. 6     1   2   0.920  3.31

tail(out)
. # A tibble: 6 × 4
.      ID  time    CL IPRED
.   <dbl> <dbl> <dbl> <dbl>
. 1  3000  238. 0.684 0.121
. 2  3000  238  0.684 0.119
. 3  3000  238. 0.684 0.116
. 4  3000  239  0.684 0.114
. 5  3000  240. 0.684 0.112
. 6  3000  240  0.684 0.110

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
.  1     1   0   0.920  0   
.  2     1   0   0.920  0   
.  3     1   0.5 0.920  1.17
.  4     1   1   0.920  2.08
.  5     1   1.5 0.920  2.78
.  6     1   2   0.920  3.31
.  7     1   2.5 0.920  3.70
.  8     1   3   0.920  3.99
.  9     1   3.5 0.920  4.20
. 10     1   4   0.920  4.33
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
.  1     1   0   0.920  0   
.  2     1   0   0.920  0   
.  3     1   0.5 0.920  1.17
.  4     1   1   0.920  2.08
.  5     1   1.5 0.920  2.78
.  6     1   2   0.920  3.31
.  7     1   2.5 0.920  3.70
.  8     1   3   0.920  3.99
.  9     1   3.5 0.920  4.20
. 10     1   4   0.920  4.33
. # ℹ more rows
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
.  2   0.5  1.11
.  3   1    1.80
.  4   1.5  2.26
.  5   2    2.58
.  6   2.5  2.79
.  7   3    2.94
.  8   3.5  3.04
.  9  16.5  2.23
. 10  17.5  2.15
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
. 1:   1  0.0 1.249369 0.000000
. 2:   1  0.0 1.249369 0.000000
. 3:   1  0.5 1.249369 1.629762
. 4:   1  1.0 1.249369 2.581764
. 5:   1  1.5 1.249369 3.121251
. 6:   1  2.0 1.249369 3.410071
. 7:   1  2.5 1.249369 3.546969
. 8:   1  3.0 1.249369 3.592181
```

## Files on disk are automagically managed

All `arrow` files are stored in the `tempdir()` in parquet format

``` r
list_temp()
. 11 files [131.1 Mb]
. - mrgsims-ds-e42340c627a4.parquet
. - mrgsims-ds-e46052520435.parquet
.    ...
. - mrgsims-ds-e4642a8734e6.parquet
. - mrgsims-ds-e4642ce59690.parquet
```

This directory is eventually removed when the R session ends. Tools are
provided to manage the space.

``` r
retain_temp(out2)
. Discarding 1 files.

list_temp()
. 10 files [119.1 Mb]
. - mrgsims-ds-e46052520435.parquet
. - mrgsims-ds-e4605db9d125.parquet
.    ...
. - mrgsims-ds-e4642a8734e6.parquet
. - mrgsims-ds-e4642ce59690.parquet
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
. Ncells  1935316 103.4    3631562 194.0         NA  2899594 154.9
. Vcells 15215755 116.1   29059439 221.8      16384 26997794 206.0

list_temp()
. 2 files [23.8 Mb]
. - mrgsims-ds-out1-0001.parquet
. - mrgsims-ds-out3-0001.parquet
```
