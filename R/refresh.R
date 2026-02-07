#' Refresh the arrow dataset pointers.
#' 
#' Pointers to arrow data sets will be invalid when 
#' the simulation is run in a different process, for 
#' example when simulating in parallel. The pointers
#' should be refreshed on the head node once the 
#' simulation is finished. 
#' 
#' @param x an mrgsimsds object. 
#' @param ... for future use.
#' 
#' @examples
#' mod <- mrgsolve::house()
#' data <- ev_expand(amt = 100, ID = 1:100)
#' 
#' out <- lapply(1:3, function(rep) {
#'   out <- mrgsim_ds(mod, data) 
#'   out
#' })
#' out <- refresh_ds(out)
#' 
#' @rdname refresh_ds
#' @export
refresh_ds <- function(x, ...) UseMethod("refresh_ds")
#' @rdname refresh_ds
#' @export
refresh_ds.mrgsimsds <- function(x, ...) {
  files_exist(x, fatal = TRUE)
  x$ds <- open_dataset(x$files)
  x$dim <- dim(x$ds)
  x$pid <- Sys.getpid()
  x
}

#' @rdname refresh_ds
#' @export
refresh_ds.list <- function(x, ...) {
  classes <- simlist_classes(x)
  x[classes] <- lapply(x[classes], refresh_ds)
  x
}
