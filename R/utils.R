total_size <- function(files) {
  size <- vapply(files, FUN = file.size, FUN.VALUE = 1.0)
  if(any(is.na(size))) {
    abort(
      "file(s) backing this object do not exist.", 
      call = caller_env()
    )  
  }
  size <- sum(size)
  class(size) <- "object_size"
  size <- format(size, units = "auto")
  size
}

files_exist <- function(x, fatal = TRUE) {
  ans <- all(file.exists(x$files))
  if(!isTRUE(fatal)) return(ans)
  if(!ans) {
    abort(
      "file(s) backing this object do not exist.", 
      call = caller_env()
    )    
  }
  return(invisible(ans))
}

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
is_mrgsimsds <- function(x) {
  inherits(x, "mrgsimsds")  
}

# Formatter from the scales package
format_big <- scales::label_number(
  accuracy = 0.1, 
  scale_cut = scales::cut_short_scale()
)

#' Set or get default temporary output directory
#' 
#' @param x a model object. 
#' 
#' @examples
#' mod <- mrgsolve::house()
#' 
#' mod <- set_temp_ds(mod)
#' 
#' get_temp_ds(mod)
#' 
#' @export
set_temp_ds <- function(x) {
  set_output_ds(x, tempdir()) 
}
#' @name get_temp_ds
#' @rdname set_temp_ds
#' @export
get_temp_ds <- function(x) {
  get_output_ds(x)
}

#' Set or get default output directory
#' 
#' @param x a model object. 
#' @param output_dir path to output directory. 
#' 
#' @examples
#' mod <- mrgsolve::house()
#' 
#' path <- file.path(tempfile(), "foo")
#' 
#' mod <- set_output_ds(mod, path)
#' 
#' get_output_ds(mod)
#' 
#' @export
set_output_ds <- function(x, output_dir) {
  assign("mrgsim.ds_output_dir", output_dir, x@envir)
  invisible(x)
}

#' @name get_output_ds
#' @rdname get_output_ds
#' @export
get_output_ds <- function(x) {
  ans <- x@envir$mrgsim.ds_output_dir 
  if(is.null(ans)) {
    return(tempdir())  
  }
  ans
}

file_name_ds <- function(base = NULL, ext = ".parquet") {
  if(is.character(base)) {
    file <- paste0("mrgsims-ds-", base, ext)
  } else {
    file <- basename(tempfile(pattern = "mrgsims-ds-", fileext = ext))    
  }
  return(file)
}

#' @export
temp_file <- function(x = NULL) {
  if(is.mrgmod(x)) {
    path <- get_output_ds(x)  
  } else {
    path <- tempdir()
  }
  file.path(path, file_name_ds())
}
