//
//  Created by Егор on 13.08.2020.
//  Copyright © 2020 Егор. All rights reserved.
//
//

import Foundation
import CoreData


extension WeatherEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeatherEntity> {
        return NSFetchRequest<WeatherEntity>(entityName: "WeatherEntity")
    }

    @NSManaged public var country: String?
    @NSManaged public var dt: Float
    @NSManaged public var dt_txt: String?
    @NSManaged public var feels_like: Float
    @NSManaged public var humidity: Float
    @NSManaged public var name: String?
    @NSManaged public var pressure: Float
    @NSManaged public var sunrise: Float
    @NSManaged public var sunset: Float
    @NSManaged public var temp: Float
    @NSManaged public var temp_max: Float
    @NSManaged public var temp_min: Float
    @NSManaged public var timezone: Float
    @NSManaged public var weatherRelation: DetailedWeatherEntity?
    @NSManaged public var creationDate: NSDate
}
