#' @export
#' @md
print.mrgsimsds <- function(x, n = 8, ...) { # nocov start
  check_files_fatal(x)
  dm <- x$dim
  size <- total_size(x$files)
  dm1 <- dm[1L]
  if(dm1 < 99999) {
    dm1 <- format(dm1, scientific = FALSE,  big.mark = ',')
  }
  if(dm1 > 99999) {
    dm1 <- format_big()(dm1)  
  }
  own <- ifelse(check_ownership(x), "yes", "no")
  nfile <- sum(file.exists(x$files))
  cat("Model: ", x$mod@model, "\n", sep = "")
  cat("Dim  : ", dm1, " x ", dm[2L], "\n", sep = "")
  cat("Files: ", nfile, " [", size, "]", "\n", sep = "")
  cat("Owner: ", own, "\n", sep = "")
  chunk <- head(x$head, n = n)
  rownames(chunk) <- paste0(seq(nrow(chunk)), ": ")
  print(chunk) 
  if(invalid_ds(x)) {
    refresh_ds(x)
    message("[mrgsim.ds] dataset pointer was refreshed.")
  }
  return(invisible(NULL))
} # nocov end
