#' #' @export
#' mutate.mrgsimsds <- function(x, ... ) {
#'   for(f in x$files) {
#'     mutate_impl(f)
#'   }
#'   x$head <- mutate(x$head, ...)
#'   x <- refresh_ds(x)
#'   x
#' }
#' 
#' mutate_impl <- function(file, ... ) {
#'   ds <- open_dataset(file)
#'   ds <- mutate(ds, ...)
#'   write_parquet(x = ds, sink = file)
#'   return(invisible(NULL))
#' }
