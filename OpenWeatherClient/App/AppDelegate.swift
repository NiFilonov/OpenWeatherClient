//
//  AppDelegate.swift
//  OpenWeatherClient
//
//  Created by Nikita Filonov on 23.04.2025.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let viewModel = MainViewModel()
        window?.rootViewController = MainViewController(viewModel: viewModel)
        window?.makeKeyAndVisible()
        return true
    }
}

