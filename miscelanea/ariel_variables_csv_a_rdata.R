## Este script es para pasar de CSV a RData los datos que me compartio Ariel. Numero de techos, tipos de cobertura, etc.
## También para verificar que no falta el dato de ninguna cámara.

library(tidyverse)

variables_camera_df <- read_csv("../data/variables_cobertura_100m.csv") %>% 
  rename(site = "CAMARA") %>% 
  clean_names()

variables_system_df <- read_csv("../data/variables_cobertura_500m.csv") %>% 
  rename(system ="SISTEMA") %>% 
  clean_names()

saveRDS(variables_camera_df, "../data_processed/variables_camera_df.RData")
saveRDS(variables_system_df, "../data_processed/variables_system_df.RData")
