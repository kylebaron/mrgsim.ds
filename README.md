
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

mod <- modlib_ds("1005", Req = "IPRED")

data <- expand.ev(amt = 100, ID = 1:1000)
```

mrgsim.ds provides a new `mrgsim()` variant - `mrgsim_ds()`:

``` r
out <- mrgsim_ds(mod, data)

out
. Model: 1005
. Dim  : 26,000 14
. Files: 1 [1015.5 Kb]
.     ID time       GUT     CENT    PERIPH       CL        Q       V2       V3
. 1:   1    0   0.00000 0.000000 0.0000000 31.33487 3.474506 42.82186 113.2767
. 2:   1    0 100.00000 0.000000 0.0000000 31.33487 3.474506 42.82186 113.2767
. 3:   1    1  93.27363 4.584666 0.2116820 31.33487 3.474506 42.82186 113.2767
. 4:   1    2  86.99971 6.317642 0.6532843 31.33487 3.474506 42.82186 113.2767
. 5:   1    3  81.14779 6.809088 1.1633157 31.33487 3.474506 42.82186 113.2767
. 6:   1    4  75.68949 6.769677 1.6728714 31.33487 3.474506 42.82186 113.2767
. 7:   1    5  70.59834 6.512441 2.1538103 31.33487 3.474506 42.82186 113.2767
. 8:   1    6  65.84963 6.174665 2.5958522 31.33487 3.474506 42.82186 113.2767
.             KA   ETA_1     ETA_2       ETA_3     IPRED
. 1:  0.06963272 1.19261 0.6306834 -0.02553457 0.0000000
. 2:  0.06963272 1.19261 0.6306834 -0.02553457 0.0000000
. 3:  0.06963272 1.19261 0.6306834 -0.02553457 0.1070637
. 4:  0.06963272 1.19261 0.6306834 -0.02553457 0.1475331
. 5:  0.06963272 1.19261 0.6306834 -0.02553457 0.1590096
. 6:  0.06963272 1.19261 0.6306834 -0.02553457 0.1580893
. 7:  0.06963272 1.19261 0.6306834 -0.02553457 0.1520822
. 8:  0.06963272 1.19261 0.6306834 -0.02553457 0.1441942
```

The output object doesn’t actually carry the simulated data, but rather
a pointer to the data in parquet files on your disk.

``` r
as_arrow_ds(out)
. FileSystemDataset with 1 Parquet file
. 14 columns
. ID: double
. time: double
. GUT: double
. CENT: double
. PERIPH: double
. CL: double
. Q: double
. V2: double
. V3: double
. KA: double
. ETA_1: double
. ETA_2: double
. ETA_3: double
. IPRED: double
. 
. See $metadata for additional Schema metadata
```

``` r
plot(out)
```

<img src="man/figures/README-unnamed-chunk-5-1.png" alt="" width="100%" />
