load_data <- function() {
  # Se necesita que exista una carpeta "Datos" que contenga un archivo 'sitios_de_estudio.csv' y otro 'planilla_general.RData'.
  site_coords <- read.csv("./data/sitios_de_estudio.csv") %>% 
    select(site = Name, lat = Y, lon = X)
  
  load(file = "./data/planilla_general.RData")
  
  sp_pairs <- c("Btau", "Cfam", "Aaxi", "Mgou", "Ctho", "Lgym", "Lwie", "Lgeo", "Dnov", "Dsep")
  
  data <- datos %>%
    filter(type == "Mammal" & site != "QC" & species %in% sp_pairs) %>%
    select(site, station, camera, datetime, sp = species) %>% 
    left_join(site_coords, by = join_by(site)) %>% 
    select(site, camera, lat, lon, datetime, sp) 
  return(data)
}

data <- load_data()

save(data, file="data_processed/datos_procesados_v0.RData")
