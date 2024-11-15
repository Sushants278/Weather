//
//  NetworkManager+UserRequest.swift
//  Weather
//
//  Created by Sushant Shinde on 16/10/24.
//

import Foundation


typealias LocationWeatherClosure = ((Swift.Result<User, APIError>) -> Void)

// Protocol to define user requests
protocol WeatherRequest {
    
    func fetchUsers(isLoadMore: Bool, pageNumber: Int, seed: String, handler: @escaping LocationWeatherClosure)
}

// NetworkManager conforms to UserRequests
extension NetworkManager: WeatherRequest {
    
    // Function to fetch users from server
    func fetchWeatherForUsers( isLoadMore: Bool = false, pageNumber: Int = 1, seed: String = "", handler: @escaping UserCompletionClosure) {
        
        var parameters: [String : Any] = ["results": 25,"inc": "gender,name,nat,email,id" ]
        
        if isLoadMore {
            
            parameters["page"] = pageNumber
            parameters["seed"] = seed
        }
        
        self.request(parameters: parameters, completion: handler)
    }
}
