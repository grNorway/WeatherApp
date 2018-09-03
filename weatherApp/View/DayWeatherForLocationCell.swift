//
//  DayWeatherForLocationCell.swift
//  weatherApp
//
//  Created by PS Shortcut on 29/08/2018.
//  Copyright © 2018 PS Shortcut. All rights reserved.
//

import UIKit

class DayWeatherForLocationCell: UITableViewCell {

    @IBOutlet weak var dayName: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var maxTemp_Clabel: UILabel!
    @IBOutlet weak var minTemp_Clabel: UILabel!

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(dayPrediction : DayPrediction){
        DispatchQueue.main.async {
            
            
            self.selectionStyle = .none
            self.backgroundColor = UIColor.white.withAlphaComponent(0.4)
            self.dayName.text = self.getDayNameFromWeek(dateIn: dayPrediction.date)
            let maxTempItn = Int(dayPrediction.maxTemp_c)
            self.maxTemp_Clabel.text = "\(maxTempItn)"
            let minTempInt = Int(dayPrediction.minTemp_c)
            self.minTemp_Clabel.text = "\(minTempInt)"
            self.downloadIconData(iconStringURL: dayPrediction.iconStringURL) { (data, errorString) in
                if errorString != nil {
                    //TODO: - Error UIImage()
                }else{
                    guard let data = data else{
                        //TODO: - Error UIImage()
                        return
                    }
                    DispatchQueue.main.async {
                        self.iconImage.image = UIImage(data: data)
                    }
                    
                }
            }
        }
        
    }
    
    private func getDayNameFromWeek(dateIn : Date) -> String{
        
        let dayName = Calendar.current.component(.weekday, from: dateIn)
        switch dayName{
        case 1:
            return "Sunday"
        case 2:
            return "Monday"
        case 3:
            return "Tuesday"
        case 4:
            return "Wednesday"
        case 5:
            return "Thursday"
        case 6:
            return "Friday"
        default:
            return "Saturday"
        }
    }
    
    private func downloadIconData(iconStringURL:String, completionHandlerForDownloadIconData: @escaping (_ iconData:Data?,_ errorString: String?) -> ()){
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
