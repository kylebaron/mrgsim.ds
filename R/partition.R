# HOLD THIS CODE---
#' #' @export
#' partition_ds <- function(x, ...) UseMethod("partition_ds")
#' #' @export
#' partition_ds.mrgsimsds <- function(x, partitioning, file = tempfile()) {
#'   x <- safe_ds(x)
#'   old_files <- x$files
#'   write_dataset(x$ds, path = file, partitioning = partitioning)
#'   unlink(old_files)
#'   x$ds <- open_dataset(file)
#'   x$files <- x$ds$files
#'   x$pid <- Sys.getpid()
#'   x
#' }
