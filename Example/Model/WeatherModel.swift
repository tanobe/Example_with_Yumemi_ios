//
//  WeatherModel.swift
//  Example
//
//  Created by 渡部 陽太 on 2020/04/01.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import Foundation
import YumemiWeather

class WeatherModelImpl: WeatherModel {
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return dateFormatter
    }()
    
    func jsonString(from request: Request) throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        
        let requestData = try encoder.encode(request)
        guard let requestJsonString = String(data: requestData, encoding: .utf8) else {
            throw WeatherError.jsonEncodeError
        }
        return requestJsonString
    }
    
    func response(from jsonString: String) throws -> Response {
        guard let responseData = jsonString.data(using: .utf8) else {
            throw WeatherError.jsonDecodeError
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(Response.self, from: responseData)
    }
    
    func fetchWeather(at area: String, date: Date, completion: @escaping (Result<Response, WeatherError>) -> Void) {
        
        DispatchQueue.global().async {
            do {
                let request = Request(area: area, date: date)
                guard let requestJson = try? self.jsonString(from: request) else {
                    return completion(.failure(WeatherError.jsonEncodeError))
                }
                let weather = try YumemiWeather.syncFetchWeather(requestJson)
                guard let response = try? self.response(from: weather) else {
                    return completion(.failure(WeatherError.jsonDecodeError))
                }
                return completion(.success(response))
                
            } catch YumemiWeatherError.invalidParameterError {
                return completion(.failure(.invalidError))
            } catch YumemiWeatherError.unknownError {
                return completion(.failure(.unknownError))
            } catch {
                return completion(.failure(.other))
            }
        }
    }
}
