//
//  WeatherForecastViewController.swift
//  weatherApp
//
//  Created by PS Shortcut on 21/08/2018.
//  Copyright © 2018 PS Shortcut. All rights reserved.
//


import UIKit
import CoreLocation
import CoreData

class WeatherForecastViewController: UIViewController {

    //MARK: - Segues
    
    private enum Segues{
        static let showStoredLocations = "showStoredLocations"
    }
    
    //MARK: - Properties
    
    
    var locationName : String!
    
    private var daysArray : [DayPrediction]!
    private var currentDay : DayPrediction!
    private var getForecastToken:Int = 0
    
    //MARK: - Outlets
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentWeatherViewBackgroundIsDay: UIView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    @IBOutlet weak var maxTemp_cLabel: UILabel!
    @IBOutlet weak var minTemp_Clabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var spiner: UIActivityIndicatorView!
    @IBOutlet weak var currentWeatherView: UIView!
    
    
    
    //MARK: - life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView(areDataLoaded: false)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getForecastToken += 1
        let localForecastToken = self.getForecastToken
        ApixuClient.shared.getForecast(parameterQ: locationName, days: 10) { (success,daysArrayPrediction, errorString) in
            
            if localForecastToken != self.getForecastToken {
                return
            }
            
            guard errorString == nil else{
                self.showAlert(title: Errors.ErrorTitles.NetworkError, msg: errorString!)
                return
            }
            
            print("We have success : \(success)")
            self.currentDay = daysArrayPrediction![0]
            self.daysArray = daysArrayPrediction!
            
            self.daysArray = Array(self.daysArray!.dropFirst())
            print("Days For TableView : \(self.daysArray!.count)")
            
            //TODO: - UpdateUI
            DispatchQueue.main.async {
                self.setupView(areDataLoaded: true)
                self.tableView.reloadData()
            }
            
        }
        
    }
    
    deinit {
        print("deinit")
    }

    //MARK: - Functions
    //TODO: - Make it better
    private func setupView(areDataLoaded : Bool){
        currentWeatherView.isHidden = !areDataLoaded
        tableView.isHidden = !areDataLoaded
        backgroundImage.image = UIImage(named: "WeatherImage")
        tableView.backgroundColor = UIColor.clear
        guard areDataLoaded != false else{
            spiner.activityIndicatorViewStyle = .whiteLarge
            spiner.color = .black
            spiner.startAnimating()
            return
        }
        spiner.stopAnimating()
        spiner.removeFromSuperview()
        tableView.backgroundColor = .clear
        self.updateCurrentWeatherView(dayPrediction: self.daysArray![0])
        
    }
    
    /// it updates the currentWeatherView with data from DayPrediction [0] which is the day today
    private func updateCurrentWeatherView(dayPrediction:DayPrediction){
        cityNameLabel.text = locationName
        weatherDescription.text = dayPrediction.weatherDescription
        maxTemp_cLabel.text = "Max:\(Int(dayPrediction.maxTemp_c))"
        minTemp_Clabel.text = "Min:\(Int(dayPrediction.minTemp_c))"
        
        downloadIconData(iconStringURL: dayPrediction.iconStringURL) { (data, errorString) in
            
            guard errorString == nil else{
                
                self.iconImage.image = UIImage(named: "error")
                return
            }
            
            guard let data = data else{
                self.iconImage.image = UIImage(named: "error")
                return
            }
            
            DispatchQueue.main.async {
                self.iconImage.image = UIImage(data: data)
                
            }
        }
    }

    
}


//MARK: - UITableViewDataSource
extension WeatherForecastViewController : UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daysArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let day = daysArray![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayWeatherCell", for: indexPath) as! DayWeatherForLocationCell
       
        cell.configureCell(dayPrediction: day)
        
        return cell
    }
    
}




