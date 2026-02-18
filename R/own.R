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

#' Ownership of simulation files
#' 
#' Functions to take ownership or disown simulation output files on disk.
#' 
#' @param x an mrgsimsds object.
#' @param full.names if `TRUE`, include the directory path when listing file 
#' ownership. 
#' 
#' @details
#' Only call `take_ownership()` when you really know what you're doing. If an 
#' object doesn't own its own simulation files, there's probably a reason why 
#' that is. Most often, whoever has ownership of the files is the one who 
#' actually generated the simulation outputs.
#' 
#' @return 
#' - `take_ownership`: `x` is returned invisibly after getting modified in 
#'   place. 
#' - `check_ownership`: `TRUE` if `x` owns the underlying files; `FALSE` 
#'   otherwise.
#' - `list_ownership`: a data.frame of ownership information.
#' - `ownership`: nothing; used for side effects.
#' - `disown`: `x` is returned invisibly; it is not modified.
#' 
#' @examples
#' mod <- house_ds()
#' 
#' out <- mrgsim_ds(mod, id = 1)
#' 
#' check_ownership(out)
#' 
#' ownership()
#' 
#' list_ownership()
#' 
#' @rdname ownership
#' @name ownership
#' @export
take_ownership <- function(x) {
  require_ds(x)
  hash_files(x)
  assign(x$hash, value = list(address = x$address, files = x$files), envir = file_owner)
  return(invisible(x))
}

#' @rdname ownership
#' @export
check_ownership <- function(x) {
  require_ds(x)
  test <- file_owner[[x$hash]]
  if(is.null(test)) return(FALSE)
  return(x$address == test$address)
}

#' @rdname ownership
#' @export
list_ownership <- function(full.names = FALSE) {
  entries <- names(file_owner)
  if(!length(entries)) {
    ans <- data.frame(object = "a", file = "b", hash = "c")[0,]
    return(ans)
  }
  objects <- mget(entries, envir = file_owner)
  listing <- lapply(objects, \(x) {
    data.frame(file = x$files, address = x$address)
  })
  ans <- bind_rows(listing)
  if(isFALSE(full.names)) {
    ans$file <- basename(ans$file)
  }
  rownames(ans) <- NULL
  ans
}

#' @rdname ownership
#' @export
ownership <- function() {
  entries <- names(file_owner)
  objects <- mget(entries, envir = file_owner)
  files <- unlist(sapply(objects, \(x) x$files, USE.NAMES=FALSE))
  addresses <- sapply(objects, \(x) x$address)
  size <- total_size(files)
  nfile <- length(unique(files))
  nadd <- length(unique(addresses))
  msg <- "Objects: {nadd} | Files: {nfile} | Size: {size}"
  message(glue(msg))
  return(invisible(NULL))
}

#' @rdname ownership
#' @export
disown <- function(x) {
  require_ds(x)
  if(is.null(x$hash)) abort("files are not hashed.")
  if(x$hash %in% names(file_owner)) {
    rm(list = x$hash, envir = file_owner)  
  }
  invisible(x)
}

#' Copy an mrgsims object
#' 
#' By default, the new object will own the data files. 
#' 
#' @param x the object to copy.
#' @param own logical; if `TRUE` the new object will own the files; otherwise
#' there will be no change in ownership.
#' 
#' @return
#' An mrgsimsds object with identical fields, but updated pid. 
#' 
#' @examples
#' mod <- house_ds()
#' 
#' out <- mrgsim_ds(mod)
#' 
#' out2 <- copy_ds(out)
#' 
#' check_ownership(out)
#' 
#' check_ownership(out2)
#' 
#' @export
copy_ds <- function(x, own = TRUE) {
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
