# memoise the data loading function to not repeatedly call
# the API in a single session
.onLoad <- function(lib, pkg) {
  idmc_get_data <<- memoise::memoise(idmc_get_data)
}
