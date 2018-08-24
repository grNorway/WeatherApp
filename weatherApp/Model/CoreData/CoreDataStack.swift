//
//  CoreDataStack.swift
//  weatherApp
//
//  Created by PS Shortcut on 23/08/2018.
//  Copyright © 2018 PS Shortcut. All rights reserved.
//

// Core Data Stack


import Foundation
import CoreData


class CoreDataStack {
    
    //MARK: - Persistent Container
    let persistenContainer : NSPersistentContainer
    
    //MARK: - View Context
    var viewContext : NSManagedObjectContext {
        return persistenContainer.viewContext
    }
    
    //MARK: - BackgroundContext
    var backgroundContext : NSManagedObjectContext!
    
    //MARK: - Initializer
    init(modelName:String){
        persistenContainer = NSPersistentContainer(name: modelName)
    }
    
    //MARK: - ConfigureContexts
    /// Configures the context and sets the merge Policy
    private func configureContexts(){
        backgroundContext = persistenContainer.newBackgroundContext()
        
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        //Set merge policy
        viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        backgroundContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    }
    
    /// Loads the persistentStores
    func load(completion: (() -> ())? = nil){
        
        persistenContainer.loadPersistentStores { (storeDescription, error) in
            
            guard error == nil else{
                fatalError("Unable to load peristent container. Error : \(error!.localizedDescription)")
            }
            self.configureContexts()
            completion?()
            
        }
    }
    
    /// Saves the viewContext
    func saveViewContext(){
        if viewContext.hasChanges{
            do{
                try viewContext.save()
                print("ViewContext Saved")
            }catch{
                fatalError("ViewContext Save Error : \(error)     Error Message: \(error.localizedDescription)")
            }
        }
    }
    
    /// Saves the backgroudContext
    func saveBackgroundContext(){
        
        if backgroundContext.hasChanges{
            
            do{
                try backgroundContext.save()
            }catch{
                fatalError("backgroundContext Save Error : \(error)     Error Message: \(error.localizedDescription)")
            }
            
        }
    }
    
    
    
}

extension CoreDataStack {
    
    func setupFetchRequest(objectName: String ,sortingKey : String , ascending: Bool ,predicate : String? , arg : NSManagedObject?) -> NSFetchRequest<NSFetchRequestResult>{
    
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: objectName)
        let sortDescriptor = NSSortDescriptor(key:sortingKey,ascending : ascending)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if predicate == nil {
            return fetchRequest
        }else{
            let predicate = NSPredicate(format: predicate!, arg!)
            fetchRequest.predicate = predicate
            return fetchRequest
        }
    }
    
    func setupFetchResultsController(fetchRequest : NSFetchRequest<NSFetchRequestResult> , context: NSManagedObjectContext ) -> NSFetchedResultsController<NSFetchRequestResult>{
        
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchResultsController
        
    }
    
}





