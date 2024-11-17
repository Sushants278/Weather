//
//  WeatherListViewModelTests.swift
//  Weather
//
//  Created by Sushant Shinde on 17/11/24.
//
import XCTest
@testable import Weather
import CoreData

class WeatherListViewModelTests: XCTestCase {
    var sut: WeatherListViewModel!
    var mockWeatherManager: MockWeatherRequest!
    var mockOfflineManager: MockWeatherOfflineRequest!
    
    override func setUp() {
        super.setUp()
        mockWeatherManager = MockWeatherRequest()
        mockOfflineManager = MockWeatherOfflineRequest()
        sut = WeatherListViewModel(
            weatherManager: mockWeatherManager,
            offlineManager: mockOfflineManager
        )
    }
    
    override func tearDown() {
        sut = nil
        mockWeatherManager = nil
        mockOfflineManager = nil
        super.tearDown()
    }
    
    // MARK: - Initial Load Tests
    
    func testInitialLoadFromOfflineStorage() async throws {
        // Given
        let mockWeather = createMockWeather(city: "Test City", country: "US", temperature: 20.0)
        mockOfflineManager.mockStoredWeather = [mockWeather]
        
        // When
        await sut.getWeather()
        
        // Then
        XCTAssertEqual(sut.weatherList.count, 1)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
    
    func testInitialLoadWithEmptyOfflineStorage() async {
        // Given
        mockOfflineManager.mockStoredWeather = []
        mockWeatherManager.mockResponse = createMockWeatherResponse()
        
        // When
        await sut.getWeather()
        
        // Then
        XCTAssertEqual(sut.weatherList.count, 0) // Initially empty until save completes
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
    
    func testInitialLoadWithOfflineError() async {
        // Given
        mockOfflineManager.shouldThrowError = true
        
        // When
        await sut.getWeather()
        
        // Then
        XCTAssertEqual(sut.weatherList.count, 0)
        XCTAssertNotNil(sut.error)
        if case .fetchFailed(let message) = sut.error {
            XCTAssertEqual(message, "Failed to load offline data.")
        } else {
            XCTFail("Wrong error type received")
        }
    }
    
    // MARK: - Refresh Tests
    
    func testRefreshWeatherSuccess() async {
        // Given
        let cityName = "Berlin"
        let mockResponse = createMockWeatherResponse(cityName: cityName, temperature: 25.0)
        mockWeatherManager.mockResponse = mockResponse
        
        // When
        await sut.refreshWeather(for: cityName)
        
        // Then
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
    
    func testRefreshWeatherNetworkError() async {
        // Given
        let cityName = "Berlin"
        mockWeatherManager.shouldThrowError = true
        
        // When
        await sut.refreshWeather(for: cityName)
        
        // Then
        XCTAssertFalse(sut.isLoading)
        XCTAssertNotNil(sut.error)
        if case .fetchFailed(let message) = sut.error {
            XCTAssertEqual(message, "Failed to refresh weather data for Berlin. Please try again.")
        } else {
            XCTFail("Wrong error type received")
        }
    }
    
    // MARK: - Helper Methods
    
    private func createMockWeather(city: String, country: String, temperature: Double) -> Weather {
         let context = MockPersistentContainer().viewContext
         let weather = Weather(context: context)
         // Set cityName in the format "City, Country" to match the expected format
         weather.cityName = "\(city), \(country)"
         weather.temperature = temperature
         weather.time = "2024-11-16T12:00:00Z"
         weather.id = UUID().uuidString
         return weather
     }
    
    private func createMockWeatherResponse(cityName: String = "Berlin", temperature: Double = 20.0) -> WeatherResponse {
         // Create JSON data matching the expected structure
         let json: [String: Any] = [
             "data": [
                 "time": "2024-11-16T12:00:00Z",
                 "values": [
                     "temperature": temperature
                 ]
             ],
             "location": [
                 "name": cityName
             ]
         ]
         
         do {
             let jsonData = try JSONSerialization.data(withJSONObject: json)
             return try JSONDecoder().decode(WeatherResponse.self, from: jsonData)
         } catch {
             fatalError("Failed to create mock WeatherResponse: \(error)")
         }
     }
    
}

// MARK: - Mock Classes

class MockWeatherRequest: WeatherRequest {
        var mockResponse: WeatherResponse?
        var shouldThrowError = false
        var fetchWeatherCalled = false
        var lastFetchedCity: String?
        
        func fetchWeatherForcity(city: String) async throws -> WeatherResponse {
            fetchWeatherCalled = true
            lastFetchedCity = city
            
            if shouldThrowError {
                throw WeatherError.networkError("Mock network error")
            }
            
            if let mockResponse = mockResponse {
                return mockResponse
            }
            
            // Create default response using JSON
            let defaultJson: [String: Any] = [
                "data": [
                    "time": "2024-11-16T12:00:00Z",
                    "values": [
                        "temperature": 20.0
                    ]
                ],
                "location": [
                    "name": city
                ]
            ]
            
            let jsonData = try JSONSerialization.data(withJSONObject: defaultJson)
            return try JSONDecoder().decode(WeatherResponse.self, from: jsonData)
        }
    }

class MockWeatherOfflineRequest: WeatherOfflineRequest {
    var mockStoredWeather: [Weather] = []
    var shouldThrowError = false
    
    func fetchWeatherFromCoreData() async throws -> [Weather] {
        if shouldThrowError {
            throw WeatherError.fetchFailed("Mock fetch error")
        }
        return mockStoredWeather
    }
    
    func saveWeatherToCoreData(_ weather: WeatherResponse) async throws {
        if shouldThrowError {
            throw WeatherError.saveFailed("Mock save error")
        }
    }
    
    func fetchWeather(for city: String) async throws -> Weather? {
        if shouldThrowError {
            throw WeatherError.fetchFailed("Mock fetch error")
        }
        return mockStoredWeather.first { $0.cityName == city }
    }
}

class MockPersistentContainer {
    lazy var viewContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        return context
    }()
}
