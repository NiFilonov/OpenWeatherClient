//
//  WeatherCacheService.swift
//  OpenWeatherClient
//
//  Created by Nikita Filonov on 24.04.2025.
//

import Foundation

protocol WeatherCacheServiceProtocol {
    func save(weather: WeatherResponse, for city: String, unit: TemperatureUnit)
    func saveCurrentLocationWeather(_ weather: WeatherResponse, unit: TemperatureUnit)
    func getCachedWeather() -> (weather: WeatherResponse, unit: TemperatureUnit)?
}

final class WeatherCacheService: WeatherCacheServiceProtocol {
    private let userDefaults = UserDefaults.standard
    private let cacheKey = "cached_weather_data"
    private let currentLocationKey = "current_location"
    
    func save(weather: WeatherResponse, for city: String, unit: TemperatureUnit) {
        let data = try? JSONEncoder().encode(WeatherCached(weather: weather, temperatureUnit: unit))
        userDefaults.set(data, forKey: cacheKey)
    }
    
    func saveCurrentLocationWeather(_ weather: WeatherResponse, unit: TemperatureUnit) {
        save(weather: weather, for: currentLocationKey, unit: unit)
    }
    
    func getCachedWeather() -> (weather: WeatherResponse, unit: TemperatureUnit)? {
        guard let data = userDefaults.data(forKey: cacheKey) else { return nil }
        return [try? JSONDecoder().decode(WeatherCached.self, from: data)]
            .compactMap({ cached in
                if let cached {
                    return (cached.weather, cached.temperatureUnit)
                }
                return nil
            }).first
    }
}
