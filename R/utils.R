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
set_temp_ds <- function(x) {
  set_output_ds(x, tempdir()) 
}

#' @export
set_output_ds <- function(x, output_dir) {
  assign("mrgsim.ds_output_dir", output_dir, x@envir)
  invisible(x)
}

#' @export
get_temp_ds <- function(x) {
  get_output_ds(x)
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
random_file <- function(ext = ".parquet") {
  basename(tempfile(pattern = "mrgsims-ds-", fileext = ext))  
}

#' @export
temp_file <- function(x = NULL) {
  if(is.mrgmod(x)) {
    path <- get_output_ds(x)  
  } else {
    path <- tempdir()
  }
  file.path(path, random_file())
}
