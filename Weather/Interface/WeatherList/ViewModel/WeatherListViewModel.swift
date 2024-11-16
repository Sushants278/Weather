//
//  WeatherListViewModel.swift
//  Weather
//
//  Created by Sushant Shinde on 16/11/24.
//

import Foundation

class WeatherListViewModel: ObservableObject {
    
    @Published var weatherList = [WeatherResponse]()
    private var weatherManager: WeatherRequest = NetworkManager.shared
    
    /// Fetch weather for multiple cities concurrently using async/await.
    func fetchWeather(for cities: [String]) async {
        DispatchQueue.main.async {
              self.weatherList = []
        }
        
        await withTaskGroup(of: WeatherResponse?.self) { group in
            for city in cities {
                group.addTask {
                    do {
                        return try await self.weatherManager.fetchWeatherForcity(city: city)
                    } catch {
                        print("Failed to fetch weather for \(city): \(error)")
                        return nil
                    }
                }
            }
            
            for await result in group {
                if let weather = result {
                    DispatchQueue.main.async {
                        self.weatherList.append(weather)
                    }
                }
            }
        }
    }
}
        
    


