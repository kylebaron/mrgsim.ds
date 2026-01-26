
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
. Loading required package: mrgsolve
. 
. Attaching package: 'mrgsolve'
. The following object is masked from 'package:stats':
. 
.     filter

mod <- modlib("1005")
. Loading required namespace: xml2
. Building 1005 ... done.

data <- expand.ev(amt = 100, ID = 1:1000)
```

mrgsim.ds provides a new `mrgsim()` variant - `mrgsim_ds()`:

``` r
out <- mrgsim_ds(mod, data)

out
. Model: 1005
. Dim  : 26000 14
. Files: 1 [1015.5 Kb]
.     ID time       GUT     CENT    PERIPH       CL        Q       V2       V3
. 1:   1    0   0.00000 0.000000 0.0000000 11.71519 3.474506 19.93599 113.2767
. 2:   1    0 100.00000 0.000000 0.0000000 11.71519 3.474506 19.93599 113.2767
. 3:   1    1  92.29942 5.366929 0.5293308 11.71519 3.474506 19.93599 113.2767
. 4:   1    2  85.19183 7.478612 1.6470050 11.71519 3.474506 19.93599 113.2767
. 5:   1    3  78.63157 8.109837 2.9489899 11.71519 3.474506 19.93599 113.2767
. 6:   1    4  72.57648 8.080905 4.2553480 11.71519 3.474506 19.93599 113.2767
. 7:   1    5  66.98767 7.769969 5.4894149 11.71519 3.474506 19.93599 113.2767
. 8:   1    6  61.82923 7.350445 6.6218544 11.71519 3.474506 19.93599 113.2767
.             KA    ETA_1      ETA_2     ETA_3     IPRED
. 1:  0.08013233 0.208765 -0.1338387 0.1149101 0.0000000
. 2:  0.08013233 0.208765 -0.1338387 0.1149101 0.0000000
. 3:  0.08013233 0.208765 -0.1338387 0.1149101 0.2692081
. 4:  0.08013233 0.208765 -0.1338387 0.1149101 0.3751313
. 5:  0.08013233 0.208765 -0.1338387 0.1149101 0.4067938
. 6:  0.08013233 0.208765 -0.1338387 0.1149101 0.4053426
. 7:  0.08013233 0.208765 -0.1338387 0.1149101 0.3897459
. 8:  0.08013233 0.208765 -0.1338387 0.1149101 0.3687023
```

The output object doesn’t actually carry the simulated data, but rather
a pointer to the data in parquet files on your disk.

``` r
as_ds_sims(out)
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
