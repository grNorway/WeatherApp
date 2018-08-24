//
//  ApixuConvenience.swift
//  weatherApp
//
//  Created by PS Shortcut on 21/08/2018.
//  Copyright © 2018 PS Shortcut. All rights reserved.
//

import UIKit

extension ApixuClient{
    
    
    //TODO: - Change the method and have 2 completionHandlers for upodating the view in 1)a)LocationStoredViewControllerCell , b) save background on Core Data
    //                                                                                  2)Save the Forecast for ViewController
    
    
    func getCurrentWeather(parameterQ:String,completionHandlerForGetCurrentWeather : @escaping (_ success : Bool ,_ currentDay : CurrentDay?, _ error:String?) -> ()) {
        
        let parameters = [Constants.ApixuParameterKeys.parameterQ : parameterQ]
        
        let _ = taskForGetMethod(apiPath: Constants.Apixu.Paths.aPIPathCurrent, parameters:parameters as [String : AnyObject]) { (results, nsError) in
            
            if let error = nsError {
                completionHandlerForGetCurrentWeather(false,nil,error.localizedDescription)
            }else{
                if results != nil {
                    let currentDayObject = self.parseCurrentWeatherResults(results: results! as! [String : AnyObject])
                    completionHandlerForGetCurrentWeather(true, currentDayObject,nil)
                }else{
                    print("Error: Unable to Find all keys from the Response Body for current Weather)")
                    completionHandlerForGetCurrentWeather(false, nil , "Unable to get current weather")
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
    private func parseCurrentWeatherResults(results : [String : AnyObject]) -> CurrentDay?{
        
            if let location = results[Constants.ApixuResponseKeys.location] as? [String : AnyObject],
                let current = results[Constants.ApixuResponseKeys.current] as? [String : AnyObject]{
                let name = location[Constants.ApixuResponseKeys.Location.name] as! String
                let temp_c = current[Constants.ApixuResponseKeys.Current.temp_c] as! Double
                let is_day = current[Constants.ApixuResponseKeys.Current.is_day] as! Bool
                let localtime_epoch =  location[Constants.ApixuResponseKeys.Location.localtime_epoch] as! Double
                let locatimeTimeInterval = Date(timeIntervalSince1970: localtime_epoch)
                //TODO: - Think what to do with time
                print(locatimeTimeInterval)
                if let condition = current[Constants.ApixuResponseKeys.Current.condition] as? [String : AnyObject]{
                    let weatherDescription = condition[Constants.ApixuResponseKeys.Current.Condition.text] as! String
                    let weatherIconUrlString = condition[Constants.ApixuResponseKeys.Current.Condition.icon] as! String
                    let currentDayObject = CurrentDay(cityName: name, weatherDescription: weatherDescription, tempAvgInt: Int(temp_c), is_day: is_day, weatherIconUrlString: weatherIconUrlString)
                    
                    return currentDayObject
                }
            }
        
        return nil
        
    }
    
    private func parseLocationResults(results: [[String:AnyObject]]) -> [Location]  {
        
        var locations = [Location]()
        for location in results{
            if let locationName = location[Constants.ApixuResponseKeys.search.name] as? String{
                var locationFound = Location()
                locationFound.name = locationName
                locations.append(locationFound)
            }
        }
        return locations
    
    }
    
}











