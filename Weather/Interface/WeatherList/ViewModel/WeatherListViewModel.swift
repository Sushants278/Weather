//
//  WeatherListViewModel.swift
//  Weather
//
//  Created by Sushant Shinde on 16/11/24.
//

import Foundation
import CoreData

/// Sort options for weather list.
enum SortOption {
    case byName
    case byTemperature
}

class WeatherListViewModel: ObservableObject {
    
    // Published properties
    @Published var weatherList = [Weather]()
    @Published var isLoading = false
    @Published var error: WeatherError?
    @Published var sortOption: SortOption = .byName {
        didSet {
            sortWeatherList()
        }
    }
    
    private let weatherManager: WeatherRequest
    private let offlineManager: WeatherOfflineRequest
    
    // MARK: - Initializer
    /// Initializes the view model with default values.
    /// - Parameters:  weatherManager: WeatherRequest object to fetch weather data.
    ///                offlineManager: WeatherOfflineRequest object to fetch offline weather data.
    init(weatherManager: WeatherRequest = NetworkManager.shared,
         offlineManager: WeatherOfflineRequest = CoreDataManager.shared) {
        self.weatherManager = weatherManager
        self.offlineManager = offlineManager
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCoreDataChanges),
            name: .NSManagedObjectContextDidSave,
            object: nil
        )
    }
    
    /// Deinitializes the  removes observers.
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Handles core data changes.
    /// - Parameter notification: Notification
    /// - Note: This method is called when core data changes are detected.
    @objc private func handleCoreDataChanges(_ notification: Notification) {
        Task { @MainActor in
            await getWeather()
        }
    }
    
    
    /// Fetches weather data from offline storage or triggers an online fetch if offline data is unavailable.
    ///
    /// If offline data exists, it updates and sorts `weatherList`.
    /// Otherwise, it fetches new data online. Errors are captured in the `error` property.
    ///
    /// - Throws: `WeatherError` if offline data retrieval fails.
    func getWeather() async {
        do {
            let storedData = try await offlineManager.fetchWeatherFromCoreData()
            if storedData.isEmpty {
                await fetchInitialWeatherData()
            } else {
                await MainActor.run {
                    self.weatherList = storedData
                }
            }
        } catch {
            await MainActor.run { self.error = .fetchFailed("Failed to load offline data.") }
        }
    }
    
    /// Fetches weather data for a list of cities.
    /// - Throws: `WeatherError` if network fetch fails.
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
    
    /// Fetches weather data for a list of cities.
    /// - Parameter cities: List of city names.
    /// - Throws: `WeatherError` if network fetch fails.
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
    
    /// Refreshes weather data for a single city.
    /// - Parameter city: Name of the city to refresh.
    /// - Throws: `WeatherError` if network fetch fails.
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
    
    /// sort weather list based on selected option
    private func sortWeatherList() {
        switch sortOption {
        case .byName:
            weatherList.sort { $0.city < $1.city }
        case .byTemperature:
            weatherList.sort { $0.temperature < $1.temperature }
        }
    }
}

// MARK: - FailedCitiesTracker

/// Helper class to track failed cities during network fetch.
actor FailedCitiesTracker {
    private var cities: [String] = []
    
    func add(_ city: String) {
        cities.append(city)
    }
    
    func allFailedCities() -> [String] {
        return cities
    }
}
