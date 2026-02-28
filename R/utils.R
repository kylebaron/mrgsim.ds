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
    msg <- "an 'mrgsimsds' object is required, not '{actual}'."
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
#' Save information about the R process that loaded a model
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
  if(!is.mrgmod(x)) { # nocov start
    abort("`x` must be an mrgmod object.")  
  } # nocov end
  x@envir$mrgsim.ds.mread_valid <- TRUE
  x@envir$mrgsim.ds.mread_pid <- Sys.getpid()
  x@envir$mrgsim.ds.mread_tempdir <- tempdir()
  x
}

invalid_ds <- function(x) {
  identical(x$ds$pointer(), .global$nullptr)  
}

safe_ds <- function(x) {
  if(invalid_ds(x)) x <- refresh_ds(x)
  invisible(x)
}

pid_changed <- function(x) {
  if(is.mrgmod(x)) {
    return(Sys.getpid() != get_mread_pid(x))
  }
  if(is_mrgsimsds(x)) {
    return(Sys.getpid() != x$pid)  
  }
  abort("cannot assess pid on this object.")
}

get_mread_pid <- function(x) {
  stopifnot("this function was expecting a model object." = is.mrgmod(x))
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

get_nrow_from_ds <- function(x, n = 6, batch_size = 10000) {
  x <- safe_ds(x)
  scanner <- Scanner$create(x$ds, batch_size = batch_size)
  reader <- scanner$ToRecordBatchReader()  
  head(as.data.frame(reader$read_next_batch()), n = n)
}

get_nid_from_ds <- function(x, nid = 10, batch_size = 10000) {
  x <- safe_ds(x)
  ds <- x$ds
  scanner <- Scanner$create(ds, batch_size = batch_size)
  reader <- scanner$ToRecordBatchReader()
  count_id <- 1
  iter <- 0
  simsl <- vector(mode = "list", length = nid)
  while(count_id < (nid+2)) {
    batch <- as.data.frame(reader$read_next_batch())
    if(nrow(batch)==0) {
      count_id <- nid + 2
      break;  
    }
    iter <- iter + 1
    ids <- unique(batch$ID)
    count_id <- count_id + length(ids)
    simsl[[iter]] <- batch
  }
  simsl <- simsl[seq(iter)]
  sims <- bind_rows(simsl)
  uid <- unique(sims$ID)
  uid <- uid[seq(nid)]
  sims <- sims[sims$ID %in% uid,]  
  sims
}

set_finalizer_ds <- function(x) {
  reg.finalizer(x, clean_up_ds, onexit = TRUE)
  x
}
