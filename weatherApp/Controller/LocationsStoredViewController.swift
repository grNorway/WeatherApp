//
//  LocationsStoredViewController.swift
//  weatherApp
//
//  Created by PS Shortcut on 22/08/2018.
//  Copyright © 2018 PS Shortcut. All rights reserved.
//


import UIKit
import CoreData

class LocationsStoredViewController: UIViewController{

    //MARK: - Segues
    
    private enum Segues{
        static let AddLocation = "AddLocation"
        static let WeatherForecast = "WeatherForecast"
    }
    
    //MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    //MARK: - Core Data Properties
    
    private var fetchResultsController : NSFetchedResultsController<LocationCurrentWeatherObject>!
    private var fetchRequest : NSFetchRequest<NSFetchRequestResult>!
    var coreDataStack : CoreDataStack!
    
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Locations"
        tableView.backgroundColor = UIColor.clear
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupFetchRequest()
        
        performFetch()
        
    }

    
    //MARK: - Functions
    
    fileprivate func setupFetchRequest() {
        fetchRequest = coreDataStack.setupFetchRequest(objectName: "LocationCurrentWeatherObject", sortingKey: "creationDate", ascending: true, predicate: nil, arg: nil)
        fetchResultsController = (coreDataStack.setupFetchResultsController(fetchRequest: fetchRequest, context: coreDataStack.viewContext) as! NSFetchedResultsController<LocationCurrentWeatherObject>)
        
        fetchResultsController.delegate = self
    }
    
    fileprivate func performFetch() {
        do{
            try fetchResultsController.performFetch()
        }catch{
            print("Unable to perform Fetch (FetchResultsController) in LocationStoredViewController")
        }
    }
    
    //MARK: - Actions
    
    @IBAction func addLocation(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Segues.AddLocation, sender: self)
    }
    
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Segues.AddLocation {
            let searchAddLocationViewController = segue.destination as! SearchAddLocationViewController
            searchAddLocationViewController.coreDataStack = self.coreDataStack
        }else if segue.identifier == Segues.WeatherForecast{
            let weatherForecastViewController = segue.destination as! WeatherForecastViewController
            if let locationName = sender as? String {
                weatherForecastViewController.locationName = locationName
            }
        }
        
    }
    

}

//MARK: - UITableViewDelegate
extension LocationsStoredViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let locationSelected = fetchResultsController.object(at: indexPath)
        if let locationName = locationSelected.locationName {
            performSegue(withIdentifier: "WeatherForecast", sender: locationName)
        }else{
            self.showAlert(title: ErrorTitles.Internal_Error, msg: ErrorMessages.Internal_Error)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}

//MARK: - UITableViewDataSource

extension LocationsStoredViewController : UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationStoredTableViewCell.identifier, for: indexPath) as! LocationStoredTableViewCell
        
        let locationObject = fetchResultsController.object(at: indexPath)
        cell.configureCell(weatherData: locationObject)

        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let objectToDelete = fetchResultsController.object(at: indexPath)
            coreDataStack.viewContext.delete(objectToDelete)
            coreDataStack.saveViewContext()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    
    
}

//MARK: - NSFetchedResultsControllerDelegate
extension LocationsStoredViewController : NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let index = IndexSet(integer: sectionIndex)
        
        switch type{
        case .insert:
            tableView.insertSections(index, with: .fade)
        case .delete:
            tableView.deleteSections(index, with: .fade)
        case .update,.move:
            print("Error : No allowed types .update , .move on tableView")
        }
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type{
        case .insert :
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}


