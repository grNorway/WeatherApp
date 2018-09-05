//
//  UIViewControllerExtension.swift
//  weatherApp
//
//  Created by PS Shortcut on 23/08/2018.
//  Copyright © 2018 PS Shortcut. All rights reserved.
//

import UIKit

extension UIViewController  {
    
    //MARK: - ErrorTitles
    
    
    struct Errors{
        
        struct ErrorTitles {
            static let NetworkError = "Network Error"
            static let Internal_Error = "Internal Error"
            static let SpeechError = "Error"
        }
        
        struct ErrorMessages{
            static let Internal_Error = "There was an Internal Error. Please contact the customer Support."
            static let SpeechRecognizerErrorNotAvailable = "Speech Recognition is not avaialble. Please try later or contact customer support"
            static let SpeechRecognitionErrorLocale = "Speech Recognition is not supported"
        }
    }
    
    
    //MARK: - ShowAlertController
    func showAlert(title: String , msg : String){
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(action)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    //MARK: - downloadIconData
    ///Downloads data for a image URL
    func downloadIconData(iconStringURL:String, completionHandlerForDownloadIconData: @escaping (_ iconData:Data?,_ errorString: String?) -> ()){
        let iconPath = String(format: "https:%@", iconStringURL.replacingOccurrences(of: "//", with: "", options: NSString.CompareOptions.literal, range: nil))
        
        guard let iconURL = URL(string: iconPath) else{
            completionHandlerForDownloadIconData(nil,"Internal error: Unable to load icon . URL")
            return
        }
        
        let request : URLRequest = URLRequest(url: iconURL)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard error == nil else {
                completionHandlerForDownloadIconData(nil,"Error: \(String(describing: error?.localizedDescription))")
                return
            }
            
            guard let data = data else {
                completionHandlerForDownloadIconData(nil,"Error: No data on Request: \(request)")
                return
            }
            
            completionHandlerForDownloadIconData(data,nil)
        }
        task.resume()
    }
    
}
