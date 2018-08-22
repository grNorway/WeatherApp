//
//  ViewController.swift
//  weatherApp
//
//  Created by PS Shortcut on 21/08/2018.
//  Copyright © 2018 PS Shortcut. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //MARK: - Properties
    
    var currentWeather : CurrentDay?
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    
    //MARK: - life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ApixuClient.shared.getCurrentWeather(parameterQ: "oslo") { (success, currentDay, errorString) in
            
            if success {
                if currentDay != nil {
                    self.currentWeather = currentDay
                    print(self.currentWeather)
                }
            }else{
                print(errorString!)
            }
            
        }
        
        
    }

    


}

extension ViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}

extension ViewController : UITableViewDelegate {
    
}

