# Coerce an mrgsimsds object to a DuckDB table

Coerce an mrgsimsds object to a DuckDB table

## Usage

``` r
as_duckdb_ds(x, ...)
```

## Arguments

- x:

  an mrgsimsds object or a list of mrgsimsds objects.

- ...:

  passed to
  [`as_arrow_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/as_arrow_ds.md).

## Value

A `tbl` of the simulated data in DuckDB; see
[`arrow::to_duckdb()`](https://arrow.apache.org/docs/r/reference/to_duckdb.html).

## Details

The conversion is handled by
[`as_arrow_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/as_arrow_ds.md).

## See also

[`as_arrow_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/as_arrow_ds.md)

## Examples

``` r
mod <- house_ds(end = 5)

out <- mrgsim_ds(mod, events = ev(amt = 100))

if(requireNamespace("duckdb")) {
  as_duckdb_ds(out)
}
#> Loading required namespace: duckdb
#> Error in check_dbplyr(): The package "dbplyr" is required to communicate with database backends.
```
