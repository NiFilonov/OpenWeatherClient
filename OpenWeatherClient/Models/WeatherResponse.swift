//
//  WeatherResponse.swift
//  OpenWeatherClient
//
//  Created by Nikita Filonov on 24.04.2025.
//

import Foundation

struct WeatherResponse: Codable {
    let coord: Coordinates
    let weather: [Weather]
    let main: Info
    let name: String
}
