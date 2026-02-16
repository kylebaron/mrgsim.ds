
#' Coerce an mrgsims object to 'Arrow'-backed mrgsimsds object
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
as_mrgsim_ds <- function(x, id = NULL, verbose = FALSE) {
  
  verbose <- isTRUE(verbose)
  
  if(verbose) message("Writing dataset [2/3].")
  stopifnot(mread_with_ds(x@mod))
  
  dir <- get_mread_tempdir(x@mod)
  
  file <- file.path(dir, file_name_ds(id))
  if(grepl(" ", file)) {
    abort("output file name cannot contain spaces.")  
  }
  
  write_parquet(x = x@data, sink = file)
  
  if(verbose) message("Wrapping up [3/3].")
  
  ans <- list()
  ans$ds <- open_dataset(file)
  ans$files <- ans$ds$files
  ans$mod <- x@mod
  ans$dim <- dim(ans$ds)
  ans$head <- x@data[seq(20),]
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
mrgsim_ds <- function(x,  ..., id = NULL, tags = list(), verbose = FALSE) {
  verbose <- isTRUE(verbose)
  if(verbose) message("Simulating data [1/3].")
  out <- mrgsim(x, output = NULL, ...)
  if(is.list(tags) && length(tags)) {
    if(!is_named(tags)) {
      abort("`tags` must be a named list.")  
    }
    for(j in names(tags)) {
      out@data[[j]] <- tags[[j]]  
    }
  }
  ans <- as_mrgsim_ds(x = out, id = id, verbose = verbose)
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
plot.mrgsimsds <- function(x, y = NULL, nid = 5, batch_size = 10000, ...) {
  x <- safe_ds(x)
  ds <- x$ds
  scanner <- Scanner$create(ds, batch_size = batch_size)
  reader <- scanner$ToRecordBatchReader()
  count_id <- 1
  iter <- 0
  simsl <- vector(mode = "list", length = nid)
  while(count_id < (nid+2)) {
    iter <- iter + 1
    batch <- as.data.frame(reader$read_next_batch())
    ids <- unique(batch$ID)
    count_id <- count_id + length(ids)
    simsl[[iter]] <- batch
  }
  simsl <- simsl[seq(iter)]
  sims <- bind_rows(simsl)
  uid <- unique(sims$ID)
  uid <- uid[seq(nid)]
  sims <- sims[sims$ID %in% uid,]
  if(!rlang::is_formula(y)) {
    cols <- names(sims)
    cols <- cols[!(cols %in% c("ID", "id", "TIME", "time"))]
    y <- paste0(cols, collapse = "+")
    y <- paste0("~", y)
    y <- as.formula(y, env = emptyenv())
  }
  print(plot_sims(sims, .f = y))
  return(invisible(sims))
}
