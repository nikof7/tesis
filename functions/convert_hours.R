hour_to_decimal <- function(datetime) {
  h <- hour(datetime)
  m <- minute(datetime)
  s <- second(datetime)
  return(h + m / 60 + s / 3600)
}

hour_to_radians <- function(datetime) {
  decimal_time <- hour_to_decimal(datetime)
  radian_time <- decimal_time * ((2 * pi)/24)
  return(radian_time)
}

radians_to_decimal <- function(radians) {
  hours <- (radians / (2 * pi)) * 24
  hours <- hours %% 24  # Ensure hours are in the range of 0 to 24
  return(hours)
}

decimal_to_hours <- function(decimal) {
  hours <- floor(decimal)
  minutes <- floor((decimal - hours) * 60)
  seconds <- round(((decimal - hours) * 60 - minutes) * 60)
  
  # Format the values to have two digits
  hours <- sprintf("%02d", hours)
  minutes <- sprintf("%02d", minutes)
  seconds <- sprintf("%02d", seconds)
  
  time_format <- paste(hours, minutes, seconds, sep = ":")
  return(time_format)
}

radians_to_hour <- function(radians) {
  decimal <- radians_to_decimal(radians)
  return(decimal_to_hours(decimal))
}
