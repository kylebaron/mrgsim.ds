
#' Coerce an mrgsims object to 'Arrow'-backed mrgsimsds object
#' 
#' @inheritParams mrgsim_ds
#' @param x an mrgsims object. 
#' 
#' @examples
#' mod <- house_ds()
#' 
#' data <- ev_expand(amt = 100, ID = 1:10)
#' 
#' out <- mrgsolve::mrgsim(mod, data)
#' 
#' obj <- as_mrgsim_ds(out)
#' 
#' obj
#' 
#' @return
#' An object with class `mrgsimsds`.
#' 
#' @seealso [mrgsim_ds()].
#' 
#' @export
as_mrgsim_ds <- function(x, id = NULL, verbose = FALSE, gc = TRUE) {
  
  verbose <- isTRUE(verbose)
  
  if(verbose) message("Writing dataset [2/3].")
  stopifnot(mread_with_ds(x@mod))
  
  dir <- get_mread_tempdir(x@mod)
  
  file <- file.path(dir, file_ds(id))
  if(grepl(" ", file)) {
    abort("output file name cannot contain spaces.")  
  }
  
  write_parquet(x = x@data, sink = file)
  
  if(verbose) message("Wrapping up [3/3].")
  
  ans <- new.env(parent = emptyenv())
  ans$ds <- open_dataset(file)
  ans$files <- ans$ds$files
  ans$mod <- x@mod
  ans$dim <- dim(ans$ds)
  ans$head <- x@data[seq(10),]
  ans$names <- names(ans$head)
  ans$pid <- Sys.getpid()
  ans$gc <- isTRUE(gc)
  
  rm(x)
  
  if(isTRUE(ans$gc)) {
    reg.finalizer(ans, clean_up_ds)
  }
  
  class(ans) <- c("mrgsimsds", "environment")
  
  ans
}

#' Simulate from a model object, returning an arrow-backed output object
#' 
#' Note that full names must be used for all arguments. 
#' 
#' @param x a model object loaded through [mread_ds()], [mcode_ds()], 
#' [modlib_ds()] or [house_ds()].
#' @param id used to label output files; see details.
#' @param ... passed to [mrgsolve::mrgsim()]. 
#' @param tags a named list of atomic data to tag (or mutate) the simulated 
#' output.
#' @param verbose if `TRUE`, print progress information to the console.
#' @param gc if `TRUE`, a finalizer function will attempt to remove files once 
#' the object is out of scope.
#' 
#' @examples
#' mod <- house_ds()
#' 
#' data <- ev_expand(amt = 100, ID = 1:10)
#' 
#' out <- mrgsim_ds(mod, data, end = 72, delta = 0.1)
#' 
#' out <- mrgsim_ds(mod, data, tags = list(rep = 1))
#' 
#' head(out)
#' 
#' @return 
#' An object with class `mrgsimsds`.
#' 
#' @seealso [as_mrgsim_ds()], [mrgsimsds-methods].
#' 
#' @export
mrgsim_ds <- function(x,  ..., id = NULL, tags = list(), verbose = FALSE, 
                      gc = TRUE) {
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
  ans <- as_mrgsim_ds(x = out, id = id, verbose = verbose, gc = gc)
  ans
}

#' Copy an mrgsims object
#' 
#' @param x the object to copy.
#' 
#' @return
#' An mrgsims object with identical fields, but updated pid. 
#' 
#' @export
copy_ds <- function(x) {
  names_in <- names(x)
  ans <- new.env(parent = emptyenv())
  ans$ds <- open_dataset(x$files)
  ans$files <- ans$ds$files
  ans$mod <- x$mod
  ans$dim <- x$dim
  ans$head <- x$head
  ans$names <- x$names
  ans$pid <- Sys.getpid()
  ans$gc <- ans$gc
  class(ans) <- c("mrgsimsds", "environment")
  names_out <- names(ans)
  stopifnot("bad copy" = identical(names_in, names_out))
  ans
}

#' Interact with mrgsimsds objects
#' 
#' @param x an mrgsimsds object, output from 
#' [mrgsim_ds()] or [as_mrgsim_ds()].
#' @param y a formula for plotting simulated data; if not provided, all 
#' columns will be plotted. 
#' @param n number of rows to return.
#' @param nid number of subjects to plot.
#' @param batch_size size of batch when reading data for plot method.
#' @param logy if `TRUE`, plot data with log y-axis.
#' @param .dots a list of items to pass to [mrgsolve::plot_sims()].
#' @param ... arguments to be passed to or from other methods.
#' 
#' @details
#' `head()` and `tail()` only look at the first and last file in the data
#' set, respectively. 
#' 
#' @examples
#' mod <- house_ds(end = 24)
#' 
#' mod <- omat(mod, diag(0.04, 4))
#' 
#' data <- ev_expand(amt = c(100, 300), ID = 1:20)
#' 
#' set.seed(10203)
#' 
#' out <- mrgsim_ds(mod, data = data)
#' 
#' dim(out)
#' head(out)
#' tail(out)
#' nrow(out)
#' ncol(out)
#' plot(out, ~ CP + RESP, nid = 10)
#' 
#' @name mrgsimsds-methods
#' @export
dim.mrgsimsds <- function(x) {
  x$dim
}

#' @name mrgsimsds-methods
#' @export
head.mrgsimsds <-  function(x, n = 6L, ...) {
  as_tibble(get_head(x, n = n))
}

#' @name mrgsimsds-methods
#' @export
tail.mrgsimsds <- function(x, n = 6L, ...) {
  x <- safe_ds(x)
  nf <- length(x$files)
  if(nf > 1) {
    ds <- open_dataset(x$files[nf])  
  } else {
    ds <- x$ds  
  }
  out <- tail(ds, n = n)
  collect(out)
}

#' @name mrgsimsds-methods
#' @export
plot.mrgsimsds <- function(x, y = NULL, ...,  nid = 5, batch_size = 20000, 
                           logy = FALSE, 
                           .dots = list()) {
  x <- safe_ds(x)
  ds <- x$ds
  scanner <- Scanner$create(ds, batch_size = batch_size)
  reader <- scanner$ToRecordBatchReader()
  count_id <- 1
  iter <- 0
  simsl <- vector(mode = "list", length = nid)
  while(count_id < (nid+2)) {
    batch <- as.data.frame(reader$read_next_batch())
    if(nrow(batch)==0) {
      count_id <- nid + 2
      break;  
    }
    iter <- iter + 1
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
  .dots$logy <- logy
  p <- plot_sims(sims, .f = y, .dots = .dots)
  print(p)
  return(invisible(sims))
}
