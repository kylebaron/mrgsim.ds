file_owner <- new.env(parent = emptyenv())

clean_up_ds <- function(x) {
  if(x$gc && check_ownership(x)) {
    if(getOption("mrgsim.ds.show.gc", FALSE)) {
      n <- length(x$files)
      msg <- glue("[mrgsim.ds.show.gc] cleaning up {n} file(s) ...")
      message(msg)
    }
    on.exit(disown(x), add = TRUE)
    unlink(x$files, recursive = TRUE)
  }
}

#' Take or check ownership of simulation files
#' 
#' @param x an mrgsimsds object.
#' @param full.names if `TRUE`, include the directory path when listing file 
#' ownership. 
#' 
#' @export
take_ownership <- function(x) {
  require_ds(x)
  if(length(x$files) > 1) {
    foo <- sapply(x$files, assign, value = x$address, envir = file_owner)  
    return(invisible(x))
  } else {
    assign(x$files, x$address, envir = file_owner)
    return(invisible(x))
  }
}

#' @rdname take_ownership
#' @export
check_ownership <- function(x) {
  require_ds(x)
  if(length(x$files) == 1) {
    test <- file_owner[[x$files]]
    if(is.null(test))return(FALSE)
    return(test==x$address)
  } else {
    ans <- sapply(x$files, \(xi) {
      test <- file_owner[[xi]]
      if(is.null(test)) return(FALSE)
      test==x$address
    })
    return(all(ans))
  }
}

#' @rdname take_ownership
#' @export
list_ownership <- function(full.names = FALSE) {
  ans <- as.list(file_owner)
  if(!length(ans)) {
    ans <- data.frame(object = "a", file = "b")[0,]
    return(ans)
  }
  if(isFALSE(full.names)) {
    names(ans) <- basename(names(ans)) 
  }
  ans <- data.frame(object = unlist(ans), file = names(ans))
  rownames(ans) <- NULL
  ans
}

#' @rdname take_ownership
#' @export
ownership <- function() {
  files <- names(mrgsim.ds:::file_owner)
  files <- files[grepl("parquet", files)]
  objects <- mget(files, envir = mrgsim.ds:::file_owner)
  size <- total_size(files)
  message(glue::glue("Files:   ", length(unique(files))))
  message(glue::glue("Size:    ", size))
  message(glue::glue("Objects: ", length(unique(objects))))
}

#' @rdname take_ownership
#' @export
disown <- function(x) {
  require_ds(x)
  files <- x$files
  files <- files[files %in% names(file_owner)]
  for(file in files) {
    rm(list = file, envir = file_owner)  
  }
  invisible(x)
}

#' Copy an mrgsims object
#' 
#' @param x the object to copy.
#' 
#' @return
#' An mrgsims object with identical fields, but updated pid. 
#' 
#' @export
copy_ds <- function(x, own = FALSE) {
  require_ds(x)
  names_in <- names(x)
  ans <- new.env(parent = emptyenv())
  ans$ds <- open_dataset(x$files)
  ans$files <- ans$ds$files
  ans$mod <- x$mod
  ans$dim <- x$dim
  ans$head <- x$head
  ans$names <- x$names
  ans$pid <- Sys.getpid()
  ans$gc <- x$gc
  ans$address <- obj_addr(ans)
  class(ans) <- c("mrgsimsds", "environment")
  names_out <- names(ans)
  stopifnot("bad copy" = identical(names_in, names_out))
  if(own) take_ownership(ans)
  ans
}
