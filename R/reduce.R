simlist_reduce_ok <- function(x) {
  classes <- simlist_classes(x)
  if(!all(classes)) {
    abort("all objects in list must inherit from `mrgsimsds`.")
  }
  models <- simlist_models(x)
  if(!all(models)) {
    abort(
      message = "all objects in list must be derived from the same model.",
      body = "consider using `mrgsim.ds::extract_ds()` instead."
    )
  }
  cols <- simlist_cols(x)
  if(!all(cols)) {
    abort(
      message = "all objects in list must have the same column names.",
      body = "consider using `mrgsim.ds::extract_ds()` instead."
    )
  }
  files <- simlist_files(x)
  if(length(files) != length(unique(files))) {
    abort(
      message = "duplicate files found in list.",
      body = "consider using `mrgsim.ds::extract_ds()` instead."
    )
  }
}

#' @export
reduce_ds <- function(x, ...) UseMethod("reduce_ds")
#' @export
reduce_ds.mrgsimsds <- function(x, ...) {
  x <- safe_ds(x)
  x
}
#' @export
reduce_ds.list <- function(x) {
  simlist_reduce_ok(x)
  files <- simlist_files(x)
  x <- x[[1]]
  x$ds <- open_dataset(sources = files)
  x$files <- x$ds$files
  x$dim <- dim(x$ds)
  x$pid <- Sys.getpid()
  class(x) <- c("mrgsimsds", "list")
  x
}
