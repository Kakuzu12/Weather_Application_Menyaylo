//
//  Created by Егор on 25.07.2020.
//  Copyright © 2020 Егор. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Core Data stack
    private var converter: WeatherModelConverterInput!
    static let sharedManager = AppDelegate()
    private override init() {} // Prevent clients from creating another instance.
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Weather_app")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = AppDelegate.sharedManager.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    // MARK: - WeatherEntityCreationAndSave
    func saveWeatherEntity(model: WeatherModel) -> WeatherEntity {
        converter = WeatherModelConverter()
        let weatherEntity = converter.convert(weatherModel: model)
        self.saveContext()
        
        return weatherEntity
    }
    
    func saveDetailedWeatherEntity(model: Weather) -> DetailedWeatherEntity {
        converter = WeatherModelConverter()
        let detailedWeatherEntity = converter.convertWeather(weatherModel: model)
        self.saveContext()
        
        return detailedWeatherEntity
    }
    
    func checkRecordDuplicate(name: String?) -> Bool {
        let context = AppDelegate.sharedManager.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WeatherEntity")
        
        fetchRequest.predicate = NSPredicate(format: "name == %@", name!)
        var results: [NSManagedObject] = []
        
        do {
            results = try context.fetch(fetchRequest)
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        return results.count > 1
    }
    // MARK: - CoreDataManipulation
    func delete(weatherEntity : WeatherEntity){
        let managedContext = AppDelegate.sharedManager.persistentContainer.viewContext
        managedContext.delete(weatherEntity)
        
        do {
            try managedContext.save()
        } catch {
            print("error")
        }
    }
    
    private func fetchAllCities() -> [WeatherEntity]?{
        let managedContext = AppDelegate.sharedManager.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WeatherEntity")
        
        do {
            let weatherEntity = try managedContext.fetch(fetchRequest)
            return weatherEntity as? [WeatherEntity]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    func update() {
            let networkManager = WeatherNetworkManager()
            let weatherEntityArray = self.fetchAllCities()
            for i in 0..<weatherEntityArray!.count{
                networkManager.fetchCurrentWeatherForUpdate(city: weatherEntityArray?[i].name ?? "", weatherEntity: weatherEntityArray?[i])
            }
    }
    // MARK: - FetchedResultsControllerCreation
    lazy var fetchedResultsController: NSFetchedResultsController<WeatherEntity> = {
        let managedContext = AppDelegate.sharedManager.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<WeatherEntity>(entityName: "WeatherEntity")
        
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultsController = NSFetchedResultsController<WeatherEntity>(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
}

