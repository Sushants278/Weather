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
}

extension Weather {
    var country: String {
        return cityName.components(separatedBy: ",").last ?? ""
    }
    
    var city: String {
        return cityName.components(separatedBy: ",").first ?? ""
    }
    
    var imageName: String {
        let availableImages = ["Berlin", "Dallas County", "City of London", "Paris", "Shimla"]
        return availableImages.contains(city) ? city : "defaultImage"
    }
}
