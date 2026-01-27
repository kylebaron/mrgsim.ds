#' @export
#' @md
as_arrow_table.mrgsimsds <- function(x, ...) {
  x <- safe_ds(x)
  as_arrow_table(x$ds)
}

#' @export
#' @md
as_tibble.mrgsimsds <- function(x, ...) {
  x <- safe_ds(x)
  as_tibble(x$ds)  
}

#' @export
#' @md
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

#' @export
collect.mrgsimsds <- function(x, ...) {
  x <- safe_ds(x)
  collect(x$ds)  
}
