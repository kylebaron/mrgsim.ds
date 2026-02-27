#' Set collection status for mrgsimsds objects
#' 
#' @param x a list of mrgsimsds objects or a single mrgsimsds object.
#' @param ... not used.
#' 
#' @examples
#' mod <- modlib_ds("popex", outvars = "IPRED")
#' 
#' data <- ev_expand(amt = 100, ID = 1:5)
#' 
#' out <- mrgsim_ds(mod, data)
#' 
#' out <- gc_ds(out, value = FALSE)
#' 
#' out <- gc_ds(out, value = TRUE)
#' 
#' out <- lapply(1:3, function(rep) {
#'   out <- mrgsim_ds(mod, data) 
#'   out
#' })
#' 
#' out <- gc_ds(out, value = FALSE)
#' 
#' @return 
#' An mrgsimsds object or a list of those objects is returned, potentially
#' with the `gc` status updated. 
#' 
#' @export
gc_ds <- function(x, ...) UseMethod("gc_ds")
#' @export
gc_ds.mrgsimsds <- function(x, value, ...) {
  x$gc <- isTRUE(value)
  invisible(x)
}

#' @export
gc_ds.list <- function(x, value ...) {
  x <- lapply(x, gc_ds, value = value)
  x
}
