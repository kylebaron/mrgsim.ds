#' Read a model specification file for Arrow-backed simulation
#' 
#' This is a very-light wrapper around [mrgsolve::mread()].
#' 
#' @param ... passed to [mrgsolve::mread()].
#' 
#' @details
#' After calling `mcode()`, the model object is passed through either
#' [set_output_ds()] or [set_temp_ds()].
#' 
#' @seealso [mcode_ds()], [modlib_ds()].
#' 
#' @export
mread_ds <- function(..., output_dir = NULL) {
  x <- mread(...)
  if(is.character(output_dir)) {
    x <- set_output_ds(x, output_dir)  
  } else {
    x <- set_temp_ds(x)  
  }
  x
}

#' Write, compile, and load model code for Arrow-backed simulation
#' 
#' This is a very-light wrapper around [mrgsolve::mcode()]. 
#' 
#' @param ... passed to [mrgsolve::mcode()].
#' 
#' @details
#' After calling `mcode()`, the model object is passed through either
#' [set_output_ds()] or [set_temp_ds()].
#' 
#' @seealso [mread_ds()], [modlib_ds()].
#' 
#' @export
mcode_ds <- function(..., output_dir = NULL) {
  x <- mcode(...)
  if(is.character(output_dir)) {
    x <- set_output_ds(x, output_dir)  
  } else {
    x <- set_temp_ds(x)  
  }
  x  
}

#' Internal model library for Arrow-backed simulation
#' 
#' This is a very-light wrapper around [mrgsolve::modlib()].
#' 
#' @param ... passed to [mrgsolve::modlib()].
#' 
#' @details
#' After calling `modlib()`, the model object is passed through either
#' [set_output_ds()] or [set_temp_ds()].
#' 
#' @seealso [mread_ds()], [mcode_ds()].
#' 
#' @export
modlib_ds <- function(..., output_dir = NULL) {
  x <- modlib(...)
  if(is.character(output_dir)) {
    x <- set_output_ds(x, output_dir)  
  } else {
    x <- set_temp_ds(x)  
  }
  x
}
