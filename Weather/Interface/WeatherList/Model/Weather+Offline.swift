//
//  Weather+Offline.swift
//  Weather
//
//  Created by Sushant Shinde on 16/11/24.
//

import CoreData

// MARK: - Core Data

/// Managed object subclass for the WeatherInfo entity.
class Weather: NSManagedObject {
    @NSManaged var temperature: Double
    @NSManaged var cityName: String
    @NSManaged var time: String
    @NSManaged var id: String
    @NSManaged var lastUpdated: Date
}
