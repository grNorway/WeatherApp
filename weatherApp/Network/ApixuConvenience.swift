//
//  ApixuConvenience.swift
//  weatherApp
//
//  Created by PS Shortcut on 21/08/2018.
//  Copyright © 2018 PS Shortcut. All rights reserved.
//

import UIKit

extension ApixuClient{
    
     func getCurrentWeather(location:String,completionHandlerForGetCurrentWeather : @escaping (_ success : Bool , _ results:[String:AnyObject]? , _ error:String?) -> ()){
        
         
        
        let _ = taskForGetMethod(apiPath: Constants.Apixu.Paths.aPIPathCurrent, parameters:nil) { (results, nsError) in
            
            guard nsError == nil else{
                completionHandlerForGetCurrentWeather(false , nil , nsError?.localizedDescription)
                return
            }
            
            completionHandlerForGetCurrentWeather(true,results! as! [String : AnyObject],nil)
        }
    }
    
}
