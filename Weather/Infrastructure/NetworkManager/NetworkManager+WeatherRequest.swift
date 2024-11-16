//
//  NetworkManager+UserRequest.swift
//  Weather
//
//  Created by Sushant Shinde on 16/10/24.
//

import Foundation

protocol WeatherRequest {
    
    func fetchWeatherForcity(city: String) async throws -> WeatherResponse
}

extension NetworkManager: WeatherRequest {
    
    func fetchWeatherForcity(city: String) async throws -> WeatherResponse {
        var parameters: [String : Any] = ["location": city, "apikey": "lNH84ae0ZvxBGM8sVLgELcHMsKnbA6f6"]
        
        let weather: WeatherResponse = try await self.request(parameters: parameters)
        return weather
    }
}
