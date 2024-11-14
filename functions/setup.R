# Lista de paquetes necesarios
packages_ <- c(
               ## Para crear el documento              
               "knitr",
               "bookdown",
               "rmarkdown",
               ## Manejo de datos y gráficos
               "tidyverse",
               "janitor",
               "purrr",
               "glue",
               "grid",
               "gridExtra",
               "patchwork",
               "reshape2",
               ## Horario solar, overlap, kernels
               "activity",
               "overlap",
               "suncalc",
               "circular",
               "sp",
               "NPCirc")

# Función para instalar y cargar paquetes
install_and_load <- function(packages_) {
  for (package_ in packages_) {
    if (!require(package_, character.only = TRUE)) {
      install.packages(package_, dependencies = TRUE)
      library(package_, character.only = TRUE)
    }
  }
}

# Instalar y cargar paquetes
install_and_load(packages_)

rm(packages_, install_and_load)


## Solo para desarrollador:
# setwd("E:/la_carpeta/tesis")

