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
    
    enum ErrorTitles {
        static let NetworkError = "Network Error"
        static let Internal_Error = "Internal Error"
    }
    
    //MARK: - ErrorMessages
    
    enum ErrorMessages{
        static let Internal_Error = "The was an Internal Error. Please contact the customer Support."
    }
    
    struct Errors{
        
        struct ErrorTitles {
            static let NetworkError = "Network Error"
            static let Internal_Error = "Internal Error"
        }
        
        struct ErrorMessages{
            static let Internal_Error = "The was an Internal Error. Please contact the customer Support."
        }
    }
    
    
    
    func showAlert(title: String , msg : String){
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(action)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
}
