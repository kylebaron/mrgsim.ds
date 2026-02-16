library(testthat)
library(mrgsim.ds)

test_that("mrgsim_ds", {
  mod <- house_ds()
  out <- mrgsim_ds(mod)
  expect_is(out, "mrgsimsds")
})

