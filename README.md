
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

mod <- modlib_ds("popex", Req = "IPRED")

data <- expand.ev(amt = 100, ID = 1:1000)
```

mrgsim.ds provides a new `mrgsim()` variant - `mrgsim_ds()`:

``` r
out <- mrgsim_ds(mod, data)

out
. Model: popex
. Dim  : 482.0K 9
. Files: 1 [16 Mb]
.     ID time       GUT      CENT        CL        V        ECL     IPRED
. 1:   1  0.0   0.00000  0.000000 0.6918132 15.40637 -0.3684394 0.0000000
. 2:   1  0.0 100.00000  0.000000 0.6918132 15.40637 -0.3684394 0.0000000
. 3:   1  0.5  90.70430  9.190446 0.6918132 15.40637 -0.3684394 0.5965355
. 4:   1  1.0  82.27270 17.322530 0.6918132 15.40637 -0.3684394 1.1243746
. 5:   1  1.5  74.62487 24.499163 0.6918132 15.40637 -0.3684394 1.5901971
. 6:   1  2.0  67.68797 30.813591 0.6918132 15.40637 -0.3684394 2.0000554
. 7:   1  2.5  61.39590 36.350294 0.6918132 15.40637 -0.3684394 2.3594329
. 8:   1  3.0  55.68872 41.185802 0.6918132 15.40637 -0.3684394 2.6732971
.            DV
. 1:  0.0000000
. 2:  0.0000000
. 3:  0.5965355
. 4:  1.1243746
. 5:  1.5901971
. 6:  2.0000554
. 7:  2.3594329
. 8:  2.6732971
```

The output object doesn’t actually carry the simulated data, but rather
a pointer to the data in parquet files on your disk.

``` r
as_arrow_ds(out)
. FileSystemDataset with 1 Parquet file
. 9 columns
. ID: double
. time: double
. GUT: double
. CENT: double
. CL: double
. V: double
. ECL: double
. IPRED: double
. DV: double
. 
. See $metadata for additional Schema metadata
```

``` r
plot(out)
```

<img src="man/figures/README-unnamed-chunk-5-1.png" alt="" width="100%" />
