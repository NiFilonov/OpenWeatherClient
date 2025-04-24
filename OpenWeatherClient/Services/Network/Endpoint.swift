//
//  Endpoint.swift
//  OpenWeatherClient
//
//  Created by Nikita Filonov on 24.04.2025.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct Endpoint {
    let path: String
    let method: HTTPMethod
    let queryParameters: [URLQueryItem]?
    let body: [String: Any]?
    let headers: [String: String]?
    
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5" + path
        components.queryItems = queryParameters
        
        return components.url
    }
    
    // Примеры эндпоинтов
    static func weather(for city: String, apiKey: String, units: String) -> Endpoint {
        Endpoint(
            path: "/weather",
            method: .get,
            queryParameters: [
                URLQueryItem(name: "q", value: city),
                URLQueryItem(name: "appid", value: apiKey),
                URLQueryItem(name: "units", value: units)
            ],
            body: nil,
            headers: ["Content-Type": "application/json"]
        )
    }
    
    static func weather(lat: Double, lon: Double, apiKey: String, units: String) -> Endpoint {
        Endpoint(
            path: "/weather",
            method: .get,
            queryParameters: [
                URLQueryItem(name: "lat", value: "\(lat)"),
                URLQueryItem(name: "lon", value: "\(lon)"),
                URLQueryItem(name: "appid", value: apiKey),
                URLQueryItem(name: "units", value: units)
            ],
            body: nil,
            headers: ["Content-Type": "application/json"]
        )
    }
}
