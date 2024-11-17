//
//  Weather.swift
//  Weather
//
//  Created by Sushant Shinde on 16/11/24.
//
import Foundation

struct WeatherResponse: Codable {
    let data: WeatherData?
    let location: LocationData?
}

struct WeatherData: Codable {
    let time: String?
    let temperature: Double?

    enum CodingKeys: String, CodingKey {
        case time
        case values
    }

    enum ValuesKeys: String, CodingKey {
        case temperature
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        time = try container.decodeIfPresent(String.self, forKey: .time)
        let valuesContainer = try container.nestedContainer(keyedBy: ValuesKeys.self, forKey: .values)
        temperature = try valuesContainer.decodeIfPresent(Double.self, forKey: .temperature)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(time, forKey: .time)
        var valuesContainer = container.nestedContainer(keyedBy: ValuesKeys.self, forKey: .values)
        try valuesContainer.encodeIfPresent(temperature, forKey: .temperature)
    }
}

struct LocationData: Codable {
    let name: String?
}

enum WeatherError: Error {
    case fetchFailed(String)
    case saveFailed(String)
    case networkError(String)
    case invalidData
    
    var localizedDescription: String {
        switch self {
        case .fetchFailed(let message): return "Failed to fetch weather: \(message)"
        case .saveFailed(let message): return "Failed to save weather: \(message)"
        case .networkError(let message): return "Network error: \(message)"
        case .invalidData: return "Invalid weather data received"
        }
    }
}
