library(spelling)

message("checking package")
spell_check_package()
ignore <- readLines("inst/WORDLIST")
