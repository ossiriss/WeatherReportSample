//
//  NetworkManager.swift
//  WeatherReport
//
//  Created by  Boris Estrin on 25/05/2018.
//  Copyright © 2018  Boris Estrin. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NetworkManager {
    static func getCurrentWeatherForLocation(lon:Double, lat:Double, completion: @escaping (_ data: LocationData?)->Void){
        var urlString = URLs.openWeatherMainUrl + URLProperties.currentWeather
        urlString += String(format: "lat=%f&lon=%f", lat, lon)
        urlString += URLProperties.metricUnits
        urlString += URLProperties.APPID
        
        Alamofire.request(urlString).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            guard let result = response.result.value else{
                completion(nil)
                return
            }
            print("JSON: \(result)")
            
            completion(parseResult(json: JSON(result)))
        }
        
    }
    
    static func getCurrentWeatherForCity(city:String, completion: @escaping (_ data: LocationData?)->Void){
        var urlString = URLs.openWeatherMainUrl + URLProperties.currentWeather
        urlString += String(format: "q=%@", city)
        urlString += URLProperties.metricUnits
        urlString += URLProperties.APPID
        
        Alamofire.request(urlString).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            guard let result = response.result.value else{
                completion(nil)
                return
            }
            print("JSON: \(result)")
            
            completion(parseResult(json: JSON(result)))
        }
    }
    
    static func parseResult(json:JSON)->LocationData?{
        if  let cityName = json["name"].string,
            let currentTemperature = json["main"]["temp"].double,
            let maxTemperature = json["main"]["temp_max"].double,
            let minTemperature = json["main"]["temp_min"].double,
            let humidity = json["main"]["humidity"].int,
            let condition = json["weather"][0]["description"].string,
            let sunrise = json["sys"]["sunrise"].double,
            let sunset = json["sys"]["sunset"].double,
            let id = json["id"].int
        {
            print(cityName)
            print(currentTemperature)
            print(maxTemperature)
            print(minTemperature)
            print(humidity)
            print(condition)
            print(sunrise)
            print(sunset)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            
            return LocationData(name: cityName, curentTemperature: Int(currentTemperature), maxTemperature: Int(maxTemperature), minTempereture: Int(maxTemperature), humidity: humidity, condition: condition, sunrise: formatter.string(from: Date(timeIntervalSince1970: sunrise)) , sunset: formatter.string(from: Date(timeIntervalSince1970: sunset)), id: id)
        } else{
            return nil
        }
    }
    
    
    
    
    
    
    
    
    
    
    
}
