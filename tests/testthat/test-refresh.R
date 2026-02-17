library(testthat)
library(mrgsim.ds)

test_that("refresh invalid pointers", {
  mod <- house_ds(end = 3, delta = 1)
  out <- mrgsim_ds(mod)
  out$ds$set_pointer(new("externalptr"))
  expect_false(mrgsim.ds:::valid_ds(out))
  out <- refresh_ds(out)
  expect_true(mrgsim.ds:::valid_ds(out))

  out$ds$set_pointer(new("externalptr"))
  expect_false(mrgsim.ds:::valid_ds(out))
  out <- reduce_ds(out)
  expect_true(mrgsim.ds:::valid_ds(out))
  
  l <- list(mrgsim_ds(mod), mrgsim_ds(mod), mrgsim_ds(mod))
  x <- refresh_ds(l)
  expect_is(l, "list")
  v <- sapply(l, mrgsim.ds:::valid_ds)  
  expect_all_true(v)
})

