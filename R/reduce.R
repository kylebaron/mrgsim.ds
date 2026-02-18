simlist_reduce_ok <- function(x) {
  classes <- simlist_classes(x)
  if(!all(classes)) {
    abort("all objects in list must inherit from `mrgsimsds`.")
  }
  models <- simlist_models(x)
  if(!all(models)) {
    abort(
      message = "all objects in list must be derived from the same model.",
    )
  }
  cols <- simlist_cols(x)
  if(!all(cols)) {
    abort(
      message = "all objects in list must have the same column names.",
    )
  }
  files <- simlist_files(x)
  if(length(files) != length(unique(files))) {
    abort(
      message = "duplicate files found in list.",
    )
  }
}


#' Reduce a list of mrgsimsds objects into a single object
#' 
#' @param x a list of mrgsimsds objects or a single mrgsimsds object.
#' @param ... not used.
#' 
#' @details
#' When `x` is a list, a new object is created and returned. This new object
#' will take ownership for all the files from the objects in the list. 
#' 
#' When `x` is an mrgsimsds object, it will be returned invisibly with no 
#' modification.
#' 
#' @examples
#' mod <- modlib_ds("1005", outvars = "IPRED")
#' 
#' data <- ev_expand(amt = 100, ID = 1:100)
#' 
#' out <- lapply(1:3, function(rep) {
#'   out <- mrgsim_ds(mod, data) 
#'   out
#' })
#' 
#' length(out)
#' 
#' sims <- reduce_ds(out)
#' 
#' sims
#' 
#' check_ownership(sims)
#' 
#' lapply(out, check_ownership)
#' 
#' @export
reduce_ds <- function(x, ...) UseMethod("reduce_ds")
#' @export
reduce_ds.mrgsimsds <- function(x, ...) {
  check_files_fatal(x)
  x <- safe_ds(x)
  invisible(x)
}
#' @export
reduce_ds.list <- function(x, ...) {
  simlist_reduce_ok(x)
  x <- refresh_ds(x)
  files <- simlist_files(x)
  ans <- copy_ds(x[[1]], own = TRUE)
  run_gc <- isTRUE(ans$gc)
  disown(ans)
  sapply(x, disown)
  rm(x)
  ans$files <- files
  ans$ds <- open_dataset(sources = ans$files)
  ans$files <- ans$ds$files
  ans$dim <- dim(ans$ds)
  ans$pid <- Sys.getpid()
  if(run_gc) set_finalizer_ds(ans)
  class(ans) <- c("mrgsimsds", "environment")
  take_ownership(ans)
  ans
}
