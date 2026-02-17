#' Check if object inherits mrgsimsds
#'
#' @param x object to check. 
#' 
#' 
#' @export
is_mrgsimsds <- function(x) {
  inherits(x, "mrgsimsds")  
}

require_ds <- function(x) {
  if(!inherits(x, "mrgsimsds")) {
    actual <- class(x)
    if(length(actual) > 1) {
      actual <- paste0(actual, collapse = "/")  
    }
    msg <- "an {'mrgsimsds' object is required, not '{actual}'."
    abort(glue(msg))
  }
}

# Formatter from the scales package
format_big <- function() {
  scales::label_number(
    accuracy = 0.1, 
    scale_cut = scales::cut_short_scale()
  )
}
#' Save information about the R process that loded a model
#' 
#' @param x a model object. 
#' 
#' @return 
#' An updated model object suitable for using with [mrgsim_ds()].
#' 
#' @examples
#' mod <- mrgsolve::house()
#' 
#' mod <- save_process_info(mod)
#' 
#' @export
save_process_info <- function(x) {
  x@envir$mrgsim.ds.mread_valid <- TRUE
  x@envir$mrgsim.ds.mread_pid <- Sys.getpid()
  x@envir$mrgsim.ds.mread_tempdir <- tempdir()
  x
}

valid_ds <- function(x) {
  !identical(x$ds$pointer(), new("externalptr"))  
}

safe_ds <- function(x) {
  if(!valid_ds(x)) x <- refresh_ds(x)
  x
}

pid_changed <- function(x) {
  Sys.getpid() != get_mread_pid(x)  
}

get_mread_pid <- function(x) {
  pid <- x@envir$mrgsim.ds.mread_pid
  if(!is.numeric(pid)) {
    pid <- -1e9
  }
  pid
}

get_mread_tempdir <- function(x) {
  tempd <- x@envir$mrgsim.ds.mread_tempdir
  tempd
}

mread_with_ds <- function(x) {
  is.character(x@envir$mrgsim.ds.mread_tempdir)  
}

get_head <- function(x, n = 6) {
  x <- safe_ds(x)
  scanner <- Scanner$create(x$ds, batch_size = 10000)
  reader <- scanner$ToRecordBatchReader()  
  head(as.data.frame(reader$read_next_batch()), n = n)
}
