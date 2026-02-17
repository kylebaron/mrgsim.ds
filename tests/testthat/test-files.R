library(testthat)
library(mrgsim.ds)

mod <- house_ds()

test_that("total size", {
  out <- mrgsim_ds(mod, gc = FALSE)
  tot <- mrgsim.ds:::total_size(out$files)
  expect_is(tot, "character")
  expect_match(tot, "Kb")
})

test_that("files exist", {
  out <- mrgsim_ds(mod, gc = FALSE)
  expect_true(mrgsim.ds:::files_exist(out))
  out$files <- "b"
  expect_error(mrgsim.ds:::files_exist(out), "do not exist")
})

test_that("clean up", {
  out <- mrgsim_ds(mod, gc = TRUE)
  expect_true(file.exists(out$files))
  files <- out$files
  rm(out)
  gc()
  expect_false(file.exists(files))
})

test_that("file_ds", {
  set.seed(123)
  x <- file_ds()
  expect_is(x, "character")
  expect_match(x, "mrgsims-ds-", fixed = TRUE)
  expect_match(x, ".parquet", fixed = TRUE)
  
  x <- file_ds("fizz")
  expect_equal(x, "mrgsims-ds-fizz.parquet")
})

test_that("rename_ds", {
  out <- mrgsim_ds(mod)
  a <- basename(out$files)
  out <- rename_ds(out, "zip")
  b <- basename(out$files)
  expect_equal(b, "mrgsims-ds-zip-0001.parquet")
})

test_that("write_ds", {
  out <- mrgsim_ds(mod)
  x <- write_ds(out, file.path(tempdir(), "test-write"))
  expect_false(x$gc)
  expect_equal(basename(x$files), "test-write")
  expect_equal(dirname(normalizePath(x$files)), normalizePath(tempdir()))
})

rm(mod)
