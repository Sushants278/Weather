//
//  NetworkManager+UserRequest.swift
//  Weather
//
//  Created by Sushant Shinde on 16/10/24.
//

import Foundation


typealias LocationWeatherClosure = ((Swift.Result<WeatherResponse, APIError>) -> Void)

// Protocol to define weather requests
protocol WeatherRequest {
    
    func fetchWeatherForcity(city: String, handler: @escaping LocationWeatherClosure)
}

// NetworkManager conforms to UserRequests
extension NetworkManager: WeatherRequest {
    
    func fetchWeatherForcity(city: String, handler: @escaping LocationWeatherClosure) {
        
        var parameters: [String : Any] = ["location": city,"apikey": "lNH84ae0ZvxBGM8sVLgELcHMsKnbA6f6" ]
        
        self.request(parameters: parameters, completion: handler)
    }
}
