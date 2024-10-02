# Lista de paquetes necesarios
packages_ <- c("tidyverse", "bookdown", "knitr", "rmarkdown", "suncalc", "circular", "sp", "activity", "NPCirc", "janitor", "overlap")

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
