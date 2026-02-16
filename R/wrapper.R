#' Read a model specification file for 'Apache' 'Arrow'-backed simulation
#' outputs
#' 
#' This is a very-light wrapper around [mrgsolve::mread()].
#' 
#' @param ... passed to [mrgsolve::mread()].
#' 
#' @seealso [mcode_ds()], [modlib_ds()], [house_ds()].
#' 
#' @export
mread_ds <- function(...) {
  x <- mread(...)
  save_process_info(x)
}

#' Write, compile, and load model code for 'Apache' 'Arrow'-backed simulation
#' outputs
#' 
#' This is a very-light wrapper around [mrgsolve::mcode()]. 
#' 
#' @param ... passed to [mrgsolve::mcode()].
#' 
#' @seealso [mread_ds()], [modlib_ds()], [house_ds()].
#' 
#' @export
mcode_ds <- function(...) {
  x <- mcode(...)
  saved_process_info(x)
}

#' Internal model library for 'Apache' 'Arrow'-backed simulation outputs
#' 
#' This is a very-light wrapper around [mrgsolve::modlib()].
#' 
#' @param ... passed to [mrgsolve::modlib()].
#' 
#' @seealso [mread_ds()], [mcode_ds()], [house_ds()].
#' 
#' @export
modlib_ds <- function(...) {
  x <- modlib(...)
  save_process_info(x)
}

#' Return a pre-compiled, PK/PD model for 'Apache' 'Arrow'-backed simulation
#' outputs
#' 
#' This is a very-light wrapper around [mrgsolve::house()].
#' 
#' @param ... passed to [mrgsolve::house()].
#' 
#' @seealso [mcode_ds()], [mread_ds()], [mcode_ds()].
#' 
#' @export
house_ds <- function(...) {
  x <- house(...)
  save_process_info(x)
}
