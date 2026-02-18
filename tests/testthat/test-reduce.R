library(testthat)
library(mrgsim.ds)

mod <- house_ds(end = 3, delta = 1)

test_that("reduce lists of simulations", {
  x <- list(mrgsim_ds(mod), mrgsim_ds(mod), mrgsim_ds(mod))
  out <- reduce_ds(x)
  expect_is(out, "mrgsimsds")
  expect_length(out$files, 3)

  x <- list(mrgsim_ds(mod), mrgsim_ds(mod), letters, mrgsim_ds(mod))
  expect_error(reduce_ds(x), "must inherit from ")

  out <- reduce_ds(mrgsim_ds(mod))
  expect_is(out, "mrgsimsds")
  expect_length(out$files,1)
})

test_that("ok to reduce", {
  a <- mrgsim_ds(mod, gc = FALSE)
  b <- mrgsim_ds(mod, gc = FALSE)
  c <- mrgsim_ds(mod, gc = FALSE)
  
  bb <- copy_ds(b)
  bb$names <- letters
  x <- list(a,bb,c)
  expect_error(reduce_ds(x), "must have the same column names")
  
  bb <- copy_ds(b)
  bb$files <- 'a'
  x <- list(a,bb,c)
  expect_error(reduce_ds(x), "data set files do not exist")

  bb <- copy_ds(b)
  bb$files <- a$files
  x <- list(a,bb,c)
  expect_error(reduce_ds(x), "duplicate files")
  
  bb <- copy_ds(b)
  bb$mod@model <- "wrong-model"
  x <- list(a, bb, c)
  expect_error(reduce_ds(x))
})

rm(mod)

