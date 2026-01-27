valid_ds <- function(x) {
  !identical(x$ds$pointer(), new("externalptr"))  
}

safe_ds <- function(x) {
  if(!valid_ds(x)) x <- refresh_ds(x)
  x
}

#' @export
#' @md
is_mrgsimsds <- function(x) {
  inherits(x, "mrgsimsds")  
}
