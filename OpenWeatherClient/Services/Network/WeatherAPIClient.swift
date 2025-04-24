//
//  WeatherAPIClient.swift
//  OpenWeatherClient
//
//  Created by Nikita Filonov on 24.04.2025.
//

import Foundation
import Combine

protocol WeatherAPIClientProtocol {
    func fetchWeather(city: String, units: String) -> AnyPublisher<WeatherResponse, Error>
    func fetchWeather(lat: Double, lon: Double, units: String) -> AnyPublisher<WeatherResponse, Error>
}

final class WeatherAPIClient: WeatherAPIClientProtocol {
    private let networkService: NetworkServiceProtocol
    private let apiKey: String
    
    init(networkService: NetworkServiceProtocol = NetworkService(), apiKey: String) {
        self.networkService = networkService
        self.apiKey = apiKey
    }
    
    func fetchWeather(city: String, units: String) -> AnyPublisher<WeatherResponse, Error> {
        networkService.request(
            .weather(for: city, apiKey: apiKey, units: units),
            responseType: WeatherResponse.self
        )
        .mapError { error in
            // Можно добавить дополнительную обработку ошибок
            error as Error
        }
        .eraseToAnyPublisher()
    }
    
    func fetchWeather(lat: Double, lon: Double, units: String) -> AnyPublisher<WeatherResponse, Error> {
        networkService.request(
            .weather(lat: lat, lon: lon, apiKey: apiKey, units: units),
            responseType: WeatherResponse.self
        )
        .eraseToAnyPublisher()
    }
}
