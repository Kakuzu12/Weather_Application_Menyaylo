//
//  Weather_app_unit_tests.swift
//  Weather_app_unit_tests
//
//  Created by Егор on 02.09.2020.
//  Copyright © 2020 Егор. All rights reserved.
//

import XCTest
@testable import Weather_app


class Weather_app_unit_tests: XCTestCase {
    
    func testFetchCurrentLocationWeather() throws {
        let networkManager = WeatherNetworkManager()
        let exp = expectation(description: "Checking fetchCurrentLocationWeather method")
        
        networkManager.fetchCurrentLocationWeather(lat: "55.751244", lon: "37.618423") { (weather) in
            let obtainedCity: String? = weather.name
            XCTAssertEqual(obtainedCity, "Moscow")
            exp.fulfill()
        }
        waitForExpectations(timeout: 10)
    }
    
    func testFetchCurrentWeather() throws {
        let networkManager = WeatherNetworkManager()
        let exp = expectation(description: "Checking fetchCurrentWeather method")
        
        networkManager.fetchCurrentWeather(city: "Moscow") { (weather) in
            let obtainedCity: String? = weather.name
            XCTAssertEqual(obtainedCity, "Moscow")
            exp.fulfill()
        }
        waitForExpectations(timeout: 10)
    }
    
    func testFetchNextFiveWeatherForecast() throws {
        let networkManager = WeatherNetworkManager()
        let exp = expectation(description: "Checking fetchNextFiveWeatherForecast method")
        
        networkManager.fetchNextFiveWeatherForecast(city: "Moscow") { (forecastTemperatureArray) in
            XCTAssertNotEqual(forecastTemperatureArray.count,0)
            exp.fulfill()
        }
        waitForExpectations(timeout: 10)
    }
    
    func testKelvinToCelciusConverter() throws {
        let numberToCheck: Float = 273.15
        XCTAssertEqual(numberToCheck.kelvinToCeliusConverter() == 0.00, true)
    }
    
    func testIncrementWeekDays() throws {
        let numberToCheck: Int = 4
        XCTAssertEqual(numberToCheck.incrementWeekDays(by: 2),6)
    }
    
    func testWeatherModelConverterConvertMethod() throws {
        let networkManager = WeatherNetworkManager()
        let exp = expectation(description: "Checking Convert method")
        
        networkManager.fetchCurrentWeather(city: "Moscow"){ (weather) in
            let weatherConverter = WeatherModelConverter()
            let weatherEntity = weatherConverter.convert(weatherModel: weather)
            XCTAssertEqual(weatherEntity.name, "Moscow")
            exp.fulfill()
        }
        waitForExpectations(timeout: 10)
    }
    
    func testWeatherModelConverterConvertWeatherMethod() throws {
        let networkManager = WeatherNetworkManager()
        let exp = expectation(description: "Checking WeatherConvert method")
        
        networkManager.fetchCurrentWeather(city: "Moscow"){ (weather) in
            let weatherConverter = WeatherModelConverter()
            let detailedWeatherEntity = weatherConverter.convertWeather(weatherModel: weather.weather[0])
            XCTAssertNotEqual(detailedWeatherEntity.description, nil)
            exp.fulfill()
        }
        waitForExpectations(timeout: 10)
    }
    
    func testSaveWeatherEntity() throws {
        let appDelegate = AppDelegate()
        let networkManager = WeatherNetworkManager()
        let exp = expectation(description: "Checking saveWeatherEntity method")
        
        networkManager.fetchCurrentWeather(city: "Moscow") { (weather) in
            let weatherEntity = appDelegate.saveWeatherEntity(model: weather)
            XCTAssertEqual(weatherEntity.name,"Moscow")
            exp.fulfill()
        }
        waitForExpectations(timeout: 10)
    }
    
    func testSaveDetailedWeatherEntity() throws {
        let appDelegate = AppDelegate()
        let networkManager = WeatherNetworkManager()
        let exp = expectation(description: "Checking saveDetailedWeatherEntity method")
        
        networkManager.fetchCurrentWeather(city: "Moscow") { (weather) in
            let weatherEntity = appDelegate.saveDetailedWeatherEntity(model: weather.weather[0])
            XCTAssertNotEqual(weatherEntity.description,nil)
            exp.fulfill()
        }
        waitForExpectations(timeout: 10)
    }
    
    func testFetchAllCities() throws {
        let appDelegate = AppDelegate()
        let allCitiesArray: [WeatherEntity]? = appDelegate.fetchAllCities()
        XCTAssertNotEqual(allCitiesArray?.count,0)
    }
}
