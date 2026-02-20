
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mrgsim.ds

<!-- badges: start -->

[![R-universe
version](https://kylebaron.r-universe.dev/mrgsim.ds/badges/version)](https://kylebaron.r-universe.dev/mrgsim.ds)
[![r-universe
status](https://kylebaron.r-universe.dev/mrgsim.ds/badges/checks)](https://kylebaron.r-universe.dev/mrgsim.ds)
[![R-CMD-check](https://github.com/kylebaron/mrgsim.ds/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/kylebaron/mrgsim.ds/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

`mrgsim.ds` provides an [Apache
Arrow](https://arrow.apache.org/docs/r/)-backed simulation output object
for [mrgsolve](https://mrgsolve.org), greatly reducing the memory
footprint of large simulations and providing a high-performance pipeline
for summarizing huge simulation outputs. The arrow-based simulation
output objects in R claim ownership of their files on disk. Those files
are automatically removed when the owning object goes out of scope and
becomes subject to the R garbage collector. While “anonymous”,
parquet-formatted files hold the data in `tempdir()` as you are working
in R, functions are provided to move this data to more permanent
locations for later use.

## Installation

You can install the development version of `mrgsim.ds` from
[r-universe](https://kylebaron.r-universe.dev/mrgsim.ds) with:

``` r
# Install 'mrgsim.ds' in R:
install.packages('mrgsim.ds', repos = c('https://kylebaron.r-universe.dev', 'https://cloud.r-project.org'))
```

## Example

We will illustrate `mrgsim.ds` by doing a simulation.

``` r
library(mrgsim.ds)
library(dplyr)

mod <- modlib_ds("popex", end = 240, outvars = "IPRED,CL")

data <- expand.ev(amt = 100, ii = 24, total = 6, ID = 1:3000)
```

`mrgsim.ds` provides a new `mrgsim()` variant - `mrgsim_ds()`. The name
implies we are tapping into Apache Arrow
[Dataset](https://arrow.apache.org/docs/r/reference/Dataset.html)
functionality. The simulation below carries `1,446,000` rows.

``` r
out <- mrgsim_ds(mod, data)

out
. Model: popex
. Dim  : 1.4M x 4
. Files: 1 [11.9 Mb]
. Owner: yes
.     ID time        CL    IPRED
. 1:   1  0.0 0.6601045 0.000000
. 2:   1  0.0 0.6601045 0.000000
. 3:   1  0.5 0.6601045 1.756330
. 4:   1  1.0 0.6601045 2.947337
. 5:   1  1.5 0.6601045 3.744798
. 6:   1  2.0 0.6601045 4.268478
. 7:   1  2.5 0.6601045 4.601877
. 8:   1  3.0 0.6601045 4.803204
```

## Very lightweight simulation output object

The output object doesn’t actually carry these 1.4M rows of simulated
data. Rather it stores a pointer to the data in parquet files on your
disk.

``` r
basename(out$files)
. [1] "mrgsims-ds-6ece3b5bb339.parquet"
```

This means there is almost nothing inside the object itself

``` r
lobstr:::obj_size(out)
. 292.51 kB

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

The `mrgsim.ds` object is very light weight despite tracking the same
data.

## Handles like regular mrgsim output

But, we can do a lot of the typical things we would with any `mrgsim()`
output object.

``` r
plot(out, nid = 12)
```

<img src="man/figures/README-plot_head_tail_dim-1.png" alt="" width="80%" style="display: block; margin: auto;" />

``` r

head(out)
. # A tibble: 6 × 4
.      ID  time    CL IPRED
.   <dbl> <dbl> <dbl> <dbl>
. 1     1   0   0.660  0   
. 2     1   0   0.660  0   
. 3     1   0.5 0.660  1.76
. 4     1   1   0.660  2.95
. 5     1   1.5 0.660  3.74
. 6     1   2   0.660  4.27

tail(out)
. # A tibble: 6 × 4
.      ID  time    CL IPRED
.   <dbl> <dbl> <dbl> <dbl>
. 1  3000  238. 0.779 0.119
. 2  3000  238  0.779 0.117
. 3  3000  238. 0.779 0.115
. 4  3000  239  0.779 0.113
. 5  3000  240. 0.779 0.111
. 6  3000  240  0.779 0.109

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
.  1     1   0   0.660  0   
.  2     1   0   0.660  0   
.  3     1   0.5 0.660  1.76
.  4     1   1   0.660  2.95
.  5     1   1.5 0.660  3.74
.  6     1   2   0.660  4.27
.  7     1   2.5 0.660  4.60
.  8     1   3   0.660  4.80
.  9     1   3.5 0.660  4.91
. 10     1   4   0.660  4.96
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
.  1     1   0   0.660  0   
.  2     1   0   0.660  0   
.  3     1   0.5 0.660  1.76
.  4     1   1   0.660  2.95
.  5     1   1.5 0.660  3.74
.  6     1   2   0.660  4.27
.  7     1   2.5 0.660  4.60
.  8     1   3   0.660  4.80
.  9     1   3.5 0.660  4.91
. 10     1   4   0.660  4.96
. # ℹ more rows
```

## Tidyverse-friendly

We’ve integrated into the `dplyr` ecosystem as well, allowing you to
`filter()`, `group_by()`, `mutate()`, `select()`, `summarise()`,
`rename()`, or `arrange()` your way directly into a pipeline to
summarize your simulations using the power of Apache Arrow.

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
.  2   0.5  1.13  3000
.  3   1    1.83  3000
.  4   1.5  2.29  3000
.  5   2    2.60  3000
.  6   2.5  2.81  3000
.  7   3    2.96  3000
.  8   3.5  3.05  3000
.  9   4    3.10  3000
. 10   4.5  3.13  3000
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
```

Now there are 10x the number of rows (14.5M), but little change in
object size.

``` r
out2
. Model: popex
. Dim  : 14.5M x 4
. Files: 10 [119.2 Mb]
. Owner: yes
.     ID time        CL     IPRED
. 1:   1  0.0 0.7453202 0.0000000
. 2:   1  0.0 0.7453202 0.0000000
. 3:   1  0.5 0.7453202 0.2004743
. 4:   1  1.0 0.7453202 0.3821993
. 5:   1  1.5 0.7453202 0.5467789
. 6:   1  2.0 0.7453202 0.6956808
. 7:   1  2.5 0.7453202 0.8302481
. 8:   1  3.0 0.7453202 0.9517104
```

``` r
lobstr::obj_size(out2)
. 295.56 kB
```

## Files on disk are automagically managed

All `arrow` files are stored in the `tempdir()` in parquet format

``` r
list_temp()
. 11 files [131.1 Mb]
. - mrgsims-ds-6ece3b5bb339.parquet
. - mrgsims-ds-6f0c360fd6d3.parquet
.    ...
. - mrgsims-ds-6f10225ef974.parquet
. - mrgsims-ds-6f1094b404d.parquet
```

This directory is eventually removed when the R session ends. Tools are
provided to manage the space.

``` r
retain_temp(out2)
. Discarding 1 files.

list_temp()
. 10 files [119.2 Mb]
. - mrgsims-ds-6f0c360fd6d3.parquet
. - mrgsims-ds-6f0c49e0d25f.parquet
.    ...
. - mrgsims-ds-6f10225ef974.parquet
. - mrgsims-ds-6f1094b404d.parquet
```

We also put a finalizer on each object so that, when it goes out of
scope, the files are automatically cleaned up.

First, run a bunch of simulations.

``` r
plan(multisession, workers = 5L)

out1 <- mrgsim_ds(mod, data)
rename_ds(out1, "out1")

out2 <- future_lapply(1:10, \(x) { mrgsim_ds(mod, data) }, future.seed = TRUE)

out2 <- reduce_ds(out2)
rename_ds(out2, "out2")

out3 <- mrgsim_ds(mod, data) 
rename_ds(out3, "out3")
```

There are 12 files holding simulation outputs.

``` r
list_temp()
. 12 files [143 Mb]
. - mrgsims-ds-out1-0001.parquet
. - mrgsims-ds-out2-0001.parquet
.    ...
. - mrgsims-ds-out2-0010.parquet
. - mrgsims-ds-out3-0001.parquet
```

Now, remove one of the objects containing 10 files.

``` r
rm(out2)
```

As soon as the garbage collector is called, the leftover files are
cleaned up.

``` r
gc()
.            used  (Mb) gc trigger  (Mb) limit (Mb) max used  (Mb)
. Ncells  1946964 104.0    3643540 194.6         NA  3271222 174.8
. Vcells 15237389 116.3   29085557 222.0      16384 27013458 206.1

list_temp()
. 2 files [23.8 Mb]
. - mrgsims-ds-out1-0001.parquet
. - mrgsims-ds-out3-0001.parquet
```

### Ownership

This setup is only possible if one object owns the files on disk and
`mrgsim.ds` tracks this.

``` r
ownership()
. > Objects: 4 | Files: 13 | Size: 23.8 Mb
```

If I make a copy of a simulation object, the old object no longer owns
the files.

``` r
out4 <- copy_ds(out1, own = TRUE)

check_ownership(out1)
. [1] FALSE

check_ownership(out4)
. [1] TRUE
```

I can always take ownership back.

``` r
take_ownership(out1)

check_ownership(out1)
. [1] TRUE

check_ownership(out4)
. [1] FALSE
```

## If this is so great, why not make it the default for mrgsolve?

There is a cost to all of this. For small to mid-size simulations, you
might see a small slowdown with `mrgsim_ds()`; it definitely won’t be
faster than `mrgsim()` … even with the super-quick arrow ecosystem. This
workflow is really for large simulation volumes where you are happy to
pay the cost of writing outputs to file and then streaming them back in
to summarize.
