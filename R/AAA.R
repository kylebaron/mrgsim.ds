#' @importFrom rlang abort warn inform caller_env is_named is_formula
#' @importFrom arrow open_dataset as_arrow_table write_parquet Scanner
#' @importFrom dplyr collect as_tibble distinct pull
#' @importFrom dplyr mutate select group_by filter bind_rows
#' @importFrom utils head tail
#' @importFrom scales label_number cut_short_scale
#' @importFrom glue glue
#' @importFrom mrgsolve mrgsim ev ev_expand house ev
#' @importFrom mrgsolve mread mcode modlib house
#' @importFrom methods new
#' @importFrom fs file_move dir_exists dir_create
#' @importFrom stats as.formula
NULL

#' @keywords internal
"_PACKAGE"

.global <- new.env(parent = emptyenv())
assign("file.prefix", "mrgsims-ds-", .global)
assign("file.re", "^mrgsims-ds-.*\\.parquet$", .global)


