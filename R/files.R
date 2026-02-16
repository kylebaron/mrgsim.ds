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

#' Create an output file name
#' 
#' @param id a tag used to form the file name; if not provided, a random name 
#' will be generated.
#' 
#' @return 
#' A character file name.
#' 
#' @examples
#' file_ds()
#' file_ds("example")
#' 
#' @export
file_ds <- function(id = NULL) {
  ext <- ".parquet"
  if(is.atomic(id) && !is.null(id)) {
    id <- as.character(id)
    file <- paste0(.global$file.prefix, id, ext)
  } else {
    file <- basename(tempfile(pattern = .global$file.prefix, fileext = ext))    
  }
  return(file)
}

#' Manage simulated outputs in tempdir()
#' 
#' @param ... objects whose files will not be purged.
#' 
#' @examples
#' mod <- house_ds()
#' 
#' out <- lapply(1:10, \(x) mrgsim_ds(mod))
#' 
#' list_temp()
#' 
#' sims <- reduce_ds(out)
#' 
#' list_temp()
#' 
#' retain_temp(sims)
#' 
#' list_temp() 
#' 
#' purge_temp() 
#' 
#' list_temp()
#' 
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

#' @rdname list_temp
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

#' @rdname list_temp
#' @export
purge_temp <- function() {
  temp <- list.files(tempdir(), pattern = .global$file.re, full.names = TRUE)
  message("Discarding ", length(temp), " files.")
  unlink(x = temp, recursive = TRUE)
  return(invisible(NULL))
}


#' Move data set files to a new directory. 
#' 
#' Use `move_ds()` to just change the enclosing directory. `write_ds()` can also
#' move the files, but also condenses all simulation output in to a single 
#' parquet file if multiple files are backing the mrgsimsds object.
#' 
#' @param an mrgsimsds object. 
#' @param path the new directory location for backing files.
#' @param sink the complete path (including file name) for a single parquet
#' file containing all simulated data.
#' @param ... passed to [arrow::write_parquet()].
#' 
#' @return
#' Both functions return the mrgsimsds object; it is critical to capture the 
#' return value in order to continue working with the object in the current
#' R session.
#' 
#' @examples
#' 
#' mod <- house_ds()
#' 
#' out <- mrgsim_ds(mod, events = ev(amt = 100))
#' 
#' out <- write_ds(out, sink = file.path(tempdir(), "example.parquet"))
#' 
#' out$files
#' 
#' \dontrun{
#'   out <- move_ds(out, path = "data/simulated") 
#' }
#' 
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

#' @rdname move_ds
#' @export
write_ds <- function(x, sink, ...) {
  write_parquet(x$ds, sink, ...)
  file_delete(x$ds$files)
  x$files <- sink
  x <- refresh_ds(x)
  x
}
