#' Coerce an mrgsimsds object to an arrow table
#' 
#' @param x an mrgsimsds object. 
#' @param ... passed to [arrow::as_arrow_table()]. 
#' 
#' @examples
#' mod <- house_ds(end = 5)
#' out <- mrgsim_ds(mod, events = ev(amt = 100))
#' 
#' arrow::as_arrow_table(out)
#' 
#' @return
#' An 'Apache' 'Arrow' [arrow::Table] of simulated data.
#'
#' @export
as_arrow_table.mrgsimsds <- function(x, ..., schema = NULL) {
  x <- safe_ds(x)
  as_arrow_table(x$ds, ...)
}

#' Coerce an mrgsimsds object to a tbl
#' 
#' @param x an mrgsimsds object. 
#' @param ... passed to [dplyr::as_tibble()] or [dplyr::collect()]. 
#' 
#' @examples
#' mod <- house_ds(end = 5)
#' out <- mrgsim_ds(mod, events = ev(amt = 100))
#' 
#' tibble::as_tibble(out)
#' dplyr::collect(out)
#' 
#' @return
#' A `tbl` containing simulated data. 
#'
#' @export
as_tibble.mrgsimsds <- function(x, ...) {
  x <- safe_ds(x)
  dplyr::as_tibble(x$ds, ...)  
}
#' @rdname as_tibble.mrgsimsds
#' @export
collect.mrgsimsds <- function(x, ...) {
  x <- safe_ds(x)
  dplyr::collect(x$ds, ... )  
}

#' Coerce an mrgsimsds object to an arrow data set
#' 
#' @param x an mrgsimsds object or a list of mrgsimsds objects. 
#' @param ... not used. 
#' 
#' @details
#' The method for list will retain only list positions containing an `mrgsimsds`
#' object. A single data set object is returned.
#' 
#' @examples
#' mod <- house_ds(end = 5)
#' out <- mrgsim_ds(mod, events = ev(amt = 100))
#' 
#' as_arrow_ds(out)
#' 
#' @return
#' An 'Apache' 'Arrow' [arrow::Dataset] object.
#' 
#' @export
as_arrow_ds <- function(x, ... ) UseMethod("as_arrow_ds")
#' @export
as_arrow_ds.mrgsimsds <- function(x, ...) {
  x <- safe_ds(x)
  x$ds
}
#' @export
as_arrow_ds.list <- function(x, unique_files = TRUE, ...) {
  x <- prune_ds(x, inform = TRUE)
  if(isTRUE(unique_files)) {
    files <- simlist_files(x)
    x <- x[!duplicated(files)]
  }
  files <- simlist_files(x)
  open_dataset(sources = files)
}

#' Coerce an mrgsimsds object to a DuckDB table
#' 
#' @param x an mrgsimsds object or a list of mrgsimsds objects. 
#' @param ... passed to [as_arrow_ds()]. 
#' 
#' @details
#' The conversaion is handled by [as_arrow_ds()].
#' 
#' @examples
#' mod <- house_ds(end = 5)
#' out <- mrgsim_ds(mod, events = ev(amt = 100))
#' 
#' as_duckdb_ds(out)
#' 
#' @return
#' A `tbl` of the simulated data in DuckDB; see [arrow::to_duckdb()].
#' 
#' @seealso [as_arrow_ds()]
#' 
#' @export
as_duckdb_ds <- function(x, ...) UseMethod("as_duckdb_ds")
#' @export
as_duckdb_ds.mrgsimsds <- function(x, ...) {
  to_duckdb(as_arrow_ds(x, ...))  
}
#' @export
as_duckb_ds.list <- function(x, ...) {
  to_duckdb(as_arrow_ds(x, ...))  
}
