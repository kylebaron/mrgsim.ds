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
#' @name set_temp_ds
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
#' @rdname set_output_ds
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


#' @export
retain_temp <- function(...) {
  x <- list(...)
  x <- lapply(x, reduce_ds)
  cl <- mrgsim.ds:::simlist_classes(x)
  x <- x[cl]
  temp <- list.files(tempdir(), pattern = "^mrgsims-ds-.*\\.parquet$", full.names = TRUE)
  files <- sapply(x, function(xx) xx$files)
  files <- unlist(files)
  temp <- temp[!(basename(temp) %in% basename(files))]
  message("Discarding ", length(temp), " files.")
  unlink(x = temp, recursive = TRUE)
  return(invisible(NULL))
}

#' @export
reset_temp <- function() {
  temp <- list.files(tempdir(), pattern = "^mrgsims-ds-.*\\.parquet$", full.names = TRUE)
  message("Discarding ", length(temp), " files.")
  unlink(x = temp, recursive = TRUE)
  return(invisible(NULL))
}

#' @export
list_temp <- function() {
  temp <- list.files(tempdir(), pattern = "^mrgsims-ds-.*\\.parquet$", full.names = TRUE)
  size <- mrgsim.ds:::total_size(temp)
  if(length(temp) < 6) {
    show <- paste0("- ", basename(temp))
  } else {
    show <- c(
      paste0("- ", basename(head(temp, n = 2))), 
      "   ...", 
      paste0("- ", basename(tail(temp, n = 2)))
    )
  }
  header <- paste0(length(temp), " files [", size, "]")
  cat(c(header, show), sep = "\n")
  return(invisible(temp))
}
