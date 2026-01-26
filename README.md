
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

mod <- modlib("1005", Req = "IPRED")
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
. 1:   1    0   0.00000 0.000000 0.0000000 7.136932 3.474506 17.92051 113.2767
. 2:   1    0 100.00000 0.000000 0.0000000 7.136932 3.474506 17.92051 113.2767
. 3:   1    1  92.86945 5.366899 0.5733033 7.136932 3.474506 17.92051 113.2767
. 4:   1    2  86.24736 7.976678 1.8627258 7.136932 3.474506 17.92051 113.2767
. 5:   1    3  80.09745 9.099460 3.4542021 7.136932 3.474506 17.92051 113.2767
. 6:   1    4  74.38606 9.428968 5.1278888 7.136932 3.474506 17.92051 113.2767
. 7:   1    5  69.08193 9.343501 6.7697687 7.136932 3.474506 17.92051 113.2767
. 8:   1    6  64.15601 9.048795 8.3232966 7.136932 3.474506 17.92051 113.2767
.             KA      ETA_1      ETA_2      ETA_3     IPRED
. 1:  0.07397539 -0.2868385 -0.2404195 0.03496329 0.0000000
. 2:  0.07397539 -0.2868385 -0.2404195 0.03496329 0.0000000
. 3:  0.07397539 -0.2868385 -0.2404195 0.03496329 0.2994836
. 4:  0.07397539 -0.2868385 -0.2404195 0.03496329 0.4451145
. 5:  0.07397539 -0.2868385 -0.2404195 0.03496329 0.5077680
. 6:  0.07397539 -0.2868385 -0.2404195 0.03496329 0.5261551
. 7:  0.07397539 -0.2868385 -0.2404195 0.03496329 0.5213859
. 8:  0.07397539 -0.2868385 -0.2404195 0.03496329 0.5049408
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
