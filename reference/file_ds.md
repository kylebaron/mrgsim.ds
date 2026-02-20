# Create an output file name

Create an output file name

## Usage

``` r
file_ds(id = NULL)
```

## Arguments

- id:

  a tag used to form the file name; if not provided, a random name will
  be generated.

## Value

A character file name.

## Examples

``` r
file_ds()
#> [1] "mrgsims-ds-1b9cff53254.parquet"
file_ds("example")
#> [1] "mrgsims-ds-example.parquet"
```
