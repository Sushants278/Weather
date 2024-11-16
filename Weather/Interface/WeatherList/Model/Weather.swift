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
    let humidity: Int?
    let weatherCode: Int?

    enum CodingKeys: String, CodingKey {
        case time
        case values
    }

    enum ValuesKeys: String, CodingKey {
        case temperature
        case humidity
        case weatherCode
    }

    // Custom Decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        time = try container.decodeIfPresent(String.self, forKey: .time)

        let valuesContainer = try container.nestedContainer(keyedBy: ValuesKeys.self, forKey: .values)
        temperature = try valuesContainer.decodeIfPresent(Double.self, forKey: .temperature)
        humidity = try valuesContainer.decodeIfPresent(Int.self, forKey: .humidity)
        weatherCode = try valuesContainer.decodeIfPresent(Int.self, forKey: .weatherCode)
    }

    // Custom Encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(time, forKey: .time)

        var valuesContainer = container.nestedContainer(keyedBy: ValuesKeys.self, forKey: .values)
        try valuesContainer.encodeIfPresent(temperature, forKey: .temperature)
        try valuesContainer.encodeIfPresent(humidity, forKey: .humidity)
        try valuesContainer.encodeIfPresent(weatherCode, forKey: .weatherCode)
    }
}

struct LocationData: Codable {
    let name: String?
    let type: String?
}
