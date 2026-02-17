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

rm(mod)
