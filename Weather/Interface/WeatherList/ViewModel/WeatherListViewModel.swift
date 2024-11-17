//
//  WeatherListViewModel.swift
//  Weather
//
//  Created by Sushant Shinde on 16/11/24.
//

import Foundation
import CoreData

class WeatherListViewModel: ObservableObject {
    
    @Published var weatherList = [Weather]()
    @Published var isLoading = false
    @Published var error: WeatherError?
    private var weatherManager: WeatherRequest = NetworkManager.shared
    private let coreDataManager = CoreDataManager.shared
    
    
    init() {
        // Setup notification observer for Core Data changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCoreDataChanges),
            name: .NSManagedObjectContextDidSave,
            object: nil
        )
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleCoreDataChanges(_ notification: Notification) {
        Task { @MainActor in
            weatherList = fetchWeatherFromCoreData()
        }
    }
    
    func getWeather() async {
        Task {
            let storedData = fetchWeatherFromCoreData()
            if storedData.isEmpty {
                // If no stored data, fetch fresh data for default cities
                await fetchInitialWeatherData()
            } else {
                // If we have stored data, load it and refresh if stale
                DispatchQueue.main.async {
                    
                    self.weatherList = storedData
                }
            }
        }
    }
    
    /// Load offline data from Core Data
    private func loadOfflineData() {
        
        weatherList = fetchWeatherFromCoreData()
    }
    
    /// Fetch weather for multiple cities concurrently using async/await.
    func fetchWeather(for cities: [String]) async {
        guard !cities.isEmpty else { return }
        
        DispatchQueue.main.async {
            
            self.isLoading = true
            self.error = nil
        }
        
        await withTaskGroup(of: WeatherResponse?.self) { group in
            for city in cities {
                group.addTask {
                    do {
                        return try await self.weatherManager.fetchWeatherForcity(city: city)
                    } catch {
                        await MainActor.run {
                            self.error = .networkError(error.localizedDescription)
                        }
                        return nil
                    }
                }
            }
            
            for await result in group {
                if let weather = result {
                    await saveWeatherToCoreData(weather)
                }
            }
        }
        
        DispatchQueue.main.async {
            
            self.isLoading = false
        }
    }
    
    func refreshWeather(for city: String) async {
        guard !city.isEmpty else { return }
        
        DispatchQueue.main.async {
            
            self.isLoading = true
            self.error = nil
        }
        
        do {
            let weather = try await weatherManager.fetchWeatherForcity(city: city)
            await saveWeatherToCoreData(weather)
        } catch {
            DispatchQueue.main.async {
                self.error = .networkError(error.localizedDescription)
            }
        }
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    private func fetchInitialWeatherData() async {
        let defaultCities = ["Berlin", "Dallas", "London", "Paris", "Shimla"]
        await fetchWeather(for: defaultCities)
    }
    
    
    private func saveWeatherToCoreData(_ weather: WeatherResponse) async {
        let context = coreDataManager.newBackgroundContext()
        
        await context.perform { [weak self] in
            guard let self = self else { return }
            
            let fetchRequest: NSFetchRequest<Weather> = NSFetchRequest(entityName: "WeatherInfo")
            fetchRequest.predicate = NSPredicate(format: "cityName == %@", weather.location?.name ?? "")
            
            do {
                let existingWeather = try context.fetch(fetchRequest).first
                
                if let existingWeather = existingWeather {
                    self.updateWeatherEntity(existingWeather, with: weather)
                } else {
                    let weatherEntity = Weather(context: context)
                    self.updateWeatherEntity(weatherEntity, with: weather)
                    weatherEntity.id = UUID().uuidString
                }
                
                try context.save()
                
            } catch {
                DispatchQueue.main.async {
                    self.error = .saveFailed(error.localizedDescription)
                }
            }
        }
    }
    
    
    private func updateWeatherEntity(_ entity: Weather, with response: WeatherResponse) {
        entity.cityName = response.location?.name ?? ""
        entity.temperature = response.data?.temperature ?? 0.0
        entity.time = response.data?.time ?? ""
    }
    
    
    // Fetch weather data from Core Data
    private func fetchWeatherFromCoreData() -> [Weather] {
        let context = coreDataManager.container.viewContext
        let fetchRequest: NSFetchRequest<Weather> =  NSFetchRequest(entityName: "WeatherInfo")
        do {
            return try context.fetch(fetchRequest)
        } catch {
            self.error = .fetchFailed(error.localizedDescription)
            return []
        }
    }
}

