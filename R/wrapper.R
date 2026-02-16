#' Read a model specification file for 'Apache' 'Arrow'-backed simulation
#' outputs
#' 
#' These are very-light wrappers around mrgsolve functions used to load 
#' models for simulation.
#' 
#' @param ... passed to the corresponding mrgsolve function.
#' 
#' @seealso [save_process_info()].
#' 
#' @examples
#' mod <- house_ds()
#' 
#' mod
#' 
#' @export
mread_ds <- function(...) {
  x <- mread(...)
  save_process_info(x)
}

#' @rdname mread_ds
#' @export
mcode_ds <- function(...) {
  x <- mcode(...)
  saved_process_info(x)
}

#' @rdname mread_ds
#' @export
modlib_ds <- function(...) {
  x <- modlib(...)
  save_process_info(x)
}

#' @rdname mread_ds
#' @export
house_ds <- function(...) {
  x <- house(...)
  save_process_info(x)
}

#' @rdname mread_ds
#' @export
mread_cache_ds <- function(...) {
  x <- mread_cache(...)
  save_process_info(x)
}
