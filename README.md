
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
.     ID time     CL    IPRED
. 1:   1  0.0 1.0879 0.000000
. 2:   1  0.0 1.0879 0.000000
. 3:   1  0.5 1.0879 1.687068
. 4:   1  1.0 1.0879 2.642263
. 5:   1  1.5 1.0879 3.167585
. 6:   1  2.0 1.0879 3.440743
. 7:   1  2.5 1.0879 3.566304
. 8:   1  3.0 1.0879 3.605788
```

## Very lightweight simulation output object

The output object doesn’t actually carry the simulated data, but rather
a pointer to the data in parquet files on your disk.

``` r
out$files
. [1] "/private/var/folders/zv/v6tkdhrn1_bb1ndrc0c0j31w0000gp/T/RtmpMJXBtV/mrgsims-ds-9958390b5142.parquet"
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
. 1     1   0    1.09  0   
. 2     1   0    1.09  0   
. 3     1   0.5  1.09  1.69
. 4     1   1    1.09  2.64
. 5     1   1.5  1.09  3.17
. 6     1   2    1.09  3.44

tail(out)
. # A tibble: 6 × 4
.      ID  time    CL  IPRED
.   <dbl> <dbl> <dbl>  <dbl>
. 1  3000  238.  1.78 0.0149
. 2  3000  238   1.78 0.0145
. 3  3000  238.  1.78 0.0142
. 4  3000  239   1.78 0.0138
. 5  3000  240.  1.78 0.0135
. 6  3000  240   1.78 0.0132

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
.  1     1   0    1.09  0   
.  2     1   0    1.09  0   
.  3     1   0.5  1.09  1.69
.  4     1   1    1.09  2.64
.  5     1   1.5  1.09  3.17
.  6     1   2    1.09  3.44
.  7     1   2.5  1.09  3.57
.  8     1   3    1.09  3.61
.  9     1   3.5  1.09  3.60
. 10     1   4    1.09  3.56
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
.  1  224. 0.444
.  2  225  0.439
.  3  226. 0.435
.  4  226  0.431
.  5  226. 0.427
.  6  227  0.423
.  7  228. 0.418
.  8  228  0.414
.  9  228. 0.410
. 10  229  0.406
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
.     ID time        CL     IPRED
. 1:   1  0.0 0.5981712 0.0000000
. 2:   1  0.0 0.5981712 0.0000000
. 3:   1  0.5 0.5981712 0.5276051
. 4:   1  1.0 0.5981712 0.9693718
. 5:   1  1.5 0.5981712 1.3384329
. 6:   1  2.0 0.5981712 1.6459199
. 7:   1  2.5 0.5981712 1.9012681
. 8:   1  3.0 0.5981712 2.1124749
```

## Files on disk are automagically managed

All `arrow` files are stored in the `tempdir()` in parquet format

``` r
list_temp()
. 11 files [131.1 Mb]
. - mrgsims-ds-9958390b5142.parquet
. - mrgsims-ds-999515540b40.parquet
.    ...
. - mrgsims-ds-99991f6bfbd1.parquet
. - mrgsims-ds-99997db1baff.parquet
```

This directory is eventually removed when the R session ends. Tools are
provided to manage the space.

``` r
retain_temp(out2)
. Discarding 1 files.

list_temp()
. 10 files [119.1 Mb]
. - mrgsims-ds-999515540b40.parquet
. - mrgsims-ds-99956160ba02.parquet
.    ...
. - mrgsims-ds-99991f6bfbd1.parquet
. - mrgsims-ds-99997db1baff.parquet
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
. Ncells  1695947  90.6    3059962 163.5         NA  2679958 143.2
. Vcells 14761969 112.7   30250126 230.8      16384 26544040 202.6

list_temp()
. 2 files [23.8 Mb]
. - mrgsims-ds-out1-0001.parquet
. - mrgsims-ds-out3-0001.parquet
```
