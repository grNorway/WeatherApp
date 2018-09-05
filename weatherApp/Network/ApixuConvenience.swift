//
//  ApixuConvenience.swift
//  weatherApp
//
//  Created by PS Shortcut on 21/08/2018.
//  Copyright © 2018 PS Shortcut. All rights reserved.
//

import UIKit
import CoreData

extension ApixuClient{
    
    
    
    
    //TODO: - Change the method and have 2 completionHandlers for upodating the view in 1)a)LocationStoredViewControllerCell , b) save background on Core Data
    //                                                                                  2)Save the Forecast for ViewController
    
    
    func getCurrentWeatherAndForecast(parameterQ:String,locationID : Int,days : Int,completionHandlerForGetCurrentWeather : @escaping (_ success : Bool, _ error:String?) -> ()) {
        
        let parameters = [Constants.ApixuParameterKeys.parameterQ : parameterQ,
                          Constants.ApixuParameterKeys.days : days] as [String : AnyObject]
        
        let _ = taskForGetMethod(apiPath: Constants.Apixu.Paths.aPIPathForecast, parameters:parameters as [String : AnyObject]) { (results, nsError) in
            
            if let error = nsError {
                completionHandlerForGetCurrentWeather(false,error.localizedDescription)
            }else{
                if results != nil {
                    self.parseCurrentWeatherResults(results: results! as! [String : AnyObject], locationID: locationID)
                    completionHandlerForGetCurrentWeather(true,nil)
                }else{
                    print("Error: Unable to Find all keys from the Response Body for current Weather)")
                    completionHandlerForGetCurrentWeather(false, "Unable to get current weather")
                }
                
            }
            
        }
    }
    
    //MARK: - getForecast
    /// It returns and array of dayPrediction of object DayPrediction
    func getForecast(parameterQ : String,days: Int, completionHandlerForGetForecast : @escaping (_ success: Bool, _ daysForecast : [DayPrediction]? ,_ errorString: String? ) -> ()){

        
        let parameters = [Constants.ApixuParameterKeys.parameterQ : parameterQ,
                          Constants.ApixuParameterKeys.days : days] as [String: AnyObject]

        let _ = taskForGetMethod(apiPath: Constants.Apixu.Paths.aPIPathForecast, parameters: parameters) { (results, nsError) in

            if let error = nsError{
                completionHandlerForGetForecast(false,nil,error.localizedDescription)
            }else{
                if results == nil {
                    completionHandlerForGetForecast(false,nil,"Unable to find Day Weather Prediction")
                }else{
                    self.parseForecast(results: results as! [String : AnyObject], completionHandlerForParseForecast: { (daysPredictionArray, errorString) in
                        guard errorString == nil else {
                            completionHandlerForGetForecast(false,nil,errorString!)
                            return
                        }
                        
                        completionHandlerForGetForecast(true,daysPredictionArray!,nil)
                    })
                }
            }
        }

    }
    
    //MARK: - getSearchLocations()
    /// Makes the call to Serch/Autocomplete Apixu Api and returns an array of locations
    func getSearchLocations(parameterQ: String , completionHandlerForGetSearchLocations : @escaping (_ success : Bool , _ resultsArray: [Location]? ,_ errorString:String?) -> ()){
        
        let parameters = [Constants.ApixuParameterKeys.parameterQ: parameterQ]
        
        let _ = taskForGetMethod(apiPath: Constants.Apixu.Paths.aPIPathSearch, parameters: parameters as [String : AnyObject]) { (results, nsError) in
            
            if let error = nsError {
                completionHandlerForGetSearchLocations(false , nil , error.localizedDescription)
            }else{
                if let results = results {
                    let locationsArray = self.parseLocationResults(results: results as! [[String : AnyObject]])
                    completionHandlerForGetSearchLocations(true,locationsArray,nil)
                }else{
                    completionHandlerForGetSearchLocations(false,nil,"Could not get results for locations")    
                }
            }
            
        }
    }
    
    
    //MARK: - parseCurrentWeatherResults
    /// Parse results from getMethod and saves a LocationCurrentWeatherObject
    private func parseCurrentWeatherResults(results : [String : AnyObject],locationID:Int){
        
        if let location = results[Constants.ApixuResponseKeys.location] as? [String:AnyObject]{
            let locationName = location[Constants.ApixuResponseKeys.Location.name] as! String
            
            let locationObject = LocationCurrentWeatherObject(context: coreDataStack.viewContext)
            locationObject.locationName = locationName
            locationObject.creationDate = Date()
            locationObject.locationID = Int32(locationID)
            
            coreDataStack.saveViewContext()
            
        }
                   
        
    }
    

