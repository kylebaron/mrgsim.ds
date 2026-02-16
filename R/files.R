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

file_name_ds <- function(base = NULL) {
  ext <- ".parquet"
  if(is.character(base)) {
    file <- paste0(.global$file.prefix, base, ext)
  } else {
    file <- basename(tempfile(pattern = .global$file.prefix, fileext = ext))    
  }
  return(file)
}

#' @export
temp_file <- function(x = NULL, base = NULL) {
  if(is.mrgmod(x)) {
    path <- get_output_ds(x)  
  } else {
    path <- tempdir()
  }
  file.path(path, file_name_ds(base))
}


#' @export
retain_temp <- function(...) {
  x <- list(...)
  x <- lapply(x, reduce_ds)
  cl <- mrgsim.ds:::simlist_classes(x)
  x <- x[cl]
  temp <- list.files(tempdir(), pattern = .global$file.re, full.names = TRUE)
  files <- sapply(x, function(xx) xx$files)
  files <- unlist(files)
  temp <- temp[!(basename(temp) %in% basename(files))]
  message("Discarding ", length(temp), " files.")
  unlink(x = temp, recursive = TRUE)
  return(invisible(NULL))
}

#' @export
reset_temp <- function() {
  temp <- list.files(tempdir(), pattern = .global$file.re, full.names = TRUE)
  message("Discarding ", length(temp), " files.")
  unlink(x = temp, recursive = TRUE)
  return(invisible(NULL))
}

#' @export
list_temp <- function() {
  temp <- list.files(tempdir(), pattern = .global$file.re, full.names = TRUE)
  if(!length(temp)) {
    message("No files in tempdir.")
    return(invisible(temp))
  }
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
  sapply(c(header, show), message)
  return(invisible(temp))
}

#' @export
move_ds <- function(x, path) {
  files <- x$files
  if(!dir_exists(path)) {
    dir_create(path)  
  }
  x$files <- file_move(files, path)
  x <- refresh_ds(x)
  x$files <- x$ds$files
  x
}

#' @export
write_ds <- function(x, sink, ...) {
  arrow::write_parquet(x$ds, sink, ...)
  fs::file_delete(x$ds$files)
  x$files <- sink
  x <- refresh_ds(x)
  x
}
