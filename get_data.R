library(ncdf4)
library(tidyverse)
library(ggplot2)

data_path <- "bcsd5"
data_files <- paste0("Extraction_", c("tas", "pr", "tasmin", "tasmax"), ".nc")

dat <- nc_open(file.path(data_path, data_files[1]))
long_vec <- ncvar_get(dat, "longitude")
lat_vec <- ncvar_get(dat, "latitude")
date_vec <- ncvar_get(dat, "time") + as.Date("1950-01-01")
temp_dat <- ncvar_get(dat, "tas")

projections <- read.table("bcsd5/Projections5.txt")[,1]

model_idx <- 70

dat <- temp_dat[,,,model_idx] %>%
    reshape2::melt() %>%
    as_tibble() %>%
    mutate(longitude = as.factor(long_vec[Var1]), 
           latitude = as.factor(lat_vec[Var2]), 
           date = date_vec[Var3], 
           temp = value) %>%
    select(date, latitude, longitude, temp) %>%
    mutate(latitude = fct_rev(latitude))

ggplot(dat, aes(x = date, y = temp)) + 
    facet_grid(latitude ~ longitude) + 
    geom_line() + 
    labs(title = projections[model_idx]) + 
    theme_bw()
