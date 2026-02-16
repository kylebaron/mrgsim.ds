
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mrgsim.ds

<!-- badges: start -->

<!-- badges: end -->

About mrgsim.ds -

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
. 1:   1  0.0 1.953717 0.000000
. 2:   1  0.0 1.953717 0.000000
. 3:   1  0.5 1.953717 1.419314
. 4:   1  1.0 1.953717 2.340898
. 5:   1  1.5 1.953717 2.919591
. 6:   1  2.0 1.953717 3.262844
. 7:   1  2.5 1.953717 3.445188
. 8:   1  3.0 1.953717 3.518285
```

The output object doesn’t actually carry the simulated data, but rather
a pointer to the data in parquet files on your disk.

``` r
out$files
. [1] "/private/var/folders/zv/v6tkdhrn1_bb1ndrc0c0j31w0000gp/T/Rtmpb0nTjd/mrgsims-ds-899f7763ffb8.parquet"
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
. 1     1   0    1.95  0   
. 2     1   0    1.95  0   
. 3     1   0.5  1.95  1.42
. 4     1   1    1.95  2.34
. 5     1   1.5  1.95  2.92
. 6     1   2    1.95  3.26
tail(out)
. # A tibble: 6 × 4
.      ID  time    CL IPRED
.   <dbl> <dbl> <dbl> <dbl>
. 1  3000  238. 0.493 0.170
. 2  3000  238  0.493 0.167
. 3  3000  238. 0.493 0.164
. 4  3000  239  0.493 0.161
. 5  3000  240. 0.493 0.158
. 6  3000  240  0.493 0.155
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
.  1     1   0    1.95  0   
.  2     1   0    1.95  0   
.  3     1   0.5  1.95  1.42
.  4     1   1    1.95  2.34
.  5     1   1.5  1.95  2.92
.  6     1   2    1.95  3.26
.  7     1   2.5  1.95  3.45
.  8     1   3    1.95  3.52
.  9     1   3.5  1.95  3.52
. 10     1   4    1.95  3.47
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
.  3   1    1.80
.  4   1.5  2.27
.  5   2    2.58
.  6   2.5  2.80
.  7   3    2.94
.  8   3.5  3.04
.  9  16.5  2.19
. 10  17.5  2.11
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
. 1:   1  0.0 0.4453814 0.000000
. 2:   1  0.0 0.4453814 0.000000
. 3:   1  0.5 0.4453814 1.205096
. 4:   1  1.0 0.4453814 2.088543
. 5:   1  1.5 0.4453814 2.732958
. 6:   1  2.0 0.4453814 3.199767
. 7:   1  2.5 0.4453814 3.534646
. 8:   1  3.0 0.4453814 3.771554
```

All arrow files are stored in the tempdir in parquet format

``` r
list_temp()
. 11 files [131.1 Mb]
. - mrgsims-ds-899f7763ffb8.parquet
. - mrgsims-ds-89dc2697d7f6.parquet
.    ...
. - mrgsims-ds-89e01f93072b.parquet
. - mrgsims-ds-89e0580a9845.parquet
```

This directory is eventually removed when the R session ends. Tools are
provided to manage the space.

``` r
retain_temp(out2)
. Discarding 1 files.

list_temp()
. 10 files [119.1 Mb]
. - mrgsims-ds-89dc2697d7f6.parquet
. - mrgsims-ds-89dc332687b6.parquet
.    ...
. - mrgsims-ds-89e01f93072b.parquet
. - mrgsims-ds-89e0580a9845.parquet
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
. Ncells  1695948  90.6    3059967 163.5         NA  2673065 142.8
. Vcells 14761732 112.7   30249854 230.8      16384 26543820 202.6

list_temp()
. 2 files [23.8 Mb]
. - mrgsims-ds-out1-0001.parquet
. - mrgsims-ds-out3-0001.parquet
```
