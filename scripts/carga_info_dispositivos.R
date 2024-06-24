library(tidyverse)
library(janitor)


data <- read_csv("./data/info_dispositivos.csv", col_types = cols(.default = "c")) %>%
  filter(tipo_dispositivo == "camera") %>% 
  mutate(datetime_end = ifelse(is.na(hora_retiro), 
                                 as.POSIXct(paste(fecha_retiro, "00:00:00"), format = "%d/%m/%Y %H:%M:%S"), 
                                 as.POSIXct(paste(fecha_retiro, hora_retiro), format = "%d/%m/%Y %H:%M:%S")),
         datetime_start = ifelse(is.na(hora_puesta), 
                                 as.POSIXct(paste(fecha_puesta, "00:00:00"), format = "%d/%m/%Y %H:%M:%S"), 
                                 as.POSIXct(paste(fecha_puesta, hora_puesta), format = "%d/%m/%Y %H:%M:%S")))

data$datetime_start <- as.POSIXct(data$datetime_start, format = "%d/%m/%Y %H:%M:%S")
data$datetime_end <- as.POSIXct(data$datetime_end, format = "%d/%m/%Y %H:%M:%S")

camera_data <- data %>% 
  select(site = sitio, camera = id_dispositivo, lon, lat, datetime_start, datetime_end, effort = esfuerzo) %>% 
  mutate(effort = as.double(effort),
         lon = as.double(lon),
         lat = as.double(lat))

saveRDS(camera_data, "data_processed/camera_data.RData")

rm(data, camera_data)
