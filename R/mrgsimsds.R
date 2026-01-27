setClass("mrgsimsds")

#' Coerce an mrgsims object to arrow-backed mrgsimsds
#' 
#' @param x an mrgsims object. 
#' @param file path to file where output will be written using 
#' [arrow::write_dataset()].
#' @param verbose if `TRUE`, print progress information to the console.
#' 
#' @examples
#' mod <- modlib("pk1")
#' data <- expand.ev(amt = 100, ID = 1:10)
#' out <- mrgsim(mod, data)
#' obj <- as_mrgsimsds(obj)
#' 
#' @return
#' An object with class `mrgsimsds`.
#' 
#' @seealso [mrgsim_ds()].
#' 
#' @export
as_mrgsimsds <- function(x, file = tempfile(), verbose = FALSE) {

  verbose <- isTRUE(verbose)
  
  if(verbose) message("Writing to parquet.")
  write_parquet(x = x@data, sink = file)
  
  if(verbose) message("Wrapping up.")
  ans <- list()
  ans$ds <- open_dataset(file)
  ans$files <- ans$ds$files
  ans$mod <- x@mod
  ans$dim <- dim(ans$ds)
  ans$head <- x@data[seq(20), ]
  ans$names <- names(ans$head)
  ans$pid <- Sys.getpid()
  
  rm(x)
  
  class(ans) <- c("mrgsimsds", "list")
  
  ans
}

#' Simulate from a model object, returning an arrow-backed output object
#' 
#' @inheritParams as_mrgsimsds
#' @param x a model object. 
#' @param ... passed to [mrgsolve::mrgsim()]. 
#' 
#' @examples
#' mod <- modlib("1005")
#' data <- expand.ev(amt = 100, ID = 1:10)
#' out <- mrgsim_ds(mod, data, end = 72, delta = 0.1)
#' out
#' 
#' @return 
#' An object with class `mrgsimsds`.
#' 
#' @export
mrgsim_ds <- function(x,  ..., file = tempfile(), verbose = FALSE) {
  verbose <- isTRUE(verbose)
  if(verbose) message("Simulating.")
  out <- mrgsim(x, output = NULL, ...)
  ans <- as_mrgsimsds(x = out, file = file, verbose = verbose)
  ans
}

#' Return the first several rows of the object. 
#' 
#' @param x a object with class `mrgsimsds`.
#' @param n number of rows to show.  
#' @param ... passed to [head()].
#' @export
setMethod("head", "mrgsimsds", function(x, n = 6L, ...) {
  if(n > nrow(x$head)) {
    msg <- "there are only {nrow(x$head)} rows available for head()."
    warn(glue(msg))  
  }
  head(x$head, n = n, ...)
})

#' @export
setMethod("tail", "mrgsimsds", function(x,...) {
  abort("there is no `tail()` method for this object (mrgsimsds).") 
})

#' @export
dim.mrgsimsds <- function(x) {
  x$dim
}

#' @export
nrow.mrgsimsds <- function(x) {
  x$dim[1L]
}

#' @export
ncol.mrgsimsds <- function(x) {
  x$dim[2L]
}

#' @export
plot.mrgsimsds <- function(x, y, ...) {
  abort("no print method for mrgsimsds objects.")
  # ds <- as_arrow_ds(x)
  # h <- head(ds, 1)
  # h <- collect(h)
  # data <- filter(ds, ID %in% h$ID[1])
  # data <- collect(data)
  # time <- names(data)[2]
  # vars <- names(data)[seq(3, ncol(data), 1)]
  # lhs <- paste0(vars, collapse = "+")
  # form <- paste0(lhs, "~", time)
  # form <- as.formula(form)
  # plot_sims(data, .f = form)
}
