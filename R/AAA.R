#' @importFrom rlang abort warn inform caller_env is_named is_formula
#' @importFrom arrow open_dataset  write_parquet Scanner
#' @importFrom arrow to_duckdb as_arrow_table
#' @importFrom dplyr collect distinct pull summarise summarize
#' @importFrom dplyr mutate select group_by filter bind_rows
#' @importFrom tibble as_tibble
#' @importFrom utils head tail
#' @importFrom scales label_number cut_short_scale
#' @importFrom glue glue glue_data
#' @importFrom mrgsolve mrgsim ev ev_expand house ev
#' @importFrom mrgsolve mread mcode mread_cache modlib house
#' @importFrom mrgsolve plot_sims is.mrgmod
#' @importFrom methods new
#' @importFrom fs file_move dir_exists dir_create file_delete
#' @importFrom stats as.formula
#' @importFrom lobstr obj_addr
#' @importFrom digest getVDigest
NULL

#' @keywords internal
"_PACKAGE"

.global <- new.env(parent = emptyenv())
assign("file.prefix", "mrgsims-ds-", .global)
assign("file.re", "^mrgsims-ds-.*\\.parquet$", .global)
assign("nullptr", new("externalptr"), .global)
