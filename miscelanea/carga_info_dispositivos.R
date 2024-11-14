library(tidyverse)
library(janitor)


camera_data <- read_csv("../data/info_dispositivos.csv", col_types = cols(.default = "c")) %>%
  filter(tipo_dispositivo == "camera") %>% 
  mutate(datetime_end = ifelse(is.na(hora_retiro), 
                                 as.POSIXct(paste(fecha_retiro, "00:00:00"), format = "%d/%m/%Y %H:%M:%S"), 
                                 as.POSIXct(paste(fecha_retiro, hora_retiro), format = "%d/%m/%Y %H:%M:%S")),
         datetime_start = ifelse(is.na(hora_puesta), 
                                 as.POSIXct(paste(fecha_puesta, "00:00:00"), format = "%d/%m/%Y %H:%M:%S"), 
                                 as.POSIXct(paste(fecha_puesta, hora_puesta), format = "%d/%m/%Y %H:%M:%S")))

camera_data$datetime_start <- as.POSIXct(camera_data$datetime_start, format = "%d/%m/%Y %H:%M:%S")
camera_data$datetime_end <- as.POSIXct(camera_data$datetime_end, format = "%d/%m/%Y %H:%M:%S")

camera_data <- camera_data %>% 
  select(site = sitio, camera = id_dispositivo, lon, lat, datetime_start, datetime_end, effort = esfuerzo) %>% 
  mutate(effort = as.double(effort),
         lon = as.double(lon),
         lat = as.double(lat))

load("../data_processed/datos_procesados_v0.RData")

study_cameras <- data %>% select(camera) %>% distinct() %>% pull()

camera_data <- camera_data %>%
  filter(camera %in% study_cameras)

saveRDS(camera_data, "../data_processed/camera_data.RData")

rm(data, camera_data)
