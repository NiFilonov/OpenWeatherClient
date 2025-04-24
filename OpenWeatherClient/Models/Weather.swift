//
//  WeatherDTO.swift
//  OpenWeatherClient
//
//  Created by Nikita Filonov on 24.04.2025.
//

import Foundation

struct Weather: Codable {
    let id: Int
    let main, description, icon: String
}
