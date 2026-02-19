file_owner <- new.env(parent = emptyenv(), hash = TRUE, size = 5000L)

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

hash_files <- function(x) {
  dig <- getVDigest(algo = "xxh3_64")
  x$hash <- dig(x$files)
  x
}

#' Ownership of simulation files
#' 
#' Functions to check ownership or disown simulation output files on disk.
#' 
#' @param x an mrgsimsds object.
#' @param full.names if `TRUE`, include the directory path when listing file 
#' ownership. 
#' 
#' @details
#' One situation were you need to take over ownership is when you are simulating
#' in parallel, and the simulation happens in another R process. `mrgsim.ds`
#' ownership is established when the simulation returns and the `mrgsimsds` 
#' object is created. When this happens in another R process (e.g., on a 
#' worker node, there is no way to transfer that information back to the 
#' parent process. In that case, a call to `take_ownership()` once the results
#' are returned to the parent process would be appropriate. Typically, these 
#' results are returned as a list and a call to [reduce_ds()] will create 
#' a single object pointing to and owning multiple files. Therefore, it should 
#' be rare to call `take_ownership()` directly; if doing so, please make sure 
#' you understand what is going on.
#' 
#' @return 
#' - `check_ownership`: `TRUE` if `x` owns the underlying files; `FALSE` 
#'   otherwise.
#' - `list_ownership`: a data.frame of ownership information.
#' - `ownership`: nothing; used for side effects.
#' - `disown`: `x` is returned invisibly; it is not modified.
#' - `take_ownership`: `x` is returned invisibly after getting modified in 
#'   place. 
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
#' e1 <- ev(amt = 100)
#' e2 <- ev(amt = 200)
#' 
#' out <- list(mrgsim_ds(mod, e1), mrgsim_ds(mod, e2))
#' 
#' sims <- reduce_ds(out)
#' 
#' ownership()
#' 
#' check_ownership(sims)
#' 
#' check_ownership(out[[1]])
#' 
#' check_ownership(out[[2]])
#' 
#' 
#' @seealso [reduce_ds()], [copy_ds()].
#' 
#' @rdname ownership
#' @name ownership
#' @export
ownership <- function() {
  objects <- mget(names(file_owner), envir = file_owner)
  if(!length(objects)) {
    message("No ownership information yet.")
    return(invisible(NULL))
  }
  files <- vapply(objects, \(obj) obj$files, "a", USE.NAMES = FALSE)
  addresses <- vapply(objects, \(obj) obj$address, "a", USE.NAMES = FALSE)
  size <- total_size(files)
  nfile <- length(unique(files))
  nadd <- length(unique(addresses))
  msg <- "Objects: {nadd} | Files: {nfile} | Size: {size}"
  message(glue(msg))
  return(invisible(NULL))
}

#' @rdname ownership
#' @export
list_ownership <- function(full.names = FALSE) {
  objects <- mget(names(file_owner), envir = file_owner)
  if(!length(objects)) {
    ans <- data.frame(object = "a", file = "b", hash = "c")[0,]
    return(ans)
  }
  files <- vapply(objects, \(obj) obj$files, "a", USE.NAMES = FALSE)
  addresses <- vapply(objects, \(obj) obj$address, "a", USE.NAMES = FALSE)
  ans <- data.frame(
    file = files, 
    address = addresses, 
    stringsAsFactors = FALSE
  )
  if(isFALSE(full.names)) {
    ans$file <- basename(ans$file)
  }
  rownames(ans) <- NULL
  ans
}

#' @rdname ownership
#' @export
check_ownership <- function(x) {
  require_ds(x)
  keys <- x$hash[x$hash %in% names(file_owner)]
  if(length(keys) != length(x$hash)) {
    return(FALSE)  
  }
  info <- mget(keys, envir = file_owner)
  addr <- vapply(info, FUN = \(i) i$address, FUN.VALUE = "a")
  return(all(addr==x$address))
}

#' @rdname ownership
#' @export
disown <- function(x) {
  require_ds(x)
  if(is.null(x$hash)) abort("files are not hashed.")
  to_rm <- x$hash[x$hash %in% names(file_owner)]
  rm(list = to_rm, envir = file_owner)
  invisible(x)
}

#' @rdname ownership
#' @export
take_ownership <- function(x) {
  require_ds(x)
  hash_files(x)
  l <- lapply(x$files, \(f) list(address = x$address, files = f))
  names(l) <- x$hash
  list2env(l, envir = file_owner)
  return(invisible(x))
}

#' Copy an mrgsimsds object
#' 
#' By default, the new object will own the data files. 
#' 
#' @param x an mrgsimsds object to copy.
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
  if(own) {
    take_ownership(ans)
  } else {
    hash_files(ans)  
  }
  ans
}
