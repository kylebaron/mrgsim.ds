
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mrgsim.ds

<!-- badges: start -->

<!-- badges: end -->

`mrgsim.ds` provides an Apache Arrow-backed simulation output object for
mrgsolve, greatly reducing the memory footprint of large simulations and
providing a high-performance pipeline for summarizing huge simulation
outputs.

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
.     ID time        CL    IPRED
. 1:   1  0.0 0.4471385 0.000000
. 2:   1  0.0 0.4471385 0.000000
. 3:   1  0.5 0.4471385 1.389159
. 4:   1  1.0 0.4471385 2.325895
. 5:   1  1.5 0.4471385 2.953238
. 6:   1  2.0 0.4471385 3.369041
. 7:   1  2.5 0.4471385 3.640250
. 8:   1  3.0 0.4471385 3.812665
```

The output object doesn’t actually carry the simulated data, but rather
a pointer to the data in parquet files on your disk.

``` r
out$files
. [1] "/private/var/folders/zv/v6tkdhrn1_bb1ndrc0c0j31w0000gp/T/RtmpRaYidJ/mrgsims-ds-8df676b30f78.parquet"
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
. 1     1   0   0.447  0   
. 2     1   0   0.447  0   
. 3     1   0.5 0.447  1.39
. 4     1   1   0.447  2.33
. 5     1   1.5 0.447  2.95
. 6     1   2   0.447  3.37

tail(out)
. # A tibble: 6 × 4
.      ID  time    CL  IPRED
.   <dbl> <dbl> <dbl>  <dbl>
. 1  3000  238.  1.09 0.0923
. 2  3000  238   1.09 0.0906
. 3  3000  238.  1.09 0.0889
. 4  3000  239   1.09 0.0873
. 5  3000  240.  1.09 0.0857
. 6  3000  240   1.09 0.0841

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
.  1     1   0   0.447  0   
.  2     1   0   0.447  0   
.  3     1   0.5 0.447  1.39
.  4     1   1   0.447  2.33
.  5     1   1.5 0.447  2.95
.  6     1   2   0.447  3.37
.  7     1   2.5 0.447  3.64
.  8     1   3   0.447  3.81
.  9     1   3.5 0.447  3.92
. 10     1   4   0.447  3.98
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
.  1  224. 0.460
.  2  225  0.455
.  3  226. 0.451
.  4  226  0.447
.  5  226. 0.443
.  6  227  0.438
.  7  228. 0.434
.  8  228  0.430
.  9  228. 0.426
. 10  229  0.422
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
.     ID time        CL     IPRED
. 1:   1  0.0 0.3938941 0.0000000
. 2:   1  0.0 0.3938941 0.0000000
. 3:   1  0.5 0.3938941 0.7969576
. 4:   1  1.0 0.3938941 1.4812626
. 5:   1  1.5 0.3938941 2.0675876
. 6:   1  2.0 0.3938941 2.5687083
. 7:   1  2.5 0.3938941 2.9957481
. 8:   1  3.0 0.3938941 3.3583920
```

All arrow files are stored in the tempdir in parquet format

``` r
list_temp()
. 11 files [131.1 Mb]
. - mrgsims-ds-8df676b30f78.parquet
. - mrgsims-ds-8e3335dcb6bc.parquet
.    ...
. - mrgsims-ds-8e3755e4462d.parquet
. - mrgsims-ds-8e37715c1acf.parquet
```

This directory is eventually removed when the R session ends. Tools are
provided to manage the space.

``` r
retain_temp(out2)
. Discarding 1 files.

list_temp()
. 10 files [119.1 Mb]
. - mrgsims-ds-8e3335dcb6bc.parquet
. - mrgsims-ds-8e336a659fc6.parquet
.    ...
. - mrgsims-ds-8e3755e4462d.parquet
. - mrgsims-ds-8e37715c1acf.parquet
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
. Ncells  1695951  90.6    3059967 163.5         NA  2664437 142.3
. Vcells 14761833 112.7   30249963 230.8      16384 26543911 202.6

list_temp()
. 2 files [23.8 Mb]
. - mrgsims-ds-out1-0001.parquet
. - mrgsims-ds-out3-0001.parquet
```
