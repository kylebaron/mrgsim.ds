
#' Coerce an mrgsims object to arrow-backed mrgsimsds object
#' 
#' @param x an mrgsims object. 
#' @param file path to file where output will be written using 
#' [arrow::write_parquet()].
#' @param verbose if `TRUE`, print progress information to the console.
#' 
#' @examples
#' mod <- mrgsolve::house()
#' data <- mrgsolve::ev_expand(amt = 100, ID = 1:10)
#' out <- mrgsolve::mrgsim(mod, data)
#' obj <- as_mrgsim_ds(out)
#' 
#' @return
#' An object with class `mrgsimsds`.
#' 
#' @seealso [mrgsim_ds()].
#' 
#' @export
as_mrgsim_ds <- function(x, file = tempfile(), verbose = FALSE) {

  verbose <- isTRUE(verbose)
  
  if(verbose) message("Writing to dataset.")
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
#' @inheritParams as_mrgsim_ds
#' @param x a model object. 
#' @param ... passed to [mrgsolve::mrgsim()]. 
#' @param tag a named list of atomic data to tag (or mutate) the simulated 
#' output.
#' 
#' @examples
#' mod <- mrgsolve::house()
#' data <- mrgsolve::ev_expand(amt = 100, ID = 1:10)
#' out <- mrgsim_ds(mod, data, end = 72, delta = 0.1)
#' 
#' out <- mrgsim_ds(mod, data, tag = list(rep = 1))
#' head(out)
#' 
#' @return 
#' An object with class `mrgsimsds`.
#' 
#' @export
mrgsim_ds <- function(x,  ..., file = tempfile(), tag = list(), 
                      verbose = FALSE) {
  verbose <- isTRUE(verbose)
  if(verbose) message("Simulating.")
  out <- mrgsim(x, output = NULL, ...)
  if(is.list(tag) && length(tag)) {
    if(!is_named(tag)) {
      abort("`tag` must be a named list.")  
    }
    for(j in names(tag)) {
      out@data[[j]] <- tag[[j]]  
    }
  }
  ans <- as_mrgsim_ds(x = out, file = file, verbose = verbose)
  ans
}

#' Interact with mrgsimsds objects
#' 
#' @param x an mrgsimsds object, output from 
#' [mrgsim_ds()] or [as_mrgsim_ds()].
#' @param y not used. 
#' @param n number of rows to return.
#' @param ... arguments to be passed to or from other methods.
#' 
#' @examples
#' mod <- mrgsolve::house()
#' out <- mrgsim_ds(mod, events = mrgsolve::ev(amt = 100))
#' 
#' dim(out)
#' head(out)
#' nrow(out)
#' ncol(out)
#' head(out)
#' try(tail(out))
#' 
#' @name mrgsimsds-methods
#' @export
dim.mrgsimsds <- function(x) {
  x$dim
}

#' @name mrgsimsds-methods
#' @export
nrow.mrgsimsds <- function(x) {
  x$dim[1L]
}

#' @name mrgsimsds-methods
#' @export
ncol.mrgsimsds <- function(x) {
  x$dim[2L]
}

#' @name mrgsimsds-methods
#' @export
head.mrgsimsds <-  function(x, n = 6L, ...) {
  if(n > nrow(x$head)) {
    msg <- "there are only {nrow(x$head)} rows available for head()."
    warn(glue(msg))  
  }
  as_tibble(head(x$head, n = n, ...))
}

#' @name mrgsimsds-methods
#' @export
tail.mrgsimsds <- function(x, ...) {
  abort("there is no `tail()` method for this object (mrgsimsds).") 
}

#' @name mrgsimsds-methods
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
