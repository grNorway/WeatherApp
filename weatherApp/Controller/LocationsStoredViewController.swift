//
//  LocationsStoredViewController.swift
//  weatherApp
//
//  Created by PS Shortcut on 22/08/2018.
//  Copyright © 2018 PS Shortcut. All rights reserved.
//

import UIKit
import CoreData

class LocationsStoredViewController: UIViewController {

    //MARK: - Segues
    
    private enum Segues{
        static let AddLocation = "AddLocation"
    }
    
    //MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Core Data Properties
    
    var fetchResultsController : NSFetchedResultsController<LocationCurrentWeatherObject>!
    var fetchRequest : NSFetchRequest<NSFetchRequestResult>!
    var coreDataStack : CoreDataStack!
    
    //MARK: - Properties
    
    var dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchRequest = coreDataStack.setupFetchRequest(objectName: "LocationCurrentWeatherObject", sortingKey: "creationDate", ascending: false, predicate: nil, arg: nil)
        fetchResultsController = coreDataStack.setupFetchResultsController(fetchRequest: fetchRequest, context: coreDataStack.viewContext) as! NSFetchedResultsController<LocationCurrentWeatherObject>
        
        fetchResultsController.delegate = self
        
        do{
            try fetchResultsController.performFetch()
        }catch{
            print("Unable to perform Fetch (FetchResultsController) in LocationStoredViewController")
        }
        
    }

    

    //MARK: - Actions
    
    @IBAction func addLocation(_ sender: UIButton) {
        performSegue(withIdentifier: Segues.AddLocation, sender: self)
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    

}

extension LocationsStoredViewController : UITableViewDelegate{
    
}

extension LocationsStoredViewController : UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let locationObject = fetchResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        
        cell.textLabel?.text = locationObject.locationName!
        cell.detailTextLabel?.text = dateFormatter.string(from: locationObject.localTime!)
        
        return cell
    }
}


extension LocationsStoredViewController : NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
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


