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
    
    private var locations : [Location] = []
    var coreDataStack : CoreDataStack!
    
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.setShowsCancelButton(true, animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupSearchBar()
    }
    
    fileprivate func setupSearchBar() {
        searchBar.becomeFirstResponder()
        searchBar.barTintColor = UIColor.clear
        searchBar.backgroundColor = UIColor.clear
        searchBar.isTranslucent = true
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        tableView.backgroundColor = UIColor.clear
    }


    
}

//MARK: - UISearchBarDelegate

extension SearchAddLocationViewController : UISearchBarDelegate{
    
    // Cancel Button Pressed
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationController?.popViewController(animated: true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("Started")
    }
    
    
    
    
    //MARK: - SearchBar
    /// Returns a string when text Change in SearchBar and call the getSearchLocations to return the possible locations
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        print(searchText)
        if searchText == "" {
            return
        }
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
    
    
}

//MARK: - UITableViewDataSource
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

//MARK: - UITableViewDelegate
extension SearchAddLocationViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let locationSelected = locations[indexPath.row]
        let fetchRequest = coreDataStack.setupFetchRequest(objectName: "LocationCurrentWeatherObject", sortingKey: "locationID", ascending: true, predicate: "locationID == %i", arg: locationSelected.locationID )
        
        do{
            let results = try coreDataStack.viewContext.fetch(fetchRequest)
            let resultsLocations = results as! [LocationCurrentWeatherObject]
            
            if resultsLocations.count != 0 {
                print("The location Exists")
                self.dismiss(animated: true, completion: nil)
                return
            }
        }catch{
            print("Error fetch TableViewDidSelectRow: \(error) msg: \(error.localizedDescription)")
        }
        
        print("Tapped")
        ApixuClient.shared.getCurrentWeatherAndForecast(parameterQ: locationSelected.name,locationID:locationSelected.locationID, days: 1) { (success, errorString) in
            if success{
                print("success")
            }else{
                print(errorString!)
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
    
}


