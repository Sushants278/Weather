//
//  NetworkManager.swift
//  Weather
//
//  Created by Sushant Shinde on 16/10/24.
//

import Foundation

enum APIError: Error {
    case networkError(Error)
    case apiError(Int, String)
    case decodingError(Error)
}

enum HTTPMethod: String {
    case get = "GET"
}

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    private let baseURL = URL(string: "https://api.tomorrow.io/v4/weather/realtime")!
    private let urlSession = URLSession.shared
    
    func request<T: Decodable>(method: HTTPMethod = .get, parameters: [String: Any]? = nil) async throws -> T {
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = parameters?.map { URLQueryItem(name: $0, value: "\($1)") }
        var request = URLRequest(url: urlComponents.url!)
        
        request.httpMethod = method.rawValue
        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.apiError(0, "Unknown Error")
        }
        
        guard (200..<300).contains(httpResponse.statusCode) else {
            let message = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            throw APIError.apiError(httpResponse.statusCode, message)
        }
        
        guard !data.isEmpty else {
            throw APIError.apiError(0, "No Data Found")
        }
        
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(T.self, from: data)
            return result
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
