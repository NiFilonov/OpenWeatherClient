//
//  MainViewController.swift
//  OpenWeatherClient
//
//  Created by Nikita Filonov on 24.04.2025.
//

import UIKit
import SnapKit
import Combine
import CoreLocation

final class MainViewController: UIViewController {
    
    lazy private var locationButton: UIButton = {
        $0.setTitle("Получить погоду по геолокации", for: .normal)
        $0.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    private let cityTextField: UITextField = {
        $0.placeholder = "Введите название города"
        $0.borderStyle = .roundedRect
        return $0
    }(UITextField())
    
    lazy private var searchButton: UIButton = {
        $0.setTitle("Поиск", for: .normal)
        $0.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    private let temperatureLabel: UILabel = {
        $0.font = .systemFont(ofSize: 48, weight: .bold)
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    private let weatherDescriptionLabel: UILabel = {
        $0.font = .systemFont(ofSize: 24)
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    private let cityNameLabel: UILabel = {
        $0.font = .systemFont(ofSize: 24, weight: .medium)
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    private let activityIndicator: UIActivityIndicatorView = {
        $0.hidesWhenStopped = true
        return $0
    }(UIActivityIndicatorView(style: .large))
    
    lazy private var unitSwitch: UISegmentedControl = {
        $0.selectedSegmentIndex = 0
        $0.addTarget(self, action: #selector(unitSwitchChanged), for: .valueChanged)
        return $0
    }(UISegmentedControl(items: TemperatureUnit.allCases.map { $0.rawValue }))
    
    private let errorLabel: UILabel = {
        $0.textColor = .red
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.isHidden = true
        return $0
    }(UILabel())
    
    private let viewModel: MainViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: MainViewModel = MainViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now()+1) { [weak self] in
            self?.viewModel.requestLocationAuthorization()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        addSubviews()
        makeConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(locationButton)
        view.addSubview(cityTextField)
        view.addSubview(searchButton)
        view.addSubview(temperatureLabel)
        view.addSubview(weatherDescriptionLabel)
        view.addSubview(cityNameLabel)
        view.addSubview(activityIndicator)
        view.addSubview(unitSwitch)
        view.addSubview(errorLabel)
    }
    
    private func makeConstraints() {
        locationButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        cityTextField.snp.makeConstraints { make in
            make.top.equalTo(locationButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(searchButton.snp.leading).offset(-10)
        }
        
        searchButton.snp.makeConstraints { make in
            make.centerY.equalTo(cityTextField)
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo(80)
        }
        
        unitSwitch.snp.makeConstraints { make in
            make.top.equalTo(cityTextField.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
        }
        
        temperatureLabel.snp.makeConstraints { make in
            make.top.equalTo(unitSwitch.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
        }
        
        weatherDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(temperatureLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        cityNameLabel.snp.makeConstraints { make in
            make.top.equalTo(weatherDescriptionLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(cityNameLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    private func setupBindings() {
        viewModel.$weatherData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] weather in
                self?.updateWeatherUI(weather: weather)
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.showError(error)
                } else {
                    self?.hideError()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.handleAuthorizationStatus(status)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    @objc private func locationButtonTapped() {
        viewModel.fetchWeatherForCurrentLocation()
    }
    
    @objc private func searchButtonTapped() {
        guard let city = cityTextField.text, !city.isEmpty else { return }
        viewModel.fetchWeather(for: city)
    }
    
    @objc private func unitSwitchChanged() {
        viewModel.temperatureUnit = TemperatureUnit.allCases[unitSwitch.selectedSegmentIndex]
    }
    
    // MARK: - UI Updates
    private func updateWeatherUI(weather: WeatherResponse?) {
        guard let weather = weather else {
            temperatureLabel.text = "-"
            weatherDescriptionLabel.text = "Нет данных"
            cityNameLabel.text = ""
            return
        }
        
        temperatureLabel.text = "\(Int(weather.main.temp))\(viewModel.temperatureUnit.rawValue)"
        weatherDescriptionLabel.text = weather.weather.first?.description.capitalized
        cityNameLabel.text = weather.name
    }
    
    private func showError(_ error: Error) {
        errorLabel.text = error.localizedDescription
        errorLabel.isHidden = false
    }
    
    private func hideError() {
        errorLabel.isHidden = true
    }
    
    private func handleAuthorizationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .denied, .restricted:
            showLocationAccessDeniedAlert()
        default:
            break
        }
    }
    
    private func showLocationAccessDeniedAlert() {
        let alert = UIAlertController(
            title: "Нет достуступа к геолокации",
            message: "Пожалуйста, перейдите в настройки и разрешите приложению доступ к геолокации",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "В настройки", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        
        present(alert, animated: true)
    }
}
