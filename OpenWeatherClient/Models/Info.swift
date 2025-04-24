//
//  MainDTO.swift
//  OpenWeatherClient
//
//  Created by Nikita Filonov on 24.04.2025.
//

import Foundation

struct Info: Codable {
    let temp, feelsLike, tempMin, tempMax: Double
    let pressure, humidity: Int
    
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
    }
}
