//
//  ViewController.swift
//  Example
//
//  Created by 渡部 陽太 on 2020/03/30.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit

protocol WeatherModel {
    func fetchWeather(at area: String, date: Date, completion: @escaping (Result<Response, WeatherError>) -> Void)
}

protocol DisasterModel {
    func fetchDisaster(completion: ((String) -> Void)?)
}

class WeatherViewController: UIViewController {
    
    var weatherModel: WeatherModel!
    var disasterModel: DisasterModel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var disasterLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let center = NotificationCenter.default
        center.addObserver(forName: UIApplication.didBecomeActiveNotification,
                           object: nil,
                           queue: nil) { [weak self] _ in
            guard let self = self else {
                return
            }
            self.loadWeather()
        }
        center.removeObserver(UIApplication.didBecomeActiveNotification)
    }
    
    deinit {
        print(#function)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadWeather()
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func reloadButton(_ sender: Any?) {
        self.loadWeather()
    }
    
    func loadWeather() {
        self.activityIndicator.startAnimating()
        self.weatherModel.fetchWeather(at: "tokyo", date: Date()) { result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                self.activityIndicator.stopAnimating()
                self.handleWeather(result: result)
            }
        }
        disasterModel.fetchDisaster { (disaster) in
            self.disasterLabel.text = disaster
        }
    }
    
    func handleWeather(result: Result<Response, WeatherError>) {
        switch result {
        case .success(let response):
            self.weatherImageView.set(weather: response.weather)
            self.minTempLabel.text = String(response.minTemp)
            self.maxTempLabel.text = String(response.maxTemp)
            
        case .failure(let error):
            let message: String
            switch error {
            case .jsonEncodeError:
                message = "Jsonエンコードに失敗しました。"
            case .jsonDecodeError:
                message = "Jsonデコードに失敗しました。"
            case .unknownError:
                message = "unknownエラーが発生しました。"
            case .invalidError:
                message = "invalidエラーが発生しました。"
            case .other:
                message = "otherエラーが発生しました。"
            }
            let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
            showApiErrorAlert(title: "Error", message: message, action: confirmAction)
        }
    }
    
    func showApiErrorAlert(title: String, message: String, action: UIAlertAction) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
}

private extension UIImageView {
    func set(weather: Weather) {
        switch weather {
        case .sunny:
            self.image = UIImage(named: "Sunny")
            self.tintColor = UIColor(named: "Red")
        case .cloudy:
            self.image = UIImage(named: "Cloudy")
            self.tintColor = UIColor(named: "Gray")
        case .rainy:
            self.image = UIImage(named: "Rainy")
            self.tintColor = UIColor(named: "Blue")
        }
    }
}
