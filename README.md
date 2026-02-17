
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
. 1:   1  0.0 0.6559109 0.0000000
. 2:   1  0.0 0.6559109 0.0000000
. 3:   1  0.5 0.6559109 0.3607271
. 4:   1  1.0 0.6559109 0.6850600
. 5:   1  1.5 0.6559109 0.9762436
. 6:   1  2.0 0.6559109 1.2372389
. 7:   1  2.5 0.6559109 1.4707469
. 8:   1  3.0 0.6559109 1.6792321
```

## Very lightweight simulation output object

The output object doesn’t actually carry the simulated data, but rather
a pointer to the data in parquet files on your disk.

``` r
basename(out$files)
. [1] "mrgsims-ds-e8afecefb87.parquet"
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
. 1     1   0   0.656 0    
. 2     1   0   0.656 0    
. 3     1   0.5 0.656 0.361
. 4     1   1   0.656 0.685
. 5     1   1.5 0.656 0.976
. 6     1   2   0.656 1.24

tail(out)
. # A tibble: 6 × 4
.      ID  time    CL IPRED
.   <dbl> <dbl> <dbl> <dbl>
. 1  3000  238. 0.682 0.773
. 2  3000  238  0.682 0.765
. 3  3000  238. 0.682 0.758
. 4  3000  239  0.682 0.751
. 5  3000  240. 0.682 0.744
. 6  3000  240  0.682 0.737

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
.  1     1   0   0.656 0    
.  2     1   0   0.656 0    
.  3     1   0.5 0.656 0.361
.  4     1   1   0.656 0.685
.  5     1   1.5 0.656 0.976
.  6     1   2   0.656 1.24 
.  7     1   2.5 0.656 1.47 
.  8     1   3   0.656 1.68 
.  9     1   3.5 0.656 1.86 
. 10     1   4   0.656 2.03 
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
.  1     1   0   0.656 0    
.  2     1   0   0.656 0    
.  3     1   0.5 0.656 0.361
.  4     1   1   0.656 0.685
.  5     1   1.5 0.656 0.976
.  6     1   2   0.656 1.24 
.  7     1   2.5 0.656 1.47 
.  8     1   3   0.656 1.68 
.  9     1   3.5 0.656 1.86 
. 10     1   4   0.656 2.03 
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
  summarise(Mean = mean(IPRED, na.rm = TRUE), n = n()) %>% 
  arrange(time)

dd
. FileSystemDataset (query)
. time: double
. Mean: double
. n: int64
. 
. * Sorted by time [asc]
. See $.data for the source Arrow object
```

``` r
collect(dd)
. # A tibble: 481 × 3
.     time  Mean     n
.    <dbl> <dbl> <int>
.  1   0    0     6000
.  2   0.5  1.10  3000
.  3   1    1.79  3000
.  4   1.5  2.25  3000
.  5   2    2.57  3000
.  6   2.5  2.78  3000
.  7   3    2.93  3000
.  8   3.5  3.02  3000
.  9   4    3.08  3000
. 10   4.5  3.12  3000
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
. 1:   1  0.0 1.185408 0.000000
. 2:   1  0.0 1.185408 0.000000
. 3:   1  0.5 1.185408 1.598144
. 4:   1  1.0 1.185408 2.499137
. 5:   1  1.5 1.185408 2.991942
. 6:   1  2.0 1.185408 3.246076
. 7:   1  2.5 1.185408 3.360981
. 8:   1  3.0 1.185408 3.394982
```

## Files on disk are automagically managed

All `arrow` files are stored in the `tempdir()` in parquet format

``` r
list_temp()
. 11 files [131.1 Mb]
. - mrgsims-ds-e8afecefb87.parquet
. - mrgsims-ds-e8ec11985ad2.parquet
.    ...
. - mrgsims-ds-e8f03aeb624f.parquet
. - mrgsims-ds-e8f05ce2ff5d.parquet
```

This directory is eventually removed when the R session ends. Tools are
provided to manage the space.

``` r
retain_temp(out2)
. Discarding 1 files.

list_temp()
. 10 files [119.1 Mb]
. - mrgsims-ds-e8ec11985ad2.parquet
. - mrgsims-ds-e8ec22dd91de.parquet
.    ...
. - mrgsims-ds-e8f03aeb624f.parquet
. - mrgsims-ds-e8f05ce2ff5d.parquet
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
. Ncells  1943313 103.8    3626078 193.7         NA  2898100 154.8
. Vcells 15228070 116.2   29074241 221.9      16384 27010129 206.1

list_temp()
. 2 files [23.8 Mb]
. - mrgsims-ds-out1-0001.parquet
. - mrgsims-ds-out3-0001.parquet
```
