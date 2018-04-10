library(httr)
http://open-notify.org/Open-Notify-API/ISS-Pass-Times/
  
  

http://api.open-notify.org/iss-pass.json?lat=LAT&lon=LON


latitude <- "51.01667"
longitude <- "4.36667"

query <- paste0("http://api.open-notify.org/iss-pass.json?lat=", latitude,"&lon=", longitude)

response <- GET(query)
resp_content <- content(response)

df <- do.call("rbind", resp_content$response)






responsepeople <- GET("http://api.open-notify.org/astros.json")
content(responsepeople)
toJSON(content(responsepeople), pretty = TRUE)


do.call("rbind", resp_content$response)
stack(resp_content)



test <- list(
  request = list(altitude = 100, datetime = 1523276872, lqtitude = 51.0167, longtitude = 4.3667, passses = 5),
  response = "something")
  
  
toJSON(test, pretty = TRUE)
  
