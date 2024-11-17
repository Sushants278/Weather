//
//  WeatherRequest.swift
//  Weather
//
//  Created by Sushant Shinde on 17/11/24.
//

import CoreData

/// Protocol to handle weather requests
protocol WeatherOfflineRequest {
    func fetchWeatherFromCoreData() async throws -> [Weather]
    func saveWeatherToCoreData(_ weather: WeatherResponse) async throws
    func fetchWeather(for city: String) async throws -> Weather?
}

extension CoreDataManager: WeatherOfflineRequest {
    
    /// Fetches weather from Core Data
    /// - Throws: Error
    ///  - Returns: [Weather]
    func fetchWeatherFromCoreData() async throws -> [Weather] {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<Weather> = NSFetchRequest(entityName: "WeatherInfo")
        
        return try await context.perform {
            try context.fetch(fetchRequest)
        }
    }
    
    /// Saves weather to Core Data
    /// - Parameter weather: WeatherResponse
    /// - Throws: Error
    /// - Returns: Void
    func saveWeatherToCoreData(_ weather: WeatherResponse) async throws {
        let context = newBackgroundContext()
        
        try await context.perform {
            let fetchRequest: NSFetchRequest<Weather> = NSFetchRequest(entityName: "WeatherInfo")
            fetchRequest.predicate = NSPredicate(format: "cityName == %@", weather.location?.name ?? "")
            
            let existingWeather = try context.fetch(fetchRequest).first
            let weatherEntity = existingWeather ?? Weather(context: context)
            
            weatherEntity.cityName = weather.location?.name ?? ""
            weatherEntity.temperature = weather.data?.temperature ?? 0.0
            weatherEntity.time = weather.data?.time ?? ""
            weatherEntity.id = existingWeather?.id ?? UUID().uuidString
            
            try context.save()
        }
    }
    
    /// Fetches weather for a city from Core Data
    /// - Parameter city: City name
    /// - Throws: Error
    /// - Returns: Weather
    func fetchWeather(for city: String) async throws -> Weather? {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<Weather> = NSFetchRequest(entityName: "WeatherInfo")
        fetchRequest.predicate = NSPredicate(format: "cityName == %@", city)
        
        return try await context.perform {
            try context.fetch(fetchRequest).first
        }
    }
}
