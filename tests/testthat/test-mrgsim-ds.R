library(testthat)
library(mrgsim.ds)

test_that("mrgsim_ds", {
  mod <- house_ds()
  out <- mrgsim_ds(mod)
  expect_is(out, "mrgsimsds")
  expect_all_true(file.exists(out$files))
  expect_true(mrgsim.ds:::valid_ds(out))
  
  sims <- as_tibble(out)
  expect_identical(dim(sims), out$dim)
  expect_identical(dim(sims), dim(out))
  expect_identical(names(sims), out$names)
  expect_identical(names(sims), names(out))
  expect_identical(head(out), sims[1:6,])
  expect_identical(tail(out), tail(sims))
})

test_that("as_mrgsim_ds", {
  mod <- house_ds()
  x <- mrgsim(mod)
  out <- as_mrgsim_ds(x)
  expect_is(out, "mrgsimsds")
  expect_all_true(file.exists(out$files))
  expect_true(mrgsim.ds:::valid_ds(out))
})

test_that("named output files", {
  mod <- house_ds()
  out <- mrgsim_ds(mod, id = "testthat")
  expect_match(out$files, "testthat.parquet", fixed = TRUE)
  expect_error(mrgsim_ds(mod, id = "a bc"), "cannot contain spaces")
})

test_that("tag output data", {
  mod <- house_ds()
  tg <- list(a = 1, b = 2)
  out <- mrgsim_ds(mod, tags = tg)
  out <- as_tibble(out)
  expect_true("a" %in% names(out))
  expect_true("b" %in% names(out))
  expect_all_true(out$a==1)
  expect_all_true(out$b==2)
  
  expect_error(mrgsim_ds(mod, tags = list(1)), "must be a named list")
})




