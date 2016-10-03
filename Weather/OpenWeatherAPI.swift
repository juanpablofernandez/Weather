//
//  OpenWeatherAPI.swift
//  Weather
//
//  Created by Jay on 10/2/16.
//  Copyright © 2016 Juan Pablo. All rights reserved.
//

import Foundation
import SwiftyJSON

class OpenWeatherAPI {
    
    let appID = "76206cd3a7796e7db880c8385c0786ef"
    
    
    func requestTodaysWeather(city: String, country: String, units: String, completionHandlerFromViewController: @escaping (Weather) -> ()) {
        
        let urlString: String = "http://api.openweathermap.org/data/2.5/weather?q=\(city),\(country)&units=\(units)&APPID=\(appID)"
        let session: URLSession = URLSession.shared
        let url = URL(string: urlString)
        
        let task = session.dataTask(with: url!, completionHandler: { data, response, error -> Void in
            if let actualData = data {
                let json = JSON(data: actualData)
                //                print(json)
                let tempMax = json["main"]["temp_max"].stringValue
                let tempMin = json["main"]["temp_min"].stringValue
                let temp = json["main"]["temp"].stringValue
                let description = json["weather"][0]["description"].stringValue
                //                print(temp)
                //                print (tempMax)
                //                print (tempMin)
                //                print(description)
                let weather = Weather(description: description, minTemperature: tempMin, maxTemperature: tempMax, avgTemperature: temp)
                completionHandlerFromViewController(weather)
            }
            else {
                print("no data received: \(error)")
            }
            
        })
        task.resume()
    }
    
    func requestWeatherForecast(latitude: Double, longitude: Double, units: String, days: Int, completionHandlerForecast: @escaping (Forecast) -> ()) {
        
        let urlString: String = "http://api.openweathermap.org/data/2.5/forecast/daily?lat=\(latitude)&lon=\(longitude)&units=\(units)&cnt=\(days)&APPID=\(appID)"
        
        let session: URLSession = URLSession.shared
        let url = URL(string: urlString)
        
        let task = session.dataTask(with: url!, completionHandler: { data, response, error -> Void in
            if let actualData = data {
                let json = JSON(data: actualData)
                let list = json["list"]
                print(list)
                //                print(json["list"])
                //                print(json["list"][0]["temp"]["max"])
                //                print(json["list"][0]["temp"]["min"])
                //                print(json["list"][0]["weather"][0]["description"])
                //                print(json["list"][0]["weather"][0]["icon"])
                
                let weather = Forecast(forecast: list)
                completionHandlerForecast(weather)
            }
            else {
                print("no data received: \(error)")
            }
            
        })
        task.resume()
    }
}

struct Weather {
    let description: String
    let minTemperature: String
    let maxTemperature: String
    let avgTemperature: String
}

struct Forecast {
    let forecast:JSON
}

