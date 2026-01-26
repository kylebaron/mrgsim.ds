ds_simlist_classes <- function(x) {
  classes <- vapply(
    x,
    inherits,
    "mrgsimsds",
    FUN.VALUE = TRUE,
    USE.NAMES = FALSE
  )
  classes
}

ds_simlist_models <- function(x) {
  models <- vapply(
    x,
    FUN = function(xx) xx$mod@model,
    FUN.VALUE = "model",
    USE.NAMES = FALSE
  )
  models <- models==models[1]
  models
}

# Return a list of the column names
ds_simlist_cols <- function(x) {
  cols <- lapply(x, function(xx) xx$names)
  cols <- vapply(
    cols,
    FUN = setequal,
    FUN.VALUE = TRUE,
    USE.NAMES = FALSE,
    y = cols[[1]]
  )
  cols
}

# Return the files from a simlist
ds_simlist_files <- function(x) {
  files <- vapply(
    x,
    FUN = function(xx) xx$files,
    FUN.VALUE = "filename",
    USE.NAMES = FALSE
  )
  files
}

ds_simlist_merge_ok <- function(x) {
  classes <- ds_simlist_classes(x)
  if(!all(classes)) {
    abort("all objects in list must inherit from `mrgsimsds`.")
  }
  models <- ds_simlist_models(x)
  if(!all(models)) {
    abort(
      message = "all objects in list must be derived from the same model.",
      body = "consider using `mrgsim.ds::extract_ds()` instead."
    )
  }
  cols <- ds_simlist_cols(x)
  if(!all(cols)) {
    abort(
      message = "all objects in list must have the same column names.",
      body = "consider using `mrgsim.ds::extract_ds()` instead."
    )
  }
  files <- ds_simlist_files(x)
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
  ds_simlist_merge_ok(x)
  files <- ds_simlist_files(x)
  x <- x[[1]]
  x$ds <- open_dataset(sources = files)
  x$files <- x$ds$files
  class(x) <- c("mrgsimsds", "list")
  x
}

#' @export
extract_ds <- function(x, ...) UseMethod("extract_ds")
#' @export
extract_ds.mrgsimsds <- function(x, ...) {
  x <- safe_ds(x)
  x$ds
}
#' @export
extract_ds.list <- function(x, unique_files = TRUE, ...) {
  classes <- ds_simlist_classes(x)
  x <- x[classes]
  if(isTRUE(unique_files)) {
    files <- ds_simlist_files(x)
    x <- x[!duplicated(files)]
  }
  files <- ds_simlist_files(x)
  open_dataset(sources = files)
}
