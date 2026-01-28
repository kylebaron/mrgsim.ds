#' Coerce an mrgsimsds object to an arrow table
#' 
#' @param x an mrgsimsds object. 
#' @param ... passed to [arrow::as_arrow_table()]. 
#'
#' @export
as_arrow_table.mrgsimsds <- function(x, ...) {
  x <- safe_ds(x)
  as_arrow_table(x$ds, ...)
}

#' Coerce an mrgsimsds object to a tibble
#' 
#' @param x an mrgsimsds object. 
#' @param ... passed to [dplyr::as_tibble()] or 
#' [dplyr::collect()]. 
#'
#' @export
as_tibble.mrgsimsds <- function(x, ...) {
  x <- safe_ds(x)
  as_tibble(x$ds, ...)  
}
#' @rdname as_tibble.mrgsimsds
#' @export
collect.mrgsimsds <- function(x, ...) {
  x <- safe_ds(x)
  collect(x$ds, ... )  
}

#' Coerce an mrgsimsds object to an arrow data set
#' 
#' @param x an mrgsimsds object. 
#' @param ... not used. 
#' 
#' @details
#' The method for list will retain only list positions containing an `mrgsimsds`
#' object. A single data set object is returned.
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
  classes <- simlist_classes(x)
  x <- x[classes]
  if(isTRUE(unique_files)) {
    files <- simlist_files(x)
    x <- x[!duplicated(files)]
  }
  files <- simlist_files(x)
  open_dataset(sources = files)
}
