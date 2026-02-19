# Coerce an mrgsimsds object to an arrow data set

Coerce an mrgsimsds object to an arrow data set

## Usage

``` r
as_arrow_ds(x, ...)
```

## Arguments

- x:

  an mrgsimsds object or a list of mrgsimsds objects.

- ...:

  not used.

## Value

An 'Apache' 'Arrow'
[arrow::Dataset](https://arrow.apache.org/docs/r/reference/Dataset.html)
object.

## Details

The method for list will retain only list positions containing an
`mrgsimsds` object. A single data set object is returned.

## Examples

``` r
mod <- house_ds(end = 5)

out <- mrgsim_ds(mod, events = ev(amt = 100))

as_arrow_ds(out)
#> FileSystemDataset with 1 Parquet file
#> 7 columns
#> ID: double
#> time: double
#> GUT: double
#> CENT: double
#> RESP: double
#> DV: double
#> CP: double
#> 
#> See $metadata for additional Schema metadata
```
