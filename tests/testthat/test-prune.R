library(testthat)
library(mrgsim.ds)

mod <- house_ds(end = 3, delta = 1)
out <- mrgsim_ds(mod)

test_that("prune single object", {
  expect_is(prune_ds(out), "mrgsimsds")
})


test_that("prune list object", {
  l <- list(out, out, out)
  ans <- prune_ds(l)
  expect_is(ans, "list")
  
  expect_all_true(mrgsim.ds:::simlist_classes(ans))
})


test_that("prune list object - drop", {
  l <- list(out, out, letters)
  expect_message(ans <- prune_ds(l), "dropping 1")
  expect_is(ans, "list")
  expect_length(ans, 2)
  expect_all_true(mrgsim.ds:::simlist_classes(ans))
  
  expect_silent(prune_ds(l, inform = FALSE))
  
  l <- list(1,2,3)
  expect_warning(ans <- prune_ds(l), "no mrgsimsds objects")
  expect_length(ans, 0)
})

