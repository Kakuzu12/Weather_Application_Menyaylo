//
//  Weather_appTests.swift
//  Weather_appTests
//
//  Created by Егор on 01.08.2020.
//  Copyright © 2020 Егор. All rights reserved.
//

import XCTest
@testable import Weather_app

class Weather_appTests: XCTestCase {
    
    private var currentWeather: WeatherNetworkManager!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        currentWeather = WeatherNetworkManager()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        currentWeather = nil
        super.tearDown()
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
        
    }
}

