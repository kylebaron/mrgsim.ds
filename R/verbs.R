#' @export
group_by.mrgsimsds <- function(.data, ..., .add = FALSE, .drop = TRUE) {
  .data <- safe_ds(.data)
  check_files_fatal(.data)
  dplyr::group_by(as_arrow_ds(.data), ..., .add = .add, .drop = .drop)
}

#' @export
select.mrgsimsds <- function(.data, ...) {
  .data <- safe_ds(.data)
  check_files_fatal(.data)
  dplyr::select(as_arrow_ds(.data), ...)
}

#' @export
mutate.mrgsimsds <- function(.data, ...) {
  .data <- safe_ds(.data)
  check_files_fatal(.data)
  dplyr::mutate(as_arrow_ds(.data), ...)
}

#' @export
filter.mrgsimsds <- function(.data, ..., .by = NULL, .preserve = FALSE) {
  .data <- safe_ds(.data)
  check_files_fatal(.data)
  dplyr::filter(as_arrow_ds(.data), ..., .by = .by, .preserve = .preserve)
}
