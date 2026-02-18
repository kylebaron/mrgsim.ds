total_size <- function(files) {
  size <- vapply(files, FUN = file.size, FUN.VALUE = 1.0)
  size <- sum(size, na.rm = TRUE)
  class(size) <- "object_size"
  size <- format(size, units = "auto")
  size
}

files_exist <- function(x, fatal = TRUE) {
  if(isTRUE(fatal)) {
    check_files_fatal(x)  
  }
  ans <- all(file.exists(x$files))
  return(invisible(ans))
}

check_files_fatal <- function(x) {
  ans <- all(file.exists(x$files))
  if(!ans) {
    nfile <- length(x$files)
    owner <- ifelse(check_ownership(x), "yes", "no")
    model <- x$mod@model
    body <- c(
      "Model: {model}",
      "Files: {nfile}", 
      "Owner: {owner}" 
    )
    for(i in seq_along(body)) {
      body[i] <- glue(body[i])  
    }
    names(body) <- rep("*", length(body))
    abort(
      body = body,
      message = "[fatal] data set files do not exist.", 
      call = caller_env()
    )
  }
  return(invisible(TRUE))
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

#' Move data set files to a new directory. 
#' 
#' Use `move_ds()` to just change the enclosing directory. `write_ds()` can also
#' move the files, but also condenses all simulation output in to a single 
#' parquet file if multiple files are backing the mrgsimsds object. See
#' *Details*. 
#' 
#' @param x an mrgsimsds object. 
#' @param path the new directory location for backing files.
#' @param id a short name used to create data set files for the simulated 
#' output.
#' @param sink the complete path (including file name) for a single parquet
#' file containing all simulated data.
#' @param ... passed to [arrow::write_parquet()].
#' 
#' @details
#' When dataset files are rewritten to a single file with `write_ds()`, those 
#' files will no longer be cleaned up when the containing R object is finalized 
#' upon garbage collection. When dataset files are moved outside of `tempdir()`, 
#' those files, too, will no longer be cleaned up on garbage collection; but
#' file cleanup will continue to occur as long as the files remain under 
#' `tempdir()`. No change in finalization behavior due to garbage collection 
#' of the containing object will happen when files are renamed. 
#' 
#' @return
#' All three functions return the mrgsimsds object invisibly.
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
  require_ds(x)
  if(!check_ownership(x)) {
    abort("cannot move files you don't own.")  
  }
  disown(x)
  files <- x$files
  if(!dir_exists(path)) {
    dir_create(path)  
  }
  x$files <- file_move(files, path)
  x <- refresh_ds(x)
  take_ownership(x)
  invisible(x$files)
}

#' @rdname move_ds
#' @export
rename_ds <- function(x, id) {
  require_ds(x)
  if(!check_ownership(x)) {
    abort("cannot rename files you don't own.")  
  }
  disown(x)
  files <- x$files
  i <- seq_along(files)
  width <- floor(log10(length(i)))+1
  width <- max(width, 4)
  i <- formatC(i, width = width, flag = "0")
  id <- paste0(id, "-", i)
  new_names <- file_ds(id = id)
  x$files <- file_move(files, file.path(dirname(files), new_names))
  x <- refresh_ds(x)
  x$files <- x$ds$files
  x$gc <- FALSE
  take_ownership(x)
  invisible(x$files)
}

#' @rdname move_ds
#' @export
write_ds <- function(x, sink, ...) {
  require_ds(x)
  if(!check_ownership(x)) {
    abort("cannot re-write files you don't own.")  
  }
  disown(x)
  if(length(x$files)==1) {
    file_move(x$files, sink)
  } else {
    write_parquet(x$ds, sink, ...)
    unlink(x$ds$files, recursive = TRUE)
  }
  x$files <- sink
  x <- refresh_ds(x)
  x$gc <- FALSE
  take_ownership(x)
  invisible(x$files)
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
  size <- total_size(temp)
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
  cl <- simlist_classes(x)
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
