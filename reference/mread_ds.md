# Read a model specification file for 'Apache' 'Arrow'-backed simulation outputs

These are very-light wrappers around mrgsolve functions used to load
models for simulation.

## Usage

``` r
mread_ds(...)

mcode_ds(...)

modlib_ds(...)

house_ds(...)

mread_cache_ds(...)
```

## Arguments

- ...:

  passed to the corresponding mrgsolve function.

## See also

[`save_process_info()`](https://kylebaron.github.io/mrgsim.ds/reference/save_process_info.md).

## Examples

``` r
mod <- house_ds()

mod
#> 
#> 
#> --------------  source: housemodel.cpp  --------------
#> 
#>   project: /home/runner/wor...solve/project
#>   shared object: mrgsolve 
#> 
#>   time:          start: 0 end: 120 delta: 0.25
#>                  add: <none>
#>   compartments:  GUT CENT RESP [3]
#>   parameters:    CL VC KA F1 D1 WTCL WTVC SEXCL SEXVC
#>                  KIN KOUT IC50 WT SEX [14]
#>   captures:      DV CP [2]
#>   omega:         4x4 
#>   sigma:         1x1 
#> 
#>   solver:        rtol: 1e-08 atol: 1e-08 itol: 1 (scalar)
#> ------------------------------------------------------
```
