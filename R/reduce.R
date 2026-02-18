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
#' @examples
#' mod <- modlib_ds("1005")
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
#' out <- reduce_ds(out)
#' 
#' out
#' 
#' @export
reduce_ds <- function(x, ...) UseMethod("reduce_ds")
#' @export
reduce_ds.mrgsimsds <- function(x, ...) {
  files_exist(x, fatal = TRUE)
  x <- safe_ds(x)
  invisible(x)
}
#' @export
reduce_ds.list <- function(x, ...) {
  simlist_reduce_ok(x)
  files <- simlist_files(x)
  ans <- copy_ds(x[[1]])
  run_gc <- isTRUE(ans$gc)
  disown(ans)
  sapply(x, disown)
  rm(x)
  ans$files <- files
  files_exist(ans, fatal = TRUE)
  ans$ds <- open_dataset(sources = ans$files)
  ans$files <- ans$ds$files
  ans$dim <- dim(ans$ds)
  ans$pid <- Sys.getpid()
  if(run_gc) set_finalizer_ds(ans)
  class(ans) <- c("mrgsimsds", "environment")
  ans <- take_ownership(ans)
  ans
}
