library(httr)
http://open-notify.org/Open-Notify-API/ISS-Pass-Times/
  
  

http://api.open-notify.org/iss-pass.json?lat=LAT&lon=LON


latitude <- "51.01667"
longitude <- "4.36667"

query <- paste0("http://api.open-notify.org/iss-pass.json?lat=", latitude,"&lon=", longitude)

response <- GET(query)
resp_content <- content(response)

timestamp <- resp_content$response[[1]]$risetime
as.POSIXct(timestamp, origin = "1970-01-01", tz = "CET")




responsepeople <- GET("http://api.open-notify.org/astros.json")
content(responsepeople)
toJSON(content(responsepeople), pretty = TRUE)

Jan 01 1970