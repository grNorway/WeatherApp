//
//  LocationsStoredViewController.swift
//  weatherApp
//
//  Created by PS Shortcut on 22/08/2018.
//  Copyright © 2018 PS Shortcut. All rights reserved.
//

import UIKit

class LocationsStoredViewController: UIViewController {

    //MARK: - Segues
    
    private enum Segues{
        static let AddLocation = "AddLocation"
    }
    
    //MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(catchNotification(notification:)), name: Notification.Name.locationDidSelected, object: nil)
    }
    
    @objc private func catchNotification(notification:Notification) {
        guard let locationName = notification.userInfo?["LocationName"] as? String else {
            self.showAlert(title: Errors.ErrorTitles.Internal_Error, msg: ErrorMessages.Internal_Error)
            return
        }
        
        ApixuClient.shared.getCurrentWeather(parameterQ: locationName) { (success, currentDay, errorString) in
            
        }
        
        
        
    }

    

    //MARK: - Actions
    
    @IBAction func addLocation(_ sender: UIButton) {
        performSegue(withIdentifier: Segues.AddLocation, sender: self)
    }
    
    
    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Segues.AddLocation{
            
        }
        
    }
    

}

extension LocationsStoredViewController : UITableViewDelegate{
    
}

extension LocationsStoredViewController : UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        
        return UITableViewCell()
    }
}
