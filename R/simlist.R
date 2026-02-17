simlist_classes <- function(x) {
  classes <- vapply(
    x,
    inherits,
    "mrgsimsds",
    FUN.VALUE = TRUE,
    USE.NAMES = FALSE
  )
  classes
}

simlist_models <- function(x) {
  models <- vapply(
    x,
    FUN = function(xx) xx$mod@model,
    FUN.VALUE = "model",
    USE.NAMES = FALSE
  )
  models <- models==models[1]
  models
}

# Return a list of the column names
simlist_cols <- function(x) {
  cols <- lapply(x, function(xx) xx$names)
  cols <- vapply(
    cols,
    FUN = setequal,
    FUN.VALUE = TRUE,
    USE.NAMES = FALSE,
    y = cols[[1]]
  )
  cols
}

# Return the files from a simlist
simlist_files <- function(x) {
  files <- lapply(x, FUN = function(xx) xx$files)
  unlist(files, use.names=FALSE)
}
