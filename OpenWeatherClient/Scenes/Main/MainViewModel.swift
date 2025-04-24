//
//  MainViewModel.swift
//  OpenWeatherClient
//
//  Created by Nikita Filonov on 24.04.2025.
//

import CoreLocation
import Combine

final class MainViewModel {
    
    private let locationService: LocationServiceProtocol
    private let weatherService: WeatherAPIClientProtocol
    private let cacheService: WeatherCacheServiceProtocol
    
    @Published private(set) var weatherData: WeatherResponse?
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var temperatureUnit: TemperatureUnit = .celsius {
        didSet {
            updateCachedWeather()
            fetchWeather(for: weatherData?.name ?? "")
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init(locationService: LocationServiceProtocol = LocationService(),
        weatherService: WeatherAPIClientProtocol = WeatherAPIClient(apiKey: "9eafe389679b9340a0763efc0af43ac1"),
        cacheService: WeatherCacheServiceProtocol = WeatherCacheService()) {
        self.locationService = locationService
        self.weatherService = weatherService
        self.cacheService = cacheService
        
        setupBindings()
        loadCachedWeather()
    }
    
    func requestLocationAuthorization() {
        locationService.requestLocationAuthorization()
    }
    
    func fetchWeatherForCurrentLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            error = NSError(domain: "Location access denied", code: 0)
            return
        }
        
        locationService.startUpdatingLocation()
    }
    
    func fetchWeather(for city: String) {
        isLoading = true
        
        weatherService.fetchWeather(city: city, units: temperatureUnit.apiParam)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] weather in
                self?.weatherData = weather
                self?.cacheService.save(weather: weather, for: city, unit: self?.temperatureUnit ?? .celsius)
            }
            .store(in: &cancellables)
    }
    
    private func setupBindings() {
        locationService.authorizationStatusPublisher
            .assign(to: &$authorizationStatus)
        
        locationService.locationPublisher
            .compactMap { $0 }
            .flatMap { [weak self] location -> AnyPublisher<WeatherResponse, Error> in
                guard let self = self else {
                    return Empty().eraseToAnyPublisher()
                }
                return self.weatherService.fetchWeather(
                    lat: location.coordinate.latitude,
                    lon: location.coordinate.longitude,
                    units: self.temperatureUnit.apiParam
                )
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] weather in
                self?.weatherData = weather
                self?.cacheService.saveCurrentLocationWeather(weather, unit: self?.temperatureUnit ?? .celsius)
            }
            .store(in: &cancellables)
    }
    
    private func loadCachedWeather() {
        if let cached = cacheService.getCachedWeather() {
            weatherData = cached.weather
            temperatureUnit = cached.unit
        }
    }
    
    private func updateCachedWeather() {
        guard let weather = weatherData else { return }
        
        cacheService.save(weather: weather, for: weather.name, unit: temperatureUnit)
        cacheService.saveCurrentLocationWeather(weather, unit: temperatureUnit)
    }
}
