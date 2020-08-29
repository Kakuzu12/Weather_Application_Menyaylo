//
//  Created by Егор on 29.08.2020.
//  Copyright © 2020 Егор. All rights reserved.
//

import UIKit
//MARK: - FetchForUpdateProtocol
protocol NetworkManagerForUpdateProtocol {
    func fetchCurrentWeatherForUpdate(city: String, weatherEntity: WeatherEntity?)
}
