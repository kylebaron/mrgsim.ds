#' @export
#' @md
print.mrgsimsds <- function(x, n = 8, ...) {
  dm <- x$dim
  size <- sum(sapply(x$files, file.size))
  class(size) <- "object_size"
  size <- format(size, units = "auto")
  message("Model: ", x$mod@model)
  message("Dim  : ", dm[1L], " ", dm[2L])
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
