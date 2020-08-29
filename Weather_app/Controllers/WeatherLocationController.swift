//
//  Created by Егор on 25.07.2020.
//  Copyright © 2020 Егор. All rights reserved.
//

import UIKit
import CoreLocation
//MARK: - Protocols
protocol DeleteRowInTableviewDelegate: NSObjectProtocol {
    func deleteRow(inTableview rowToDelete: Int)
}

final class WeatherLocationController: UIViewController {
    //MARK: - ConstantsAndVariables
    private let networkManager = WeatherNetworkManager()
    weak var delegate: DeleteRowInTableviewDelegate?
    private var indexToDelete: Int = 0
    private var currentLoc: CLLocation?
    private var stackView : UIStackView!
    // MARK: - UIElementsSetup
    private let currentLocation: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Location"
        label.textAlignment = .left
        label.textColor = .label
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 38, weight: .heavy)
        return label
    }()
    
    private let currentTime: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Date"
        label.textAlignment = .left
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 10, weight: .heavy)
        return label
    }()
    
    private let currentTemperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "°C"
        label.textColor = .label
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 60, weight: .heavy)
        return label
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Delete", for: .normal)
        button.contentHorizontalAlignment = .center
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        button.layer.borderWidth = 2.0
        button.addTarget(self, action: #selector(backwardTransition), for: .touchUpInside)
        button.backgroundColor = .red
        return button
    }()
    
    private let tempDescription: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "..."
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        return label
    }()
    private let tempSymbol: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(systemName: "cloud.fill")
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        img.tintColor = .gray
        return img
    }()
    
    
    private let maxTemp: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "  °C"
        label.textAlignment = .left
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    private let minTemp: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "  °C"
        label.textAlignment = .left
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    // MARK: - ViewControllerLifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.accessibilityIdentifier = "ViewController"
        
        self.navigationItem.rightBarButtonItems = [createBarItems()[0], createBarItems()[1]]
        
        transparentNavigationBar()
        setupViews()
        layoutViews()
    }
    //MARK: - NavigationBarSetup
    private func createBarItems() -> [UIBarButtonItem] {
        let thermometerButton = UIBarButtonItem(image: UIImage(systemName: "thermometer"), style: .done, target: self, action: #selector(handleShowForecast))
        thermometerButton.accessibilityIdentifier = "thermometerButton"
        let arrowButton = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .done, target: self, action: #selector(handleRefresh))
        arrowButton.accessibilityIdentifier = "arrowButton"
        return [thermometerButton,arrowButton]
    }
    
    private func transparentNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "", style: .plain, target: nil, action: nil)
    }
    //MARK: - DataLoading
    func getRow(row: Int){
        self.indexToDelete = row
    }
    
    func loadData(city: String) {
        networkManager.fetchCurrentWeather(city: city) { (weather) in
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy" 
            let stringDate = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(weather.dt)))
            
            DispatchQueue.main.async {
                self.currentTemperatureLabel.text = (String(weather.main.temp.kelvinToCeliusConverter()) + "°C")
                self.currentLocation.text = "\(weather.name ?? "") , \(weather.sys.country ?? "")"
                self.tempDescription.text = weather.weather[0].description
                self.currentTime.text = stringDate
                self.minTemp.text = ("Min: " + String(weather.main.temp_min.kelvinToCeliusConverter()) + "°C" )
                self.maxTemp.text = ("Max: " + String(weather.main.temp_max.kelvinToCeliusConverter()) + "°C" )
                self.tempSymbol.loadImageFromURL(url: "https://openweathermap.org/img/wn/\(weather.weather[0].icon)@2x.png")
                UserDefaults.standard.set("\(weather.name ?? "")", forKey: "SelectedCity")
            }
        }
    }
    
    private func loadDataUsingCoordinates(lat: String, lon: String) {
        networkManager.fetchCurrentLocationWeather(lat: lat, lon: lon) { (weather) in
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy" //yyyy
            let stringDate = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(weather.dt)))
            
            DispatchQueue.main.async {
                self.currentTemperatureLabel.text = (String(weather.main.temp.kelvinToCeliusConverter()) + "°C")
                self.currentLocation.text = "\(weather.name ?? "") , \(weather.sys.country ?? "")"
                self.tempDescription.text = weather.weather[0].description
                self.currentTime.text = stringDate
                self.minTemp.text = ("Min: " + String(weather.main.temp_min.kelvinToCeliusConverter()) + "°C" )
                self.maxTemp.text = ("Max: " + String(weather.main.temp_max.kelvinToCeliusConverter()) + "°C" )
                self.tempSymbol.loadImageFromURL(url: "https://openweathermap.org/img/wn/\(weather.weather[0].icon)@2x.png")
                UserDefaults.standard.set("\(weather.name ?? "")", forKey: "SelectedCity")
            }
        }
    }
    //MARK: - UIViewSetup
    private func setupViews() {
        view.addSubview(deleteButton)
        view.addSubview(currentLocation)
        view.addSubview(currentTemperatureLabel)
        view.addSubview(tempSymbol)
        view.addSubview(tempDescription)
        view.addSubview(currentTime)
        view.addSubview(minTemp)
        view.addSubview(maxTemp)
    }
    
    private func layoutViews() {
        NSLayoutConstraint.activate([
            deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 120),
            deleteButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -90),
            currentLocation.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            currentLocation.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            currentLocation.heightAnchor.constraint(equalToConstant: 70),
            currentLocation.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            currentTime.topAnchor.constraint(equalTo: currentLocation.bottomAnchor, constant: 4),
            currentTime.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            currentTime.heightAnchor.constraint(equalToConstant: 10),
            currentTime.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            currentTemperatureLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            currentTemperatureLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            currentTemperatureLabel.heightAnchor.constraint(equalToConstant: 70),
            currentTemperatureLabel.widthAnchor.constraint(equalToConstant: 250),
            tempSymbol.topAnchor.constraint(equalTo: currentTemperatureLabel.bottomAnchor),
            tempSymbol.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            tempSymbol.heightAnchor.constraint(equalToConstant: 50),
            tempSymbol.widthAnchor.constraint(equalToConstant: 50),
            tempDescription.topAnchor.constraint(equalTo: currentTemperatureLabel.bottomAnchor, constant: 12.5),
            tempDescription.leadingAnchor.constraint(equalTo: tempSymbol.trailingAnchor, constant: 8),
            tempDescription.heightAnchor.constraint(equalToConstant: 20),
            tempDescription.widthAnchor.constraint(equalToConstant: 250),
            minTemp.topAnchor.constraint(equalTo: tempSymbol.bottomAnchor, constant: 80),
            minTemp.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            minTemp.heightAnchor.constraint(equalToConstant: 20),
            minTemp.widthAnchor.constraint(equalToConstant: 100),
            
            maxTemp.topAnchor.constraint(equalTo: minTemp.bottomAnchor),
            maxTemp.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            maxTemp.heightAnchor.constraint(equalToConstant: 20),
            maxTemp.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    //MARK: - Handlers
    @objc private func backwardTransition() {
        delegate!.deleteRow(inTableview: self.indexToDelete)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleShowForecast() {
        self.navigationController?.pushViewController(ForecastViewController(), animated: true)
    }
    
    @objc private func handleRefresh() {
        let city = UserDefaults.standard.string(forKey: "SelectedCity") ?? ""
        loadData(city: city)
    }
}
