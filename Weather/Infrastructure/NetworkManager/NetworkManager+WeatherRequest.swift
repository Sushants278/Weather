//
//  NetworkManager+UserRequest.swift
//  Weather
//
//  Created by Sushant Shinde on 16/10/24.
//

import Foundation

/// WeatherRequest protocol
protocol WeatherRequest {
    
    func fetchWeatherForcity(city: String) async throws -> WeatherResponse
}

extension NetworkManager: WeatherRequest {
    
    /// Fetch weather for city
    /// - Parameter city: city name
    /// - Returns: WeatherResponse
    /// - Throws: Error
    func fetchWeatherForcity(city: String) async throws -> WeatherResponse {
        let parameters: [String : Any] = ["location": city, "apikey": "lNH84ae0ZvxBGM8sVLgELcHMsKnbA6f6"]
        
        let weather: WeatherResponse = try await self.request(parameters: parameters)
        return weather
    }
}
