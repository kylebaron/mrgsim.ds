setClass("mrgsimsds")

check_mrgsimsds <- function(x) {
  if(!is_mrgsimsds(x)) {
    abort("`x` is not an mrgsimsds object.", call = rlang::caller_env()) 
  }
}

valid_ds_abort <- function(x) {
  invalid <- !valid_ds(x)
  if(invalid) {
    abort("dataset pointer is invalid; run refresh_ds().", call = caller_env())  
  }
}
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

#' @export
#' @md
as_mrgsimsds <- function(out, file = tempfile(), verbose = FALSE) {

  verbose <- isTRUE(verbose)
  
  if(verbose) message("Writing to parquet.")
  arrow::write_parquet(x = out@data, sink = file)
  
  if(verbose) message("Wrapping up.")
  ans <- list()
  ans$files <- normalizePath(file)
  ans$ds <- arrow::open_dataset(file)
  ans$mod <- out@mod
  ans$dim <- dim(ans$ds)
  ans$head <- out@data[seq(20), ]
  ans$names <- names(ans$head)
  ans$pid <- Sys.getpid()
  
  rm(out)
  
  class(ans) <- c("mrgsimsds", "list")
  
  ans
}


#' @export
#' @md
mrgsim_ds <- function(x,  ..., file = tempfile(), verbose = FALSE) {
  verbose <- isTRUE(verbose)
  if(verbose) message("Simulating.")
  out <- mrgsim(x, output = NULL, ...)
  ans <- as_mrgsimsds(out = out, file = file, verbose = verbose)
  ans
}

#' @export
#' @md
as_table_sims <- function(x, ...) {
  check_mrgsimsds(x)
  x <- safe_ds(x)
  as_arrow_table(x$ds)
}

#' @export
#' @md
as_tibble_sims <- function(x, ...) {
  check_mrgsimsds(x)
  x <- safe_ds(x)
  tibble::as_tibble(x$ds)  
}

#' @export
#' @md
as_ds_sims <- function(x, ...) {
  check_mrgsimsds(x)
  x <- safe_ds(x)
  x$ds
}

#' @export
#' @md
refresh_ds <- function(x, ...) UseMethod("refresh_ds")
#' @export
refresh_ds.mrgsimsds <- function(x, ...) {
  x$ds <- arrow::open_dataset(x$files)
  x
}
#' @export
refresh_ds.list <- function(x, ...) {
  x <- lapply(x, refresh_ds)
  x
}

#' @export
#' @md
print.mrgsimsds <- function(x, n = 8, ...) {
  dm <- x$dim
  size <- sum(sapply(x$files, file.size))
  class(size) <- "object_size"
  size <- format(size, units = "auto")
  message("Model: ", x$mod@model)
  message("Dim  : ", dm[1L], " ", dm[2L])
  message("Files: ", length(x$files), " [", size, "]")
  chunk <- head(x$head, n = n)
  rownames(chunk) <- paste0(seq(nrow(chunk)), ": ")
  print(chunk)
  invalid <- identical(x$ds$pointer(), new("externalptr"))
  if(invalid) {
    message("! pointer is invalid; run refresh_ds().")  
  }
  return(invisible(NULL))
}

#' Return the first several rows of the object. 
#' 
#' @param x a object with class `mrgsimsds`.
#' @param n number of rows to show.  
#' @param ... passed to [head()].
#' @export
#' @md
setMethod("head", "mrgsimsds", function(x, n = 6L, ...) {
  if(n > nrow(x$head)) {
    msg <- "there are only {nrow(x$head)} rows available for head()."
    warn(glue(msg))  
  }
  head(x$head, n = n, ...)
})

#' @export
#' @md
setMethod("tail", "mrgsimsds", function(x,...) {
  abort("there is no `tail()` method for this object (mrgsimsds).") 
})

#' 
#' @export
#' @md
dim.mrgsimsds <- function(x) {
  x$dim
}

#' @export
#' @md
nrow.mrgsimsds <- function(x) {
  x$dim[1L]
}

#' @export
#' @md
ncol.mrgsimsds <- function(x) {
  x$dim[2L]
}

#' @export
#' @md
setMethod("plot", "mrgsimsds", function(x,...) {
  abort("there is no `plot()` method for this object (mrgsimsds).")
})
