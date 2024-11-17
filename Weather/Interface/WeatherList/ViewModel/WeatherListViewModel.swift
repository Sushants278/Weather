//
//  WeatherListViewModel.swift
//  Weather
//
//  Created by Sushant Shinde on 16/11/24.
//

import Foundation
import CoreData

enum SortOption {
       case byName
       case byTemperature
}

class WeatherListViewModel: ObservableObject {
    @Published var weatherList = [Weather]()
    @Published var isLoading = false
    @Published var error: WeatherError?
    @Published var sortOption: SortOption = .byName {
           didSet {
               sortWeatherList()
           }
       }
    
    private let weatherManager: WeatherRequest = NetworkManager.shared
    private let offlineManager: WeatherOfflineRequest = CoreDataManager.shared
    
    func getWeather() async {
        do {
            let storedData = try await offlineManager.fetchWeatherFromCoreData()
            if storedData.isEmpty {
                await fetchInitialWeatherData()
            } else {
                await MainActor.run {
                    self.weatherList = storedData
                    sortWeatherList()
                }
            }
        } catch {
            await MainActor.run { self.error = .fetchFailed("Failed to load offline data.") }
        }
    }
    
    func fetchInitialWeatherData() async {
        let defaultCities = ["Berlin", "Dallas", "London", "Paris", "Shimla"]
        
        guard Reachability.isConnectedToNetwork() else {
            await MainActor.run {
                self.error = .networkError("No internet connection.")
            }
            return
        }
        
        await fetchWeather(for: defaultCities)
    }
    
    func fetchWeather(for cities: [String]) async {
        guard !cities.isEmpty else { return }
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        let failedCitiesTracker = FailedCitiesTracker()
        
        await withTaskGroup(of: (String, WeatherResponse?).self) { group in
            for city in cities {
                group.addTask {
                    do {
                        let weather = try await self.weatherManager.fetchWeatherForcity(city: city)
                        return (city, weather)
                    } catch {
                        await failedCitiesTracker.add(city)
                        return (city, nil)
                    }
                }
            }
            
            for await (_, result) in group {
                if let weather = result {
                    try? await offlineManager.saveWeatherToCoreData(weather)
                }
            }
        }
        
        let failedCities = await failedCitiesTracker.allFailedCities()
        
        if !failedCities.isEmpty {
            await MainActor.run {
                error = .networkError("Failed to fetch weather for: \(failedCities.joined(separator: ", "))")
            }
        }
        await MainActor.run {
            isLoading = false
        }
    }
    
    func refreshWeather(for city: String) async {
        guard !city.isEmpty else { return }
        
        guard Reachability.isConnectedToNetwork() else {
            await MainActor.run {
                self.error = .networkError("No internet connection. Please check your network and try again.")
            }
            return
        }
        
        // Indicate loading state
        await MainActor.run {
            self.isLoading = true
            self.error = nil
        }
        
        do {
            let weather = try await weatherManager.fetchWeatherForcity(city: city)
            
            try await offlineManager.saveWeatherToCoreData(weather)
            
            let storedData = try await offlineManager.fetchWeatherFromCoreData()
            await MainActor.run {
                self.weatherList = storedData
            }
        } catch {
            await MainActor.run {
                self.error = .fetchFailed("Failed to refresh weather data for \(city). Please try again.")
            }
        }
        
        await MainActor.run {
            self.isLoading = false
        }
    }
    
    private func sortWeatherList() {
           switch sortOption {
           case .byName:
               weatherList.sort { $0.city < $1.city }
           case .byTemperature:
               weatherList.sort { $0.temperature < $1.temperature }
           }
       }
}

actor FailedCitiesTracker {
    private var cities: [String] = []
    
    func add(_ city: String) {
        cities.append(city)
    }
    
    func allFailedCities() -> [String] {
        return cities
    }
}
