valid_ds <- function(x) {
  !identical(x$ds$pointer(), new("externalptr"))  
}

safe_ds <- function(x) {
  if(!valid_ds(x)) x <- refresh_ds(x)
  x
}

#' Check if object inherits mrgsimsds
#'
#' @param x object to check. 
#' 
#' @export
#' @md
is_mrgsimsds <- function(x) {
  inherits(x, "mrgsimsds")  
}

# Formatter from the scales package
format_big <- label_number(
  accuracy = 0.1, 
  scale_cut = cut_short_scale()
)
