
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mrgsim.ds

<!-- badges: start -->

<!-- badges: end -->

`mrgsim.ds` provides an [Apache
Arrow](https://arrow.apache.org/docs/r/)-backed simulation output object
for [mrgsolve](https://mrgsolve.org), greatly reducing the memory
footprint of large simulations and providing a high-performance pipeline
for summarizing huge simulation outputs. Simulation output objects in R
claim ownership of files on disk and those files are automatically
removed when owing object goes out of scope and becomes subject to the R
garbage collector.

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

mod <- modlib_ds("popex", end = 240, outvars = "IPRED,CL")

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
. Owner: yes
.     ID time       CL    IPRED
. 1:   1  0.0 1.099928 0.000000
. 2:   1  0.0 1.099928 0.000000
. 3:   1  0.5 1.099928 2.381230
. 4:   1  1.0 1.099928 3.510354
. 5:   1  1.5 1.099928 4.014526
. 6:   1  2.0 1.099928 4.207551
. 7:   1  2.5 1.099928 4.246425
. 8:   1  3.0 1.099928 4.209673
```

## Very lightweight simulation output object

The output object doesn’t actually carry the simulated data, but rather
a pointer to the data in parquet files on your disk.

``` r
basename(out$files)
. [1] "mrgsims-ds-144fa493c2475.parquet"
```

This means there is almost nothing inside the object itself

``` r
lobstr:::obj_size(out)
. 292.53 kB

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

<img src="man/figures/README-plot_head_tail_dim-1.png" alt="" width="100%" />

``` r
head(out)
. # A tibble: 6 × 4
.      ID  time    CL IPRED
.   <dbl> <dbl> <dbl> <dbl>
. 1     1   0    1.10  0   
. 2     1   0    1.10  0   
. 3     1   0.5  1.10  2.38
. 4     1   1    1.10  3.51
. 5     1   1.5  1.10  4.01
. 6     1   2    1.10  4.21

tail(out)
. # A tibble: 6 × 4
.      ID  time    CL   IPRED
.   <dbl> <dbl> <dbl>   <dbl>
. 1  3000  238. 0.871 0.00891
. 2  3000  238  0.871 0.00865
. 3  3000  238. 0.871 0.00840
. 4  3000  239  0.871 0.00816
. 5  3000  240. 0.871 0.00792
. 6  3000  240  0.871 0.00769

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
.  1     1   0    1.10  0   
.  2     1   0    1.10  0   
.  3     1   0.5  1.10  2.38
.  4     1   1    1.10  3.51
.  5     1   1.5  1.10  4.01
.  6     1   2    1.10  4.21
.  7     1   2.5  1.10  4.25
.  8     1   3    1.10  4.21
.  9     1   3.5  1.10  4.14
. 10     1   4    1.10  4.05
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
.  1     1   0    1.10  0   
.  2     1   0    1.10  0   
.  3     1   0.5  1.10  2.38
.  4     1   1    1.10  3.51
.  5     1   1.5  1.10  4.01
.  6     1   2    1.10  4.21
.  7     1   2.5  1.10  4.25
.  8     1   3    1.10  4.21
.  9     1   3.5  1.10  4.14
. 10     1   4    1.10  4.05
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
.  3   1    1.80  3000
.  4   1.5  2.26  3000
.  5   2    2.57  3000
.  6   2.5  2.79  3000
.  7   3    2.93  3000
.  8   3.5  3.03  3000
.  9   4    3.09  3000
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
. Owner: yes
.     ID time       CL     IPRED
. 1:   1  0.0 2.878249 0.0000000
. 2:   1  0.0 2.878249 0.0000000
. 3:   1  0.5 2.878249 0.1284124
. 4:   1  1.0 2.878249 0.2452064
. 5:   1  1.5 2.878249 0.3511959
. 6:   1  2.0 2.878249 0.4471426
. 7:   1  2.5 2.878249 0.5337592
. 8:   1  3.0 2.878249 0.6117125
```

## Files on disk are automagically managed

All `arrow` files are stored in the `tempdir()` in parquet format

``` r
list_temp()
. 11 files [131.1 Mb]
. - mrgsims-ds-144fa493c2475.parquet
. - mrgsims-ds-145373e773b20.parquet
.    ...
. - mrgsims-ds-1453b145ddef1.parquet
. - mrgsims-ds-1453b1ed7aaa9.parquet
```

This directory is eventually removed when the R session ends. Tools are
provided to manage the space.

``` r
retain_temp(out2)
. Discarding 1 files.

list_temp()
. 10 files [119.1 Mb]
. - mrgsims-ds-145373e773b20.parquet
. - mrgsims-ds-14537caf2449.parquet
.    ...
. - mrgsims-ds-1453b145ddef1.parquet
. - mrgsims-ds-1453b1ed7aaa9.parquet
```

We also put a finalizer on each object so that, when it goes out of
scope, the files are automatically cleaned up.

``` r
purge_temp()
. Discarding 10 files.

plan(multisession, workers = 5L)

out1 <- mrgsim_ds(mod, data)
rename_ds(out1, "out1")

out2 <- future_lapply(1:10, \(x) { mrgsim_ds(mod, data) }, future.seed = TRUE)

out2 <- reduce_ds(out2)
rename_ds(out2, "out2")

out3 <- mrgsim_ds(mod, data) 
rename_ds(out3, "out3")
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

As soon as the garbage collector is called, the leftover files are
cleaned up.

``` r
gc()
.            used  (Mb) gc trigger  (Mb) limit (Mb) max used  (Mb)
. Ncells  1951475 104.3    3641994 194.6         NA  3219976 172.0
. Vcells 15245573 116.4   29095809 222.0      16384 27048742 206.4

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
. Objects: 4 | Files: 13 | Size: 23.8 Mb
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
