//
//  SearchAddLocationViewController.swift
//  weatherApp
//
//  Created by PS Shortcut on 22/08/2018.
//  Copyright © 2018 PS Shortcut. All rights reserved.
//

import UIKit

class SearchAddLocationViewController: UIViewController {

    //MARK: - Outlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    
    var locations : [Location] = []
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.setShowsCancelButton(true, animated: true)
        
    }


    
}

//MARK: - UISearchBarDelegate

extension SearchAddLocationViewController : UISearchBarDelegate{
    
    // Cancel Button Pressed
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true) {
            print(" SearchAddLocationViewcontroller Dismissed")
        }
    }
    
    // Starts Editing
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        ApixuClient.shared.getSearchLocations(parameterQ: searchText) { (success, results, errorString) in
            
            if let results = results{
                self.locations = results
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }else{
                print("Error Search Bar: \(String(describing: errorString)) ")
                DispatchQueue.main.async {
                    self.showAlert(title: ErrorTitles.NetworkError, msg: errorString!)
                }
                
            }
            
        }
    }
    
    // End Editing
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("Ended Editing")
    }
    
    
    
}

extension SearchAddLocationViewController : UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationNameCell", for: indexPath)
        
        cell.textLabel?.text = locations[indexPath.row].name
        
        return cell
        
    }
}

extension SearchAddLocationViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath){
            if let locationName = cell.textLabel?.text{
                let locationUserInfo : [String : String] = ["LocationName" : locationName]
                NotificationCenter.default.post(name: .locationDidSelected, object: nil, userInfo: locationUserInfo)
                dismiss(animated: true, completion: nil)
                
            }
        }
        
        
        
        
    }
    
}


