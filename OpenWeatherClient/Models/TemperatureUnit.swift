//
//  TemperatureUnit.swift
//  OpenWeatherClient
//
//  Created by Nikita Filonov on 24.04.2025.
//

import Foundation

enum TemperatureUnit: String, CaseIterable, Codable {
    case celsius = "°C"
    case fahrenheit = "°F"
    
    var apiParam: String {
        switch self {
        case .celsius: return "metric"
        case .fahrenheit: return "imperial"
        }
    }
}
