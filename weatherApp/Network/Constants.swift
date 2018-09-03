//
//  Constants.swift
//  weatherApp
//
//  Created by PS Shortcut on 21/08/2018.
//  Copyright © 2018 PS Shortcut. All rights reserved.
//


// CURRENT CALL : https://api.apixu.com/v1/current.json?key=329d78c62f264db7948223617172407&q=oslo
// FORECAST CALL : https://api.apixu.com/v1/forecast.json?key=329d78c62f264db7948223617172407&q=oslo&days=3
// Autocomplete/Search : https://api.apixu.com/v1/search.json?key=329d78c62f264db7948223617172407&q=osl

import Foundation

struct Constants{
    
    struct Apixu{
        static let aPIScheme = "https"
        static let aPIHost = "api.apixu.com"
        
        enum Paths{
            static let aPIPathCurrent = "/v1/current.json"
            static let aPIPathForecast = "/v1/forecast.json"
            static let aPIPathSearch = "/v1/search.json"
        }
        
    }
    
    //MARK: - ParameterKeys
    // - NOTICE --> parameterQ : Pass US Zipcode, UK Postcode, Canada Postalcode, IP address, Latitude/Longitude (decimal degree) or city name

    struct ApixuParameterKeys {
        
        static let apiKey = "key"
        static let parameterQ = "q"
        static let days = "days"
        
    }
    
    //MARK: - ParameterValues
    struct ApixyParameterValues{
        
        static let aPIKeyValue = "329d78c62f264db7948223617172407"
        
    }
    
    //MARK: - ResponseKeys
    struct ApixuResponseKeys {
        
        static let location = "location"
        struct Location{
            static let name = "name"
            static let localtime_epoch = "localtime_epoch"
            static let localtime = "localtime"
            static let timezoneID = "tz_id"
        }
        
        static let current = "current"
        struct Current{
            static let temp_c = "temp_c"
            static let is_day = "is_day"
            
            
            static let condition = "condition"
            struct Condition{
                static let text = "text"
                static let icon = "icon"
            }
            
            static let wind_kph = "wind_kph"
            static let wind_dir = "wind_dir"
            static let precip_mm = "precip_mm"
            static let humidity = "humidity"
            static let cloud = "cloud" // Presents percentage
            static let feelslike_c = "feelslike_c"
            
        }
        
        static let forecast = "forecast"
        struct Forecast {
            
            static let forecastday = "forecastday"
            struct Forecastday {
                
                static let date_epoch = "date_epoch"
                
                static let day = "day"
                struct Day {
                    static let maxtemp_c = "maxtemp_c"
                    static let mintemp_c = "mintemp_c"
                    static let avgtemp_c = "avgtemp_c"
                    static let maxwind_kph = "maxwind_kph"
                    static let totalprecip_mm = "totalprecip_mm"
                    static let avgvis_km = "avgvis_km"
                    static let avghumidity = "avghumidity"
                    
                    static let condition = "condition"
                    struct Condition {
                        static let text = "text"
                        static let icon = "icon"
                    }
                    
                }
                
                static let astro = "astro"
                struct Astro {
                    static let sunrise = "sunrise"
                    static let sunset = "sunset"
                }
                
                
                static let hour = "hour"
                struct Hour{
                    static let time_epoch = "time_epoch"
                    static let time = "time"
                    static let temp_c = "temp_c"
                    static let is_day = "is_day"
                    
                    static let condition = "condition"
                    struct Condition {
                        static let text = "text"
                        static let icon = "icon"
                    }
                    
                    static let wind_kph = "wind_kph"
                    static let wind_dir = "wind_dir"
                    static let precip_mm = "precip_mm"
                    static let humidity = "humidity" // Percentage
                    static let cloud = "cloud" // Percentage
                    static let feelslike_c = "feelslike_c"
                    static let will_it_rain = "will_it_rain" // Percentage
                    static let chance_of_rain = "chance_of_rain" // Percentage
                    static let will_it_snow = "will_it_snow" // Percentage
                    static let chance_of_snow = "chance_of_snow" // Percentage
                    static let vis_km = "vis_km"
                    
                    
                }
                
            }
            
        }
        
        struct search{
            
            static let id = "id"
            static let name = "name"
            static let url = "url"
            
        }
        
    }
    
    
    
    
    
}
