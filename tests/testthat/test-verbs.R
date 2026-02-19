library(testthat)
library(mrgsim.ds)

mod <- house_ds(end = 3, delta = 1)
data <- ev_expand(amt = 100, ID = 1:3)
out <- mrgsim_ds(mod, data = data, gc = FALSE)

test_that("test verbs", {
  a <- dplyr::group_by(out)
  sims <- dplyr::collect(a)
  expect_is(a, "arrow_dplyr_query")
  expect_is(sims, "tbl")

  b <- dplyr::mutate(out, z = 1)  
  sims <- dplyr::collect(b)
  expect_is(b, "arrow_dplyr_query")
  expect_is(sims, "tbl")
  expect_all_true(sims$z==1)

  c <- dplyr::select(out, time, DV)
  sims <- dplyr::collect(c)
  expect_is(b, "arrow_dplyr_query")
  expect_is(sims, "tbl")
  expect_equal(names(sims), c("time", "DV"))
  
  d <- dplyr::filter(out, time < 3, ID==1, .by = ID)
  sims <- dplyr::collect(d)
  expect_equal(sims$time, c(0,0,1,2))
  
  e <- dplyr::summarise(out, M = mean(DV), .by = ID)
  sims <- dplyr::collect(e)
  expect_equal(sims$ID, c(1,2,3))
})

rm(out, mod, data)
