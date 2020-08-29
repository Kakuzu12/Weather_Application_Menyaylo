
//
//  Created by Егор on 25.07.2020.
//  Copyright © 2020 Егор. All rights reserved.
//

import UIKit
//MARK: - WeatherFetchProtocol
protocol NetworkManagerProtocol {
    func fetchCurrentWeather(city: String, completion: @escaping (WeatherModel) -> ())
    func fetchCurrentLocationWeather(lat: String, lon: String, completion: @escaping (WeatherModel) -> ())
    func fetchNextFiveWeatherForecast(city: String, completion: @escaping ([ForecastTemperature]) -> ())
}

