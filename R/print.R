#' @export
#' @md
print.mrgsimsds <- function(x, n = 8, ...) {
  dm <- x$dim
  size <- sum(sapply(x$files, file.size))
  if(any(is.na(size))) {
    abort("file(s) backing this mrgsims object do not exist.")  
  }
  class(size) <- "object_size"
  size <- format(size, units = "auto")
  dm1 <- dm[1L]
  if(dm1 < 99999) {
    dm1 <- format(dm1, scientific = FALSE,  big.mark = ',')
  }
  if(dm1 > 99999) {
    dm1 <- format_big(dm1)  
  }
  message("Model: ", x$mod@model)
  message("Dim  : ", dm1, " ", dm[2L])
  message("Files: ", length(x$files), " [", size, "]")
  chunk <- head(x$head, n = n)
  rownames(chunk) <- paste0(seq(nrow(chunk)), ": ")
  print(chunk)
  invalid <- identical(x$ds$pointer(), new("externalptr"))
  if(invalid) {
    message("! pointer is invalid; run refresh_ds().")  
  }
  return(invisible(NULL))
}
