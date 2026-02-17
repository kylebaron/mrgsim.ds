library(testthat)
library(mrgsim.ds)

mod <- house_ds(end = 3)

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

test_that("move_ds", {
  out <- mrgsim_ds(mod)
  nw <- file.path(tempdir(), "newdir")
  x <- move_ds(out, path = nw)
  tst <- basename(dirname(x$files))
  expect_equal(tst, "newdir")
  expect_true(x$gc)
})

test_that("temp file helpers", {
  purge_temp()
  out <- mrgsim_ds(mod, id = "AA1", gc = FALSE)
  out <- mrgsim_ds(mod, id = "AA2", gc = FALSE)
  out <- mrgsim_ds(mod, id = "AA3", gc = FALSE)
  x <- suppressMessages(list_temp())
  expect_length(x, 3)
  expect_match(x, "mrgsims-ds-AA[0-9]")
  expect_message(x <- purge_temp(), "Discarding 3 files.")
  expect_null(x)
  
  suppressMessages(purge_temp())
  out1 <- mrgsim_ds(mod, id = "AA1", gc = FALSE)
  out2 <- mrgsim_ds(mod, id = "AA2", gc = FALSE)
  out3 <- mrgsim_ds(mod, id = "AA3", gc = FALSE)
  f <- c(out1$files, out3$files)  
  expect_message(retain_temp(out1, out3), "Discarding 1 files.")
  suppressMessages(x <- list_temp())
  expect_identical(
    normalizePath(f), 
    normalizePath(x)
  )
  
  suppressMessages(purge_temp())
  out <- lapply(1:7, \(x) mrgsim_ds(mod))
  suppressMessages(x <- list_temp())
  expect_length(x, 7)
})

rm(mod)
