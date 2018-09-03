//
//  LocationStoredTableViewCell.swift
//  weatherApp
//
//  Created by PS Shortcut on 24/08/2018.
//  Copyright © 2018 PS Shortcut. All rights reserved.
//

import UIKit

class LocationStoredTableViewCell: UITableViewCell {

    //MARK: - Cell Identitier
    
    static let identifier = "LocationCell"
    
    //MARK: - Outlets
    
    @IBOutlet weak var locationNameLbl: UILabel!
    
    
    //MARK: - Configure the Cell at LocationsStoredViewController
    func configureCell(weatherData : LocationCurrentWeatherObject){
        
        self.locationNameLbl.text = weatherData.locationName
//        self.tempLbl.text = "\(weatherData.avgtemp_c)"
//        if weatherData.isDay{
//            self.backgroundColor = UIColor.clear
//        }else{
//            self.backgroundColor = UIColor.darkGray
//        }
//
//        if weatherData.isCurrentLocation{
//            self.isCurrentLocation.isHidden = false
//        }else{
//            self.isCurrentLocation.isHidden = true
//        }
//        if weatherData.iconWeather == nil {
//        self.icon.isHidden = true
//        }else{
//            self.icon.image = UIImage(data: weatherData.iconWeather!)
//            self.icon.isHidden = false
//        }
        
    }
    

}
