horasolar <- function(datetime, longitude, timezone) {
  date_structure <- as.POSIXlt(as.POSIXct(datetime), tz = timezone)
  timezone_value <- date_structure$gmtoff / 3600
  
  N = yday(datetime) # Días del año.
  h = hour(datetime)
  mm = minute(datetime)
  ss = second(datetime)
  
  
  x=2*pi*(N-1-(h-12)/24)/365
  eqtime=229.18*(0.000075+0.001868*cos(x)-0.032077*sin(x)-0.014615*cos(2*x)-0.040849*sin(2*x))
  
  time_offset=eqtime-4*longitude+60*timezone_value
  tst=h*60+mm+ss/60-time_offset
  hours_ <- tst/60
  minutes_<- (hours_-floor(hours_))*60
  seconds_ = (minutes_ -floor(minutes_))*60
  # Para formatear
  hours_text <- abs(floor(hours_))
  minutes_text <- abs(floor(minutes_))
  seconds_text <- abs(floor(seconds_))
  
  
  
  hours_text <- ifelse(nchar(hours_text) < 2, paste0("0", hours_text), hours_text)
  minutes_text <- ifelse(nchar(minutes_text) < 2, paste0("0", minutes_text), minutes_text)
  seconds_text <- ifelse(nchar(seconds_text) < 2, paste0("0", seconds_text), seconds_text)
  resultado <- paste0(as.character(date(datetime)), " ",hours_text, ":", minutes_text, ":", seconds_text) %>% 
    as.POSIXct(., tz = timezone)
  
  return(resultado)
}