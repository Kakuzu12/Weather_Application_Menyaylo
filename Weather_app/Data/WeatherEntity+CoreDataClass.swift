//
//  Created by Егор on 13.08.2020.
//  Copyright © 2020 Егор. All rights reserved.
//
//

import Foundation
import CoreData

@objc(WeatherEntity)
public class WeatherEntity: NSManagedObject {
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        self.creationDate = Date() as NSDate
    }
}
