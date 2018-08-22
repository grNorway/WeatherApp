//
//  ApixuConvenience.swift
//  weatherApp
//
//  Created by PS Shortcut on 21/08/2018.
//  Copyright © 2018 PS Shortcut. All rights reserved.
//

import UIKit

extension ApixuClient{
    
    func getCurrentWeather(parameterQ:String,completionHandlerForGetCurrentWeather : @escaping (_ success : Bool ,_ currentDay : CurrentDay?, _ error:String?) -> ()) {
        
        let parameters = [Constants.ApixuParameterKeys.parameterQ : parameterQ]
        
        let _ = taskForGetMethod(apiPath: Constants.Apixu.Paths.aPIPathCurrent, parameters:parameters as [String : AnyObject]) { (results, nsError) in
            
            if let error = nsError {
                completionHandlerForGetCurrentWeather(false,nil,error.localizedDescription)
            }else{
                if results != nil {
                    let currentDayObject = self.parseCurrentWetherResults(results: results! as! [String : AnyObject])
                    completionHandlerForGetCurrentWeather(true, currentDayObject,nil)
                }else{
                    print("Error: Unable to Find all keys from the Response Body for current Weather)")
                    completionHandlerForGetCurrentWeather(false, nil , "Unable to get current weather")
                }
                
            }
            
            
        }
    }
    
    private func parseCurrentWetherResults(results : [String : AnyObject]) -> CurrentDay?{
        
        
            if let location = results[Constants.ApixuResponseKeys.location] as? [String : AnyObject],
                let current = results[Constants.ApixuResponseKeys.current] as? [String : AnyObject]{
                let name = location[Constants.ApixuResponseKeys.Location.name] as! String
                let temp_c = current[Constants.ApixuResponseKeys.Current.temp_c] as! Float
                let is_day = current[Constants.ApixuResponseKeys.Current.is_day] as! Bool
                if let condition = current[Constants.ApixuResponseKeys.Current.condition] as? [String : AnyObject]{
                    let weatherDescription = condition[Constants.ApixuResponseKeys.Current.Condition.text] as! String
                    let weatherIconUrlString = condition[Constants.ApixuResponseKeys.Current.Condition.icon] as! String
                    let currentDayObject = CurrentDay(cityName: name, weatherDescription: weatherDescription, tempString: temp_c, is_day: is_day, weatherIconUrlString: weatherIconUrlString)
                    
                    return currentDayObject
                }
            }
        
        return nil
        
    }
    
}
