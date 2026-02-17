
library(testthat)
library(mrgsim.ds)

mod <- house_ds(end = 3, delta = 1)

test_that("collect and as_tibble", {
  out <- mrgsim_ds(mod)
  expect_is(dplyr::collect(out), "tbl")
  expect_is(tibble::as_tibble(out), "tbl")
})

test_that("data.frame", {
  out <- mrgsim_ds(mod)
  expect_is(as.data.frame(out), "data.frame")
})

test_that("as_arrow_ds", {
  out <- mrgsim_ds(mod)
  expect_is(as_arrow_ds(out), "FileSystemDataset")
})

test_that("arrow_table", {
  out <- mrgsim_ds(mod)
  expect_is(as_arrow_table(out), "Table")
})

test_that("duck_db", {
  out <- mrgsim_ds(mod)
  expect_is(as_duckdb_ds(out), "tbl_duckdb_connection")
})

rm(mod)
