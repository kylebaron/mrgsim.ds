#' @export
#' @md
refresh_ds <- function(x, ...) UseMethod("refresh_ds")
#' @export
refresh_ds.mrgsimsds <- function(x, ...) {
  x$ds <- open_dataset(x$files)
  x
}
#' @export
refresh_ds.list <- function(x, ...) {
  classes <- simlist_classes(x)
  if(!any(classes)) {
    abort("no mrgsimsds objects to refresh.")  
  }
  x[classes] <- lapply(x[classes], refresh_ds)
  x
}
