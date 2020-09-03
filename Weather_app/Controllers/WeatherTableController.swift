//
//  Created by Егор on 24.08.2020.
//  Copyright © 2020 Егор. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

final class WeatherTableController: UIViewController, CLLocationManagerDelegate {
    //MARK: - ConstantsAndVariables
    private let networkManager = WeatherNetworkManager()
    private var locationManager = CLLocationManager()
    private let tableView = UITableView()
    private var safeArea: UILayoutGuide!
    private var latitude : CLLocationDegrees!
    private var longitude: CLLocationDegrees!
    private let refreshControl = UIRefreshControl()
    
    private enum Locals {
        static let cellID = "cell"
        static let cellHeight: CGFloat = 70
        static let numberOfSections: Int = 1
    }
    // MARK: - ViewControllerLifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAllCities()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Weather"
        
        tableView.delegate = self
        tableView.dataSource = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //self.scrollViewDidEndDragging(tableView, willDecelerate: true)
        view.backgroundColor = .systemBackground
        self.navigationItem.rightBarButtonItem = setupButton()
        safeArea = view.layoutMarginsGuide
        setupTableView()
    }
    
    //MARK: - Handlers
    @objc private func handleAddPlaceButton() {
        let alertController = UIAlertController(title: "Add City", message: "Write down your city", preferredStyle: .alert)
        alertController.view.accessibilityIdentifier = "alert"
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "City Name"
            textField.accessibilityIdentifier = "textField"
        }
        let saveAction = UIAlertAction(title: "Add", style: .default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            guard let cityname = firstTextField.text else { return }
            self.loadData(city: cityname)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action : UIAlertAction!) -> Void in
            print("Cancel")
        })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    //MARK: - RefreshSetup
    @objc private func refreshPulled() {
        self.refreshControl.customBeginRefreshing(refreshControl: self.refreshControl)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [refreshControl] in
            AppDelegate.sharedManager.update()
            refreshControl.customEndRefreshing(refreshControl: refreshControl)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                print("me")
                self.tableView.reloadData()
            }
        }
    }
    //MARK: - DataLoading
    private func loadData(city: String){
        networkManager.fetchCurrentWeather(city: city) { (weather) in
            DispatchQueue.main.async {
                let weatherEntity = AppDelegate.sharedManager.saveWeatherEntity(model: weather)
                let duplicateCheck = AppDelegate.sharedManager.checkRecordDuplicate(name: weatherEntity.name)
                if duplicateCheck == false {
                    let detailedWeatherEntity = AppDelegate.sharedManager.saveDetailedWeatherEntity(model: weather.weather[0])
                    weatherEntity.weatherRelation = detailedWeatherEntity
                    AppDelegate.sharedManager.saveContext()
                    self.tableView.reloadData()
                }else{
                    AppDelegate.sharedManager.delete(weatherEntity: weatherEntity)
                    self.tableView.reloadData()
                    let alertController = UIAlertController(title: "Warning", message: "Sorry but such location aldready exists!", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: { (action : UIAlertAction!) -> Void in
                    })
                    
                    alertController.addAction(okAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func loadDataUsingCoordinates(lat: String, lon: String) {
        networkManager.fetchCurrentLocationWeather(lat: lat, lon: lon) { (weather) in
            DispatchQueue.main.async {
                if self.tableView.visibleCells.isEmpty {
                    let weatherEntity = AppDelegate.sharedManager.saveWeatherEntity(model: weather)
                    let detailedWeatherEntity = AppDelegate.sharedManager.saveDetailedWeatherEntity(model: weather.weather[0])
                    weatherEntity.weatherRelation = detailedWeatherEntity
                    AppDelegate.sharedManager.saveContext()
                    self.tableView.reloadData()
                } else {
                }
            }
        }
    }
    //MARK: - LocationManager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        manager.delegate = nil
        let location = locations[0].coordinate
        latitude = location.latitude
        longitude = location.longitude
        loadDataUsingCoordinates(lat: latitude.description, lon: longitude.description)
    }
    //MARK: - UIViewSetup
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Locals.cellID)
        tableView.tableFooterView = UIView(frame: .zero)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        refreshControl.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        refreshControl.backgroundColor = UIColor.clear
    }
    
    private func setupButton() -> UIBarButtonItem{
        let plusCircleButton = UIBarButtonItem(image: UIImage(systemName: "plus.circle"), style: .done, target: self, action: #selector(handleAddPlaceButton))
        plusCircleButton.accessibilityIdentifier = "plusCircleButton"
        return plusCircleButton
    }
    //MARK: - CoreDataManipulation
    private func delete(weatherEntity : WeatherEntity){
        AppDelegate.sharedManager.delete(weatherEntity: weatherEntity)
    }
    
    private func fetchAllCities(){
        AppDelegate.sharedManager.fetchedResultsController.delegate = self
        do{
            try AppDelegate.sharedManager.fetchedResultsController.performFetch()
        }catch{
            print(error)
        }
    }
}
//MARK: - TableViewConfiguration
extension WeatherTableController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        guard let sections = AppDelegate.sharedManager.fetchedResultsController.sections else {
            return 0
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let weatherEntity = AppDelegate.sharedManager.fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: Locals.cellID,
                                                 for: indexPath)
        cell.textLabel?.text = (" \(weatherEntity.name ?? ""), \(weatherEntity.country ?? "")")
        if indexPath.row == 0{
            cell.backgroundColor = .lightGray
        } else{
            cell.backgroundColor = .white
        }
        
        let tempSymbol = UIImageView.init(frame: CGRect(x:147,y:2,width:50,height:50))
        tempSymbol.loadImageFromURL(url: "https://openweathermap.org/img/wn/\( weatherEntity.weatherRelation?.icon ?? "13n")@2x.png")
        let smallView = UIView.init(frame: CGRect(x:0,y:0,width:200,height:56))
        let label = UILabel.init(frame: CGRect(x:73,y:18,width:100,height:20))
        
        label.text = ("\(weatherEntity.temp.kelvinToCeliusConverter())°C")
        smallView.addSubview(label)
        smallView.addSubview(tempSymbol)
        cell.accessoryView = smallView
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Locals.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Locals.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController: WeatherLocationController = WeatherLocationController()
        let weatherEntity = AppDelegate.sharedManager.fetchedResultsController.object(at: indexPath)
        viewController.delegate = self
        viewController.loadData(city: weatherEntity.name ?? "")
        viewController.getRow(row: indexPath.row)
        self.navigationController?.pushViewController(viewController,animated: false)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.row == 0){
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete){
            tableView.beginUpdates()
            let weatherEntity = AppDelegate.sharedManager.fetchedResultsController.object(at: indexPath)
            self.delete(weatherEntity: weatherEntity)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.right)
            tableView.endUpdates()
        }
    }
}

//MARK: - TableViewExtensions
extension WeatherTableController : NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch (type) {
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
            }
            break;
            
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .move:
            break;
        case .update:
            break;
        @unknown default:
            print("Unknown case")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

extension WeatherTableController: DeleteRowInTableviewDelegate {
    
    func deleteRow(inTableview rowToDelete: Int) {
        DispatchQueue.main.async{
            self.tableView.beginUpdates()
            if (rowToDelete != 0){
                let weatherEntity = AppDelegate.sharedManager.fetchedResultsController.object(at: IndexPath(row: rowToDelete, section
                    : 0))
                self.delete(weatherEntity: weatherEntity)
                
                self.tableView.deleteRows(at: [IndexPath(row: rowToDelete, section: 0)], with: .automatic)
                
            }else{
                
                let alertController = UIAlertController(title: "Warning", message: "Unfortunately you are not allowed to delete current location!", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: { (action : UIAlertAction!) -> Void in
                })
                
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
            self.tableView.endUpdates()
        }
    }
}
