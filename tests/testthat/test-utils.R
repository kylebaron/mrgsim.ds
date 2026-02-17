library(testthat)
library(mrgsim.ds)

test_that("require ds", {
  mod <- house_ds()
  out <- mrgsim_ds(mod)
  expect_null(mrgsim.ds:::require_ds(out))
  expect_error(mrgsim.ds:::require_ds(letters), "not 'character'")
  expect_error(mrgsim.ds:::require_ds(mtcars), "not 'data.frame'")
})

test_that("format numbers for print", {
  x <- mrgsim.ds:::format_big()(1234)  
  expect_equal(x, "1.2K")

  x <- mrgsim.ds:::format_big()(123456789)  
  expect_equal(x, "123.5M")
})
