

install.packages(c("sf", "rmapshaper", "readr"))

# Load the necessary libraries
library(sf)
library(rmapshaper)
library(readr)

# Define the path to the shapefile
shapefile_path <- "../data/raw/SIRGAS_SHP_distrito/SIRGAS_SHP_distrito.shp"

# Read the shapefile
shp_data <- st_read(shapefile_path)

# Simplify the shapefile (tolerance value can be adjusted as needed)
shp_data_simplified <- ms_simplify(shp_data, keep = 0.05)

object.size(shp_data_simplified)
# Define the path to save the RDS file
rds_path <- "../data/clean/SIRGAS_SHP_distrito_simplified.rds"
rds_path2 <- "../shiny_app/data/SIRGAS_SHP_distrito_simplified.rds"
# Save the simplified shapefile as an RDS file
write_rds(shp_data_simplified, rds_path)
write_rds(shp_data_simplified, rds_path2)

plot(shp_data_simplified)
