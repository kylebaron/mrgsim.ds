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


#' @export
set_output_ds <- function(x, output_dir = tempdir()) {
  assign("mrgsim.ds_output_dir", output_dir, x@envir)
  x
}
#' @export
get_output_ds <- function(x) {
  ans <- x@envir$mrgsim.ds_output_dir 
  if(is.null(ans)) {
    return(tempdir())  
  }
  ans
}
#' @export
temp_file <- function(ext = ".parquet") {
  basename(tempfile(pattern = "mrgsims-ds-", fileext = ext))  
}
