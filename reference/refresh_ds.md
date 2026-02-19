# Refresh 'Arrow' dataset pointers.

Pointers to arrow data sets will be invalid when the simulation is run
in a different process, for example when simulating in parallel. The
pointers should be refreshed on the head node once the simulation is
finished.

## Usage

``` r
refresh_ds(x, ...)

# S3 method for class 'mrgsimsds'
refresh_ds(x, ...)

# S3 method for class 'list'
refresh_ds(x, ...)
```

## Arguments

- x:

  an mrgsimsds object.

- ...:

  for future use.

## Value

The mrgsimsds object is returned invisibly with pointers refreshed;
modification is made in place.

## Details

To refresh the pointers, `refresh_ds()` checks that the files still
exist and passes the file list to
[`arrow::open_dataset()`](https://arrow.apache.org/docs/r/reference/open_dataset.html).
The object `pid` and the `dim` attributes are also refreshed, after
re-opening the data set.

## Examples

``` r
mod <- house_ds()

data <- ev_expand(amt = 100, ID = 1:100)

out <- lapply(1:3, function(rep) {
  mrgsim_ds(mod, data) 
})

refresh_ds(out)
#> [[1]]
#> Model: housemodel
#> Dim  : 48,200 7
#> Files: 1 [343.5 Kb]
#> Owner: yes
#>     ID time       GUT     CENT     RESP       DV       CP
#> 1:   1 0.00   0.00000  0.00000 50.00000 0.000000 0.000000
#> 2:   1 0.00 100.00000  0.00000 50.00000 0.000000 0.000000
#> 3:   1 0.25  74.08182 25.74883 48.68223 1.287441 1.287441
#> 4:   1 0.50  54.88116 44.50417 46.18005 2.225208 2.225208
#> 5:   1 0.75  40.65697 58.08258 43.61333 2.904129 2.904129
#> 6:   1 1.00  30.11942 67.82976 41.37943 3.391488 3.391488
#> 7:   1 1.25  22.31302 74.74256 39.57649 3.737128 3.737128
#> 8:   1 1.50  16.52989 79.55944 38.18381 3.977972 3.977972
#> 
#> [[2]]
#> Model: housemodel
#> Dim  : 48,200 7
#> Files: 1 [343.5 Kb]
#> Owner: yes
#>     ID time       GUT     CENT     RESP       DV       CP
#> 1:   1 0.00   0.00000  0.00000 50.00000 0.000000 0.000000
#> 2:   1 0.00 100.00000  0.00000 50.00000 0.000000 0.000000
#> 3:   1 0.25  74.08182 25.74883 48.68223 1.287441 1.287441
#> 4:   1 0.50  54.88116 44.50417 46.18005 2.225208 2.225208
#> 5:   1 0.75  40.65697 58.08258 43.61333 2.904129 2.904129
#> 6:   1 1.00  30.11942 67.82976 41.37943 3.391488 3.391488
#> 7:   1 1.25  22.31302 74.74256 39.57649 3.737128 3.737128
#> 8:   1 1.50  16.52989 79.55944 38.18381 3.977972 3.977972
#> 
#> [[3]]
#> Model: housemodel
#> Dim  : 48,200 7
#> Files: 1 [343.5 Kb]
#> Owner: yes
#>     ID time       GUT     CENT     RESP       DV       CP
#> 1:   1 0.00   0.00000  0.00000 50.00000 0.000000 0.000000
#> 2:   1 0.00 100.00000  0.00000 50.00000 0.000000 0.000000
#> 3:   1 0.25  74.08182 25.74883 48.68223 1.287441 1.287441
#> 4:   1 0.50  54.88116 44.50417 46.18005 2.225208 2.225208
#> 5:   1 0.75  40.65697 58.08258 43.61333 2.904129 2.904129
#> 6:   1 1.00  30.11942 67.82976 41.37943 3.391488 3.391488
#> 7:   1 1.25  22.31302 74.74256 39.57649 3.737128 3.737128
#> 8:   1 1.50  16.52989 79.55944 38.18381 3.977972 3.977972
#> 
```
