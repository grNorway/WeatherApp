//
//  ViewController.swift
//  weatherApp
//
//  Created by PS Shortcut on 21/08/2018.
//  Copyright © 2018 PS Shortcut. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    //MARK: - Segues
    
    private enum Segues{
        static let showStoredLocations = "showStoredLocations"
    }
    
    //MARK: - Properties
    
    var coreDataStack : CoreDataStack!
    var currentWeather : CurrentDay?
    var locationManager : CLLocationManager!
    
    //MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentWeatherViewBackgroundIsDay: UIView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    
    
    
    //MARK: - life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locateMe()
        
        ApixuClient.shared.getCurrentWeather(parameterQ: "oslo") { (success, currentDay, errorString) in
            
            if success {
                print()
                DispatchQueue.main.async {
                    self.updateCurrentWeatherView(currentWeatherObject: currentDay!)
                }
                
            }else{
                print(errorString!)
                DispatchQueue.main.async {
                    self.weatherDescription.text = errorString!
                }
                
            }
            
        }
        
        
    }

    //MARK: - Actions

    private func locateMe(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
    }
    
    
    @IBAction func showLocationStored(_ sender: UIButton) {
        performSegue(withIdentifier: Segues.showStoredLocations, sender: self)
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.showStoredLocations{
            
        }
    }
    
}


//MARK: - UITableViewDataSource
extension ViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}

//MARK: - UITableViewDelegate
extension ViewController : UITableViewDelegate {
    
}


//MARK: - Update the UI
extension ViewController{
    
    //MARK: - UpdateCurrentWeatherView
    
    private func updateCurrentWeatherView(currentWeatherObject: CurrentDay!){
        
        cityNameLabel.text = currentWeatherObject.cityName
        weatherDescription.text = currentWeatherObject.weatherDescription
        tempLabel.text = "\(currentWeatherObject.tempAvgInt)"
        
        
    }
    
}

extension ViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        let coordinates = manager.location?.coordinate
        print(coordinates)

    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }
    
    
}

