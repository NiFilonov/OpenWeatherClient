//
//  WeatherCached.swift
//  OpenWeatherClient
//
//  Created by Nikita Filonov on 24.04.2025.
//

import Foundation

struct WeatherCached: Codable {
    let weather: WeatherResponse
    let temperatureUnit: TemperatureUnit
}
