
Sys.setenv("R_TESTS" = "")

library(testthat)
library(mrgsim.ds)
test_check("mrgsim.ds", reporter="summary")
