
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
.     ID time       CL     IPRED
. 1:   1  0.0 2.698099 0.0000000
. 2:   1  0.0 2.698099 0.0000000
. 3:   1  0.5 2.698099 0.6776074
. 4:   1  1.0 2.698099 1.2224352
. 5:   1  1.5 2.698099 1.6543026
. 6:   1  2.0 2.698099 1.9903601
. 7:   1  2.5 2.698099 2.2454307
. 8:   1  3.0 2.698099 2.4323095
```

## Very lightweight simulation output object

The output object doesn’t actually carry the simulated data, but rather
a pointer to the data in parquet files on your disk.

``` r
out$files
. [1] "/private/var/folders/zv/v6tkdhrn1_bb1ndrc0c0j31w0000gp/T/RtmpTEhsVZ/mrgsims-ds-90fe731307d2.parquet"
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
. 1     1   0    2.70 0    
. 2     1   0    2.70 0    
. 3     1   0.5  2.70 0.678
. 4     1   1    2.70 1.22 
. 5     1   1.5  2.70 1.65 
. 6     1   2    2.70 1.99

tail(out)
. # A tibble: 6 × 4
.      ID  time    CL  IPRED
.   <dbl> <dbl> <dbl>  <dbl>
. 1  3000  238. 0.961 0.0607
. 2  3000  238  0.961 0.0595
. 3  3000  238. 0.961 0.0583
. 4  3000  239  0.961 0.0572
. 5  3000  240. 0.961 0.0560
. 6  3000  240  0.961 0.0549

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
.  1     1   0    2.70 0    
.  2     1   0    2.70 0    
.  3     1   0.5  2.70 0.678
.  4     1   1    2.70 1.22 
.  5     1   1.5  2.70 1.65 
.  6     1   2    2.70 1.99 
.  7     1   2.5  2.70 2.25 
.  8     1   3    2.70 2.43 
.  9     1   3.5  2.70 2.56 
. 10     1   4    2.70 2.64 
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

We’ve integrated into the dplyr ecosystem as well

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
.  2   0.5  1.09
.  3   1    1.79
.  4   1.5  2.25
.  5   2    2.56
.  6   2.5  2.77
.  7   3    2.91
.  8   3.5  3.00
.  9  16.5  2.17
. 10  17.5  2.08
. # ℹ 471 more rows
```

## Good for large simulations

This workflow is particularly useful when running replicate simulations
in parallel, with loarge outputs

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
.     ID time       CL    IPRED
. 1:   1  0.0 1.297545 0.000000
. 2:   1  0.0 1.297545 0.000000
. 3:   1  0.5 1.297545 1.479155
. 4:   1  1.0 1.297545 2.489495
. 5:   1  1.5 1.297545 3.165403
. 6:   1  2.0 1.297545 3.603171
. 7:   1  2.5 1.297545 3.871784
. 8:   1  3.0 1.297545 4.020650
```

## Files on disk are automagically managed

All arrow files are stored in the tempdir in parquet format

``` r
list_temp()
. 11 files [131.1 Mb]
. - mrgsims-ds-90fe731307d2.parquet
. - mrgsims-ds-913b2a7dcbce.parquet
.    ...
. - mrgsims-ds-913f3f3404f9.parquet
. - mrgsims-ds-913f703297d9.parquet
```

This directory is eventually removed when the R session ends. Tools are
provided to manage the space.

``` r
retain_temp(out2)
. Discarding 1 files.

list_temp()
. 10 files [119.1 Mb]
. - mrgsims-ds-913b2a7dcbce.parquet
. - mrgsims-ds-913b44df750d.parquet
.    ...
. - mrgsims-ds-913f3f3404f9.parquet
. - mrgsims-ds-913f703297d9.parquet
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
. Ncells  1695960  90.6    3059982 163.5         NA  2670521 142.7
. Vcells 14761933 112.7   30250083 230.8      16384 26544011 202.6

list_temp()
. 2 files [23.8 Mb]
. - mrgsims-ds-out1-0001.parquet
. - mrgsims-ds-out3-0001.parquet
```
