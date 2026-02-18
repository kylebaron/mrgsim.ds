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
  message("Model: ", x$mod@model)
  message("Dim  : ", dm1, " ", dm[2L])
  message("Files: ", nfile, " [", size, "]")
  message("Owner: ", own)
  chunk <- head(x$head, n = n)
  rownames(chunk) <- paste0(seq(nrow(chunk)), ": ")
  print(chunk)
  invalid <- identical(x$ds$pointer(), new("externalptr"))
  if(invalid) {
    message("! pointer is invalid; run refresh_ds().")  
  }
  return(invisible(NULL))
} # nocov end
