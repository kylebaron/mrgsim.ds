# Package index

## Read or load models

Functions to read models configured for use with
[`mrgsim_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsim_ds.md).

- [`mread_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mread_ds.md)
  [`mcode_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mread_ds.md)
  [`modlib_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mread_ds.md)
  [`house_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mread_ds.md)
  [`mread_cache_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mread_ds.md)
  : Read a model specification file for 'Apache' 'Arrow'-backed
  simulation outputs

## Generate Apache Arrow Dataset-backed simulation outputs

Simulate and write output to disk.

- [`mrgsim_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsim_ds.md)
  : Simulate from a model object, returning an arrow-backed output
  object
- [`as_mrgsim_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/as_mrgsim_ds.md)
  : Coerce an mrgsims object to 'Arrow'-backed mrgsimsds object

## S3 Methods

Work with
[`mrgsim_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsim_ds.md)
output.

- [`dim(`*`<mrgsimsds>`*`)`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsimsds-methods.md)
  [`head(`*`<mrgsimsds>`*`)`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsimsds-methods.md)
  [`tail(`*`<mrgsimsds>`*`)`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsimsds-methods.md)
  [`names(`*`<mrgsimsds>`*`)`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsimsds-methods.md)
  [`plot(`*`<mrgsimsds>`*`)`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsimsds-methods.md)
  : Interact with mrgsimsds objects

## Move or rename outputs

- [`move_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/move_ds.md)
  [`rename_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/move_ds.md)
  [`write_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/move_ds.md)
  : Move, rename, or write out data set files

## Manage or query ownership

This applies to parquet files holding simulation outputs.

- [`ownership()`](https://kylebaron.github.io/mrgsim.ds/reference/ownership.md)
  [`list_ownership()`](https://kylebaron.github.io/mrgsim.ds/reference/ownership.md)
  [`check_ownership()`](https://kylebaron.github.io/mrgsim.ds/reference/ownership.md)
  [`disown()`](https://kylebaron.github.io/mrgsim.ds/reference/ownership.md)
  [`take_ownership()`](https://kylebaron.github.io/mrgsim.ds/reference/ownership.md)
  : Ownership of simulation files
- [`copy_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/copy_ds.md)
  : Copy an mrgsimsds object

## Work with lists of mrgsimsds objects

Commonly needed after batch simulation in parallel

- [`reduce_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/reduce_ds.md)
  : Reduce a list of mrgsimsds objects into a single object
- [`refresh_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/refresh_ds.md)
  : Refresh 'Arrow' dataset pointers.
- [`prune_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/prune_ds.md)
  : Prune a list of mrgsimsds objects

## Manage simulation outputs in `tempdir()`

- [`list_temp()`](https://kylebaron.github.io/mrgsim.ds/reference/list_temp.md)
  [`retain_temp()`](https://kylebaron.github.io/mrgsim.ds/reference/list_temp.md)
  [`purge_temp()`](https://kylebaron.github.io/mrgsim.ds/reference/list_temp.md)
  : Manage simulated outputs in tempdir()

## Utility functions

- [`file_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/file_ds.md)
  : Create an output file name
- [`save_process_info()`](https://kylebaron.github.io/mrgsim.ds/reference/save_process_info.md)
  : Save information about the R process that loaded a model
- [`is_mrgsimsds()`](https://kylebaron.github.io/mrgsim.ds/reference/is_mrgsimsds.md)
  : Check if object inherits mrgsimsds

## Coerce output to an R object

- [`as_tibble(`*`<mrgsimsds>`*`)`](https://kylebaron.github.io/mrgsim.ds/reference/as_tibble.mrgsimsds.md)
  [`collect(`*`<mrgsimsds>`*`)`](https://kylebaron.github.io/mrgsim.ds/reference/as_tibble.mrgsimsds.md)
  [`as.data.frame(`*`<mrgsimsds>`*`)`](https://kylebaron.github.io/mrgsim.ds/reference/as_tibble.mrgsimsds.md)
  : Coerce an mrgsimsds object to a tbl
- [`as_arrow_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/as_arrow_ds.md)
  : Coerce an mrgsimsds object to an arrow data set
- [`as_arrow_table(`*`<mrgsimsds>`*`)`](https://kylebaron.github.io/mrgsim.ds/reference/as_arrow_table.mrgsimsds.md)
  : Coerce an mrgsimsds object to an arrow table
- [`as_duckdb_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/as_duckdb_ds.md)
  : Coerce an mrgsimsds object to a DuckDB table
