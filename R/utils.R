

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

save_process_info <- function(x) {
  x@envir$mrgsim.ds_mread_valid <- TRUE
  x@envir$mrgsim.ds.mread_pid <- Sys.getpid()
  x@envir$mrgsim.ds.mread_tempdir <- tempdir()
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
