# mrgsim.ds

`mrgsim.ds` provides an [Apache
Arrow](https://arrow.apache.org/docs/r/)-backed simulation output object
for [mrgsolve](https://mrgsolve.org), greatly reducing the memory
footprint of large simulations and providing a high-performance pipeline
for summarizing huge simulation outputs. The arrow-based simulation
output objects in R claim ownership of their files on disk. Those files
are automatically removed when the owning object goes out of scope and
becomes subject to the R garbage collector. While “anonymous”,
parquet-formatted files hold the data in
[`tempdir()`](https://rdrr.io/r/base/tempfile.html) as you are working
in R, functions are provided to move this data to more permanent
locations for later use.

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

`mrgsim.ds` provides a new
[`mrgsim()`](https://mrgsolve.org/docs/reference/mrgsim.html) variant -
[`mrgsim_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsim_ds.md).
The name implies we are tapping into Apache Arrow
[Dataset](https://arrow.apache.org/docs/r/reference/Dataset.html)
functionality. The simulation below carries `1,446,000` rows.

``` r
out <- mrgsim_ds(mod, data)

out
. Model: popex
. Dim  : 1.4M x 4
. Files: 1 [11.9 Mb]
. Owner: yes
.     ID time       CL    IPRED
. 1:   1  0.0 1.181467 0.000000
. 2:   1  0.0 1.181467 0.000000
. 3:   1  0.5 1.181467 2.444338
. 4:   1  1.0 1.181467 3.446174
. 5:   1  1.5 1.181467 3.821430
. 6:   1  2.0 1.181467 3.925382
. 7:   1  2.5 1.181467 3.912710
. 8:   1  3.0 1.181467 3.850735
```

## Very lightweight simulation output object

The output object doesn’t actually carry these 1.4M rows of simulated
data. Rather it stores a pointer to the data in parquet files on your
disk.

``` r
basename(out$files)
. [1] "mrgsims-ds-524f43837f7d.parquet"
```

This means there is almost nothing inside the object itself

``` r
lobstr:::obj_size(out)
. 292.51 kB

dim(out)
. [1] 1446000       4
```

What if we did the same simulation with regular
[`mrgsim()`](https://mrgsolve.org/docs/reference/mrgsim.html)?

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

But, we can do a lot of the typical things we would with any
[`mrgsim()`](https://mrgsolve.org/docs/reference/mrgsim.html) output
object.

``` r
plot(out, nid = 12)
```

![](reference/figures/README-plot_head_tail_dim-1.png)

``` r
head(out)
. # A tibble: 6 × 4
.      ID  time    CL IPRED
.   <dbl> <dbl> <dbl> <dbl>
. 1     1   0    1.18  0   
. 2     1   0    1.18  0   
. 3     1   0.5  1.18  2.44
. 4     1   1    1.18  3.45
. 5     1   1.5  1.18  3.82
. 6     1   2    1.18  3.93

tail(out)
. # A tibble: 6 × 4
.      ID  time    CL IPRED
.   <dbl> <dbl> <dbl> <dbl>
. 1  3000  238. 0.759 0.253
. 2  3000  238  0.759 0.249
. 3  3000  238. 0.759 0.245
. 4  3000  239  0.759 0.241
. 5  3000  240. 0.759 0.238
. 6  3000  240  0.759 0.234

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
.  1     1   0    1.18  0   
.  2     1   0    1.18  0   
.  3     1   0.5  1.18  2.44
.  4     1   1    1.18  3.45
.  5     1   1.5  1.18  3.82
.  6     1   2    1.18  3.93
.  7     1   2.5  1.18  3.91
.  8     1   3    1.18  3.85
.  9     1   3.5  1.18  3.77
. 10     1   4    1.18  3.68
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
.  1     1   0    1.18  0   
.  2     1   0    1.18  0   
.  3     1   0.5  1.18  2.44
.  4     1   1    1.18  3.45
.  5     1   1.5  1.18  3.82
.  6     1   2    1.18  3.93
.  7     1   2.5  1.18  3.91
.  8     1   3    1.18  3.85
.  9     1   3.5  1.18  3.77
. 10     1   4    1.18  3.68
. # ℹ more rows
```

## Tidyverse-friendly

We’ve integrated into the `dplyr` ecosystem as well, allowing you to
[`filter()`](https://dplyr.tidyverse.org/reference/filter.html),
[`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html),
[`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html), or
[`select()`](https://dplyr.tidyverse.org/reference/select.html) your way
directly into a pipeline to summarize your simulations using the power
of Apache Arrow.

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
.  2   0.5  1.11  3000
.  3   1    1.81  3000
.  4   1.5  2.27  3000
.  5   2    2.58  3000
.  6   2.5  2.79  3000
.  7   3    2.93  3000
.  8   3.5  3.03  3000
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
. Dim  : 14.5M x 4
. Files: 10 [119.1 Mb]
. Owner: yes
.     ID time        CL     IPRED
. 1:   1  0.0 0.9461104 0.0000000
. 2:   1  0.0 0.9461104 0.0000000
. 3:   1  0.5 0.9461104 0.3872511
. 4:   1  1.0 0.9461104 0.7236788
. 5:   1  1.5 0.9461104 1.0152435
. 6:   1  2.0 0.9461104 1.2672169
. 7:   1  2.5 0.9461104 1.4842606
. 8:   1  3.0 0.9461104 1.6704974
```

## Files on disk are automagically managed

All `arrow` files are stored in the
[`tempdir()`](https://rdrr.io/r/base/tempfile.html) in parquet format

``` r
list_temp()
. 11 files [131.1 Mb]
. - mrgsims-ds-524f43837f7d.parquet
. - mrgsims-ds-528d1b817a99.parquet
.    ...
. - mrgsims-ds-52912bf98b00.parquet
. - mrgsims-ds-52917e86bbe.parquet
```

This directory is eventually removed when the R session ends. Tools are
provided to manage the space.

``` r
retain_temp(out2)
. Discarding 1 files.

list_temp()
. 10 files [119.1 Mb]
. - mrgsims-ds-528d1b817a99.parquet
. - mrgsims-ds-528d32194ec1.parquet
.    ...
. - mrgsims-ds-52912bf98b00.parquet
. - mrgsims-ds-52917e86bbe.parquet
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
. Ncells  1952362 104.3    3644097 194.7         NA  3177894 169.8
. Vcells 15247021 116.4   29097300 222.0      16384 26998749 206.0

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
might see a small slowdown with
[`mrgsim_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsim_ds.md);
it definitely won’t be faster than
[`mrgsim()`](https://mrgsolve.org/docs/reference/mrgsim.html) … even
with the super-quick arrow ecosystem. This workflow is really for large
simulation volumes where you are happy to pay the cost of writing
outputs to file and then streaming them back in to summarize.
