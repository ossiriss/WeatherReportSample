//
//  LocationData.swift
//  WeatherReport
//
//  Created by  Boris Estrin on 25/05/2018.
//  Copyright © 2018  Boris Estrin. All rights reserved.
//

import Foundation
class LocationData {
    let name:String!
    let curentTemperature:Int!
    let maxTemperature:Int!
    let minTempereture:Int!
    let humidity:Int!
    let condition:String!
    let sunrise:String!
    let sunset:String!
    let id:Int!
    var currentLocation = false
    var expanded = false
    
    init(name:String, curentTemperature:Int, maxTemperature:Int, minTempereture:Int, humidity:Int, condition:String, sunrise:String, sunset:String, id:Int) {
        self.name = name
        self.maxTemperature = maxTemperature
        self.minTempereture = minTempereture
        self.humidity = humidity
        self.condition = condition
        self.sunrise = sunrise
        self.sunset = sunset
        self.curentTemperature = curentTemperature
        self.id = id
    }
}
