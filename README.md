
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mrgsim.ds

<!-- badges: start -->

<!-- badges: end -->

`mrgsim.ds` provides an [Apache
Arrow](https://arrow.apache.org/docs/r/)-backed simulation output object
for mrgsolve, greatly reducing the memory footprint of large simulations
and providing a high-performance pipeline for summarizing huge
simulation outputs.

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

data <- expand.ev(amt = 100, ii = 24, total = 6, ID = 1:3000)
```

mrgsim.ds provides a new `mrgsim()` variant - `mrgsim_ds()`:

``` r
out <- mrgsim_ds(mod, data)

out
. Model: popex
. Dim  : 1.4M 4
. Files: 1 [11.9 Mb]
.     ID time       CL    IPRED
. 1:   1  0.0 1.285184 0.000000
. 2:   1  0.0 1.285184 0.000000
. 3:   1  0.5 1.285184 1.075078
. 4:   1  1.0 1.285184 1.724978
. 5:   1  1.5 1.285184 2.110421
. 6:   1  2.0 1.285184 2.331502
. 7:   1  2.5 1.285184 2.450558
. 8:   1  3.0 1.285184 2.506411
```

The output object doesn’t actually carry the simulated data, but rather
a pointer to the data in parquet files on your disk.

``` r
out$files
. [1] "/private/var/folders/zv/v6tkdhrn1_bb1ndrc0c0j31w0000gp/T/RtmpiFooHC/mrgsims-ds-8f4912136725.parquet"
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
. 1     1   0    1.29  0   
. 2     1   0    1.29  0   
. 3     1   0.5  1.29  1.08
. 4     1   1    1.29  1.72
. 5     1   1.5  1.29  2.11
. 6     1   2    1.29  2.33

tail(out)
. # A tibble: 6 × 4
.      ID  time    CL IPRED
.   <dbl> <dbl> <dbl> <dbl>
. 1  3000  238. 0.598 0.675
. 2  3000  238  0.598 0.668
. 3  3000  238. 0.598 0.660
. 4  3000  239  0.598 0.653
. 5  3000  240. 0.598 0.646
. 6  3000  240  0.598 0.639

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
.  1     1   0    1.29  0   
.  2     1   0    1.29  0   
.  3     1   0.5  1.29  1.08
.  4     1   1    1.29  1.72
.  5     1   1.5  1.29  2.11
.  6     1   2    1.29  2.33
.  7     1   2.5  1.29  2.45
.  8     1   3    1.29  2.51
.  9     1   3.5  1.29  2.52
. 10     1   4    1.29  2.52
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
.  4   1.5  2.25
.  5   2    2.56
.  6   2.5  2.77
.  7   3    2.91
.  8   3.5  3.01
.  9  16.5  2.18
. 10  17.5  2.10
. # ℹ 471 more rows
```

This workflow is particularly useful when running replicate simulations
in parallel

``` r
library(future.apply)
. Loading required package: future

plan(multisession, workers = 5L)

out2 <- future_lapply(1:10, \(x) { mrgsim_ds(mod, data) }, future.seed = TRUE)

out2 <- reduce_ds(out2)

out2
. Model: popex
. Dim  : 14.5M 4
. Files: 10 [119.1 Mb]
.     ID time        CL    IPRED
. 1:   1  0.0 0.3993847 0.000000
. 2:   1  0.0 0.3993847 0.000000
. 3:   1  0.5 0.3993847 1.443463
. 4:   1  1.0 0.3993847 2.505440
. 5:   1  1.5 0.3993847 3.282590
. 6:   1  2.0 0.3993847 3.847126
. 7:   1  2.5 0.3993847 4.253000
. 8:   1  3.0 0.3993847 4.540514
```

All arrow files are stored in the tempdir in parquet format

``` r
list_temp()
. 11 files [131.1 Mb]
. - mrgsims-ds-8f4912136725.parquet
. - mrgsims-ds-8f8728d040ec.parquet
.    ...
. - mrgsims-ds-8f8b4a963612.parquet
. - mrgsims-ds-8f8b4bb7fdff.parquet
```

This directory is eventually removed when the R session ends. Tools are
provided to manage the space.

``` r
retain_temp(out2)
. Discarding 1 files.

list_temp()
. 10 files [119.1 Mb]
. - mrgsims-ds-8f8728d040ec.parquet
. - mrgsims-ds-8f8776f761b6.parquet
.    ...
. - mrgsims-ds-8f8b4a963612.parquet
. - mrgsims-ds-8f8b4bb7fdff.parquet
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
. Ncells  1695953  90.6    3059974 163.5         NA  2673460 142.8
. Vcells 14761850 112.7   30249971 230.8      16384 26543918 202.6

list_temp()
. 2 files [23.8 Mb]
. - mrgsims-ds-out1-0001.parquet
. - mrgsims-ds-out3-0001.parquet
```
