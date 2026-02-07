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


#' Reduce a list of mrgsimsds objects into a single object
#' 
#' @param x a list of mrgsimsds objects or a single mrgsimds object.
#' @param ... not used.
#' 
#' @examples
#' mod <- modlib("1005")
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
  x
}
#' @export
reduce_ds.list <- function(x, ...) {
  simlist_reduce_ok(x)
  files <- simlist_files(x)
  x <- x[[1]]
  x$files <- files
  files_exist(x, fatal = TRUE)
  x$ds <- open_dataset(sources = x$files)
  x$dim <- dim(x$ds)
  x$pid <- Sys.getpid()
  class(x) <- c("mrgsimsds", "list")
  x
}

#' Prune a list of mrgsimsds objects
#' 
#' @param x a list of mrgsimsds objects or a single mrgsimsds object.
#' @param inform issue a message when objects in some list slots are dropped. 
#' @param ... not used. 
#' 
#' @examples
#' mod <- house(end = 24)
#' 
#' out <- mrgsim_ds(mod, events = ev(amt = 100))
#' 
#' sims <- list(out, letters)
#' 
#' prune_ds(sims)
#' 
#' @export
prune_ds <- function(x, ...) UseMethod("prune_ds")
#' @export
prune_ds.mrgsimsds <- function(x, ...) {
  x  
}
#' @export
prune_ds.list <- function(x, inform = TRUE, ...) {
  cl <- simlist_classes(x)
  if(isTRUE(inform) && !all(cl)) {
    n <- sum(!cl)
    msg <- "dropping {n} objects that are not mrgsimsds."
    inform(glue(msg))     
  }
  if(!any(cl)) {
    warn("no mrgsimsds objects were found.")
  }
  x[cl]
}
