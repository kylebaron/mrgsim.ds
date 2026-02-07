#' @export
group_by.mrgsimsds <- function(.data, ..., .add = FALSE, .drop = TRUE) {
  dplyr::group_by(as_arrow_ds(.data), ..., .add = .add, .drop = .drop)
}

#' @export
select.mrgsimsds <- function(.data, ...) {
  dplyr::select(as_arrow_ds(.data), ...)
}

#' @export
mutate.mrgsimsds <- function(.data, ...) {
  dplyr::mutate(as_arrow_ds(.data), ...)
}

#' @export
filter.mrgsimsds <- function(.data, ..., .by = NULL, .preserve = FALSE) {
  dplyr::filter(as_arrow_ds(.data), ..., .by = .by, .preserve = .preserve)
}
