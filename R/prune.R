#' Prune a list of mrgsimsds objects
#' 
#' @param x a list of R objects or a single mrgsimsds object.
#' @param inform issue a message when objects in some list slots are dropped. 
#' @param ... not used. 
#' 
#' @examples
#' mod <- house_ds(end = 24)
#' 
#' out <- mrgsim_ds(mod, events = ev(amt = 100))
#' 
#' sims <- list(out, letters)
#' 
#' prune_ds(sims)
#' 
#' @return
#' When `x` is a list, it will be returned with only the mrgsimsds objects 
#' retained.
#' 
#' When `x` is an mrgsimsds object, it will be invisibly returned. 
#' 
#' @export
prune_ds <- function(x, ...) UseMethod("prune_ds")
#' @rdname prune_ds
#' @export
prune_ds.mrgsimsds <- function(x, ...) {
  check_files_fatal(x)
  x <- safe_ds(x)
  invisible(x)
}
#' @rdname prune_ds
#' @export
prune_ds.list <- function(x, ..., inform = TRUE) {
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
