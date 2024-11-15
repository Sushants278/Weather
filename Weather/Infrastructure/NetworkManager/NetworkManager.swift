//
//  NetworkManager.swift
//  Randomizer
//
//  Created by Sushant Shinde on 01/05/23.
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
    
    private let baseURL = URL(string: "https://randomuser.me/api")!
    
    private let urlSession = URLSession.shared
 
    func request<T: Decodable>(method: HTTPMethod = .get,
                               parameters: [String: Any]? = nil,
                               completion: @escaping (Swift.Result<T, APIError>) -> Void) {
                
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = parameters?.map { URLQueryItem(name: $0, value: "\($1)") }
        var request = URLRequest(url: urlComponents.url!)
        
        request.httpMethod = method.rawValue
        
        let task = urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(APIError.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.apiError(0, "Unknown Error")))
                return
            }
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                let message = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                completion(.failure(APIError.apiError(httpResponse.statusCode, message)))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.apiError(0, "No Data Found")))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(T.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(APIError.decodingError(error)))
            }
        }
        
        task.resume()
    }
}
