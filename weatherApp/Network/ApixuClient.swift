//
//  ApixuClient.swift
//  weatherApp
//
//  Created by PS Shortcut on 21/08/2018.
//  Copyright © 2018 PS Shortcut. All rights reserved.
//

import UIKit

class ApixuClient{
    
    static let shared = ApixuClient()
    var session = URLSession.shared
    
    //typealias completion = (_ results :AnyObject? ,_ error: NSError?) -> Void
    
    func taskForGetMethod(apiPath : String,parameters :[String : AnyObject], completionHandlerForTskGetMethod:@escaping (_ results :AnyObject? ,_ error: NSError?) -> ()){
        
        var parameters = parameters
        parameters[Constants.ApixuParameterKeys.apiKey] = Constants.ApixyParameterValues.aPIKeyValue as AnyObject 

        let request = NSMutableURLRequest(url: apixuURLfromParameterrs(apiPath: apiPath, parameters: parameters ))
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func displayError(errorString:String){
                print(errorString)
                let userInfo = [NSLocalizedDescriptionKey : errorString]
                completionHandlerForTskGetMethod(nil,NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else{
                displayError(errorString: error!.localizedDescription)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else{
                print(response as Any)
                displayError(errorString: "The response returned a statusCode different from 2xx. Error : \(error!.localizedDescription)")
                return
            }
            
            guard let data = data else {
                displayError(errorString: "The request returned no Data")
                return
            }
            
            
            self.convertDataToJSON(data: data, completionHandlerForConvertingDataToJSON: completionHandlerForTskGetMethod)
            
            
        }
        task.resume()
    }
    
    /// Returns the URL for the call on internet
     fileprivate func apixuURLfromParameterrs(apiPath : String, parameters : [String : AnyObject]) -> URL{
        
        var components = URLComponents()
        components.scheme = Constants.Apixu.aPIScheme
        components.host = Constants.Apixu.aPIHost
        components.path = "\(apiPath)"
        
        components.queryItems = [URLQueryItem]()
        
        for (key,value) in parameters{
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems?.append(queryItem)
        }
        
        return components.url!
    }
    
    private func convertDataToJSON(data:Data , completionHandlerForConvertingDataToJSON: @escaping (_ results : AnyObject?, _ error : NSError?)->()){
        
        var parsedResults :AnyObject! = nil
        do{
            parsedResults = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        }catch{
            let userInfo = [NSLocalizedDescriptionKey: error.localizedDescription]
            completionHandlerForConvertingDataToJSON(nil,NSError(domain: "convertDataToJSON", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertingDataToJSON(parsedResults,nil)
        
    }
    
    
    
    
}
