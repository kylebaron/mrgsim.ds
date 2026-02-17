
library(testthat)
library(mrgsim.ds)

test_that("collect and as_tibble", {
  mod <- house_ds()
  out <- mrgsim_ds(mod)
  expect_is(dplyr::collect(out), "tbl")
  expect_is(tibble::as_tibble(out), "tbl")
})

test_that("data.frame", {
  mod <- house_ds()
  out <- mrgsim_ds(mod)
  expect_is(as.data.frame(out), "data.frame")
})

test_that("as_arrow_ds", {
  mod <- house_ds()
  out <- mrgsim_ds(mod)
  expect_is(as_arrow_ds(out), "FileSystemDataset")
})

test_that("arrow_table", {
  mod <- house_ds()
  out <- mrgsim_ds(mod)
  expect_is(as_arrow_table(out), "Table")
})

test_that("duck_db", {
  mod <- house_ds()
  out <- mrgsim_ds(mod)
  expect_is(as_duckdb_ds(out), "tbl_duckdb_connection")
})

