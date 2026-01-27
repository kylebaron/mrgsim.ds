setClass("mrgsimsds")

#' @export
as_mrgsimsds <- function(out, file = tempfile(), verbose = FALSE) {

  verbose <- isTRUE(verbose)
  
  if(verbose) message("Writing to parquet.")
  arrow::write_parquet(x = out@data, sink = file)
  
  if(verbose) message("Wrapping up.")
  ans <- list()
  ans$ds <- open_dataset(file)
  ans$files <- ans$ds$files
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
mrgsim_ds <- function(x,  ..., file = tempfile(), verbose = FALSE) {
  verbose <- isTRUE(verbose)
  if(verbose) message("Simulating.")
  out <- mrgsim(x, output = NULL, ...)
  ans <- as_mrgsimsds(out = out, file = file, verbose = verbose)
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