    private func parseLocationResults(results: [[String:AnyObject]]) -> [Location]  {
        
        var locations = [Location]()
        for location in results{
            if let locationName = location[Constants.ApixuResponseKeys.search.name] as? String,let locationID = location[Constants.ApixuResponseKeys.search.id] as? Int{
                var locationFound = Location()
                locationFound.name = locationName
                //TODO: - Delete comment
                //print(locationID)
                locationFound.locationID = locationID
                locations.append(locationFound)
            }
        }
        return locations
    
    }
    
    private func downloadIconData(iconPath : String,completionHandlerDownloadIconData : @escaping(_ iconData : Data?,_ errorString:String?) -> ()){
        let iconPath = String(format: "https:%@", iconPath.replacingOccurrences(of: "//", with: "", options: NSString.CompareOptions.literal, range: nil))
        print(iconPath)
        guard let iconURL = URL(string: iconPath) else{
            completionHandlerDownloadIconData(nil,"Error URL Download weather Icon")
            return
        }
        
        let request : URLRequest = URLRequest(url: iconURL)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            guard error == nil else{
                completionHandlerDownloadIconData(nil,"Error completionHandlerForDownloadIconData : \(error!.localizedDescription)")
                return
            }
            
            completionHandlerDownloadIconData(data,nil)
        }
        task.resume()
    }
    
    
    //MARK: - Parse Forecast day
    /// Parses the JSON result and returns an array of [DayPrediction]
    private func parseForecast(results: [String : AnyObject],completionHandlerForParseForecast: @escaping (_ daysArray: [DayPrediction]?,_ errorString: String?) -> ()){
        
        if let forecast = results[Constants.ApixuResponseKeys.forecast] as? [String:AnyObject]{
            if let forecastdays = forecast[Constants.ApixuResponseKeys.Forecast.forecastday] as? [[String:AnyObject]] {
                var dayArray : [DayPrediction] = []
                for day in forecastdays {
                    let creatingDate = day[Constants.ApixuResponseKeys.Forecast.Forecastday.date_epoch] as! Int
                    let dateEpoch = Date.init(timeIntervalSince1970: TimeInterval(creatingDate))
                    if let dayWeather = day[Constants.ApixuResponseKeys.Forecast.Forecastday.day] as? [String:AnyObject]{
                        let maxTemp_c = dayWeather[Constants.ApixuResponseKeys.Forecast.Forecastday.Day.maxtemp_c] as! Double
                        let minTemp_c = dayWeather[Constants.ApixuResponseKeys.Forecast.Forecastday.Day.mintemp_c] as! Double
                        if let condition = dayWeather[Constants.ApixuResponseKeys.Forecast.Forecastday.Day.condition] as? [String:AnyObject]{
                            let iconStringUrl = condition[Constants.ApixuResponseKeys.Forecast.Forecastday.Day.Condition.icon] as! String
                            let weatherDescription = condition[Constants.ApixuResponseKeys.Forecast.Forecastday.Day.Condition.text] as! String
                            
                            let dayPrediction = DayPrediction(creatingDate: Date(), date: dateEpoch, maxTemp_c: maxTemp_c, minTemp_c: minTemp_c,iconStringURL:iconStringUrl,weatherDescription:weatherDescription)
                            dayArray.append(dayPrediction)
                            
                        }
                    }
                }//end For
                completionHandlerForParseForecast(dayArray,nil)
                
            }else{
                completionHandlerForParseForecast(nil,"Unable to Get information for the weather. Possible Internal Error. Please try again or contact customer support")
            }
            
        }else{
                completionHandlerForParseForecast(nil,"Unable to Get information for the weather. Possible Internal Error. Please try again or contact customer support")
        }
        
    }
    
}











