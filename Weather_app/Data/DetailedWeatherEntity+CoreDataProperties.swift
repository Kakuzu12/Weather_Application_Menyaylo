//
//  Created by Егор on 13.08.2020.
//  Copyright © 2020 Егор. All rights reserved.
//
//

import Foundation
import CoreData


extension DetailedWeatherEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DetailedWeatherEntity> {
        return NSFetchRequest<DetailedWeatherEntity>(entityName: "DetailedWeatherEntity")
    }

    @NSManaged public var definition: String?
    @NSManaged public var icon: String?
    @NSManaged public var id: Float
    @NSManaged public var main: String?
    @NSManaged public var weatherRelation: WeatherEntity?

}
