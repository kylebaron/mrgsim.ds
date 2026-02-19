# Move, rename, or write out data set files

Use `move_ds()` to change the enclosing directory. `write_ds()` can also
move the files, but also condenses all simulation output in to a single
parquet file if multiple files are backing the mrgsimsds object. All
operations are made on the object in place; see **Details**.

## Usage

``` r
move_ds(x, path)

rename_ds(x, id)

write_ds(x, sink, ...)
```

## Arguments

- x:

  an mrgsimsds object.

- path:

  the new directory location for backing files.

- id:

  a short name used to create data set files for the simulated output.

- sink:

  the complete path (including file name) for a single parquet file
  containing all simulated data; passed to
  [`arrow::write_parquet()`](https://arrow.apache.org/docs/r/reference/write_parquet.html).

- ...:

  passed to
  [`arrow::write_parquet()`](https://arrow.apache.org/docs/r/reference/write_parquet.html);
  files are always written in parquet format.

## Value

All three functions return the new file list, invisibly.

## Details

There is an important distinction between `write_ds()` and `move_ds()`
or `rename_ds()` for multi-file objects. The backing files can be moved
or written easily, without much computational burden. For multi-file
simulation outputs, `write_ds()` will need to read each file and then
write the data out to a single file. Apache Arrow can do this very
efficiently, but there will still be an additional, potentially
noticeable computational burden.

When dataset files are rewritten to a single file with `write_ds()`,
those files will no longer be cleaned up when the containing R object is
finalized upon garbage collection. When dataset files are moved outside
of [`tempdir()`](https://rdrr.io/r/base/tempfile.html), those files,
too, will no longer be cleaned up on garbage collection; but file
cleanup will continue to occur as long as the files remain under
[`tempdir()`](https://rdrr.io/r/base/tempfile.html). No change in
finalization behavior due to garbage collection of the containing object
will happen when files are renamed.

All three functions modify `x` in place and file ownership stays with
`x`.

## Examples

``` r
mod <- house_ds()

out <- lapply(1:3, \(x) { mrgsim_ds(mod, events = ev(amt = 100)) })

out <- reduce_ds(out)

rename_ds(out, id = "example-sims")

basename(out$files)
#> [1] "mrgsims-ds-example-sims-0001.parquet"
#> [2] "mrgsims-ds-example-sims-0002.parquet"
#> [3] "mrgsims-ds-example-sims-0003.parquet"

write_ds(out, sink = file.path(tempdir(), "example.parquet"))

basename(out$files)
#> [1] "example.parquet"

if (FALSE) { # \dontrun{
  move_ds(out, path = "data/simulated") 
} # }
```
