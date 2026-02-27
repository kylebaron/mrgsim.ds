library(testthat)
library(mrgsim.ds)

mod <- house_ds(end = 3, delta = 1)

test_that("set gc status - single object", {
  out <- mrgsim_ds(mod)
  expect_true(out$gc)
  
  out <- gc_ds(out, FALSE)
  expect_false(out$gc)
  
  out <- gc_ds(out, TRUE)
  expect_true(out$gc)
})

test_that("set gc status - list", {
  out <- list(mrgsim_ds(mod), mrgsim_ds(mod))
  
  expect_true(out[[1]]$gc)
  expect_true(out[[2]]$gc)  
  
  out <- gc_ds(out, FALSE)
  
  expect_false(out[[1]]$gc)
  expect_false(out[[2]]$gc)   
  
})

rm(mod)
