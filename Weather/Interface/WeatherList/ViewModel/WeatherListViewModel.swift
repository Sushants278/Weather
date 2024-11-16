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
    
    func fetchWeather(city: String) {
        weatherManager.fetchWeatherForcity(city: city) { result in
            switch result {
            case .success(let weather):
                self.weatherList.append(weather)
            case .failure(let error):
                print(error)
            }
        }
    }
}
        
    


