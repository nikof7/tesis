# Appendix 3

# This R function convert the clock time to sun time as explain
# in Nouvellet et al., noisy clock and silent sunrise.
# Firt the time of sunrise and sunset are calculated for a
# given date (day and month) of the year and for a given
# location.
#
#
# We note that the location is characterised by
#       1) its latitude, in degree and positive (negative) if 
#       north (south) of the equator,
#       2) its longitude, in degree and positive (negative) if 
#       west (east) of the prime (Greenwich) meridian,
#       3) its time zone, which is defined as the 'Current time  
#       zone offset' (specific of a given date and location) and 
#       account for both the 'Standard time zone' and a possible
#       'Daylight saving time'.
#
# The function may be called using R after adding the function to the
# source (i.e. using the command: source("filelocation\SunTime.R")).
#
# The function needs the following input in the following order:
#       1) a column vector containing the clock times of observations  
#       using hours (i.e. 3:30pm should be coded as 15.5),
#       2) a column vector containing the days (of the month),
#       3) a column vector containing the months,  
#       4) a column vector containing the latitude of observations,
#       5) a column vector containing the longitude of observations,
#       6) a column vector containing the time zone of observations,
#       7) a binary column vector taking the value '1' ('0') if a given 
#       observation was made in the morning (evening).
#
# The function return the following output in the following order:
#       1) a column vector containing the deviation between clock times  
#       and suntime of observations,
#       2) a column vector containing the clock times of observations  
#       using hours (i.e. 3:30pm should be coded as 15.5),
#       3) the time of sunrise at the given date and location,
#       4) the time of sunset at the given date and location,
#       5) a column vector containing the days (of the month),
#       6) a column vector containing the months,  
#       7) a column vector containing the latitude of observations,
#       8) a column vector containing the longitude of observations,
#       9) a column vector containing the time zone of observations,
#       10) a binary column vector taking the value '1' ('0') if a given 
#       observation was made in the morning (evening).
#
# The function may be called using R after adding the function to the
# source (i.e. using the command: source("filelocation\SunTime.R")).
#
# Then one can use the following command:
# ST<-SunTime(ClockTime,day,month,lat,long,timeZone,RS)
# and the ST matrix will include as defined above:
# (SunTime,ClockTime,Hrise,Hset,day,month,lat,long,timeZone,RS)
#
# This function, and potential update of it, are available from
# http://www.ese.u-psud.fr/epc/conservation/pages/Franck/docs/SunTime.R
#
# to use cite: Nouvellet, P., Rasmussen, G.S.A, Macdonald, D.W., 
# Courchamp, F., 201?. Noisy clock and silent sunrise: measurment
# methods of daily activity pattern. Journal of ??, ??, ??.
# 

SunTime<-function(ClockTime,day,month,lat,long,timeZone,RS) {
  
  lo<-long*12/180
  d2r<-pi/180
  m<-c(31,28,31,30,31,30,31,31,30,31,30,31)
  j<-rep(8,length(day))
  for (i in 1:length(day)){
    j[i]<-sum(m[0:(month[i]-1)])+day[i]
  }
  
  # mean anomaly
  Mo<-357.5291*d2r
  M1<-0.9856*d2r
  M<-Mo+M1*j
  
  # ellipse contribution
  e<-0.01671
  C<-(2*e-e^3/4)*sin(M)+5/4*e^2*sin(2*M)+13/12*e^3*sin(3*M)
  
  # ecliptic longitude
  lambda<-280.47*d2r+M1*j+C
  
  # earth's tilt contribution
  epsilon<-23.45*d2r
  R<-(-epsilon^2/4-epsilon^4/24-17/2880*epsilon^6)*sin(2*lambda)+(epsilon^4/32+epsilon^6/96)*sin(4*lambda)-epsilon^6*sin(6*lambda)/192
  
  # equation of Time
  Dt<-4*(C+R)
  
  # declination
  Dc<-asin(sin(epsilon)*sin(lambda))
  
  # sun height
  r<-34
  d<-32
  b<-0
  hs<- -r-d/2+b
  
  # hour angle
  cosHa<-(sin(hs*d2r/60)-sin(Dc)*sin(lat*d2r))/cos(Dc)/cos(lat*d2r)
  Ha<-acos(cosHa)/15/d2r
  
  # Time of sunrise
  Hrise<-12+Dt-Ha+lo+timeZone
  Hset<-12+Dt+Ha+lo+timeZone
  
  # sun Time
  nRise<-(RS==1)
  nSet<-(RS==0)
  SunTime<-rep(0,length(RS))
  SunTime[nRise]<-ClockTime-Hrise[nRise]
  SunTime[nSet]<-ClockTime-Hset[nSet]
  
  # Output
  Output<-cbind(SunTime,ClockTime,Hrise,Hset,day,month,lat,long,timeZone,RS)
  
  return(Output) 
}