//
//  Created by Егор on 03.08.2020.
//  Copyright © 2020 Егор. All rights reserved.
//

import UIKit
//MARK: - ModelForWeather
struct Weather: Codable {
    let id: Float
    let main: String
    let description: String
    let icon: String
}

struct Main: Codable {
    let temp: Float
    let feels_like: Float
    let temp_min: Float
    let temp_max: Float
    let pressure: Float
    let humidity: Float
}

struct Sys: Codable {
    let country: String?
    let sunrise: Float?
    let sunset: Float?
}

struct WeatherModel: Codable {
    let weather: [Weather]
    let main: Main
    let sys: Sys
    let name: String?
    let dt: Float
    let timezone: Float?
    let dt_txt: String?
}

struct ForecastModel: Codable {
    var list: [WeatherModel]
    let city: City
}

struct City: Codable {
    let name: String?
    let country: String?
    
}
