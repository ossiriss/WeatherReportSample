//
//  Constants.swift
//  WeatherReport
//
//  Created by  Boris Estrin on 25/05/2018.
//  Copyright © 2018  Boris Estrin. All rights reserved.
//

import Foundation
struct Keys {
    static let weatherAPIKey = "cc774bcd7c2495cd9375d59e6ce3cae6"
}

struct URLs {
    static let openWeatherMainUrl = "https://api.openweathermap.org/data/2.5/"
    
}

struct URLProperties {
    static let currentWeather = "weather?"
    static let metricUnits = "&units=metric"
    static let APPID = "&APPID=" + Keys.weatherAPIKey
}
