//
//  Created by Егор on 24.08.2020.
//  Copyright © 2020 Егор. All rights reserved.
//

import Foundation
//MARK: - TableViewCellStructure
private struct TableViewCellModel: Codable {
    private let name: String
    private let country: String
    
    init(name: String, country: String) {
        self.name = name
        self.country = country
    }
    
    var nameValue: String {
        return name
    }
    var countryValue: String {
        return country
    } 
}
