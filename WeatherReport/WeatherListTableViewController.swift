//
//  WeatherListTableViewController.swift
//  WeatherReport
//
//  Created by  Boris Estrin on 25/05/2018.
//  Copyright © 2018  Boris Estrin. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherListTableViewController: UITableViewController, CLLocationManagerDelegate {
    var locationsList = [LocationData]()
    let locationManager = CLLocationManager()
    var requestsCount = 0
    var showingAlert = false
    var emptyView:UILabel?

    @IBAction func addButtonClicked(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Location", message: "Enter City Name", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "city name"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            print("Text field: \(String(describing: textField?.text))")
            if textField?.text == ""{
                let alert = UIAlertController(title: "Error", message: "City name cannot be empty", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
            }else{
                self.addCityLocation(city: (textField?.text!)!)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 44.0;
        
        updateLocation()
        addSampleLocations()
        
        refreshControl = UIRefreshControl()
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(self.refreshControl!)
        }
        
        //locationsList.append(LocationData(name: "TestCity", curentTemperature: 31, maxTemperature: 33, minTempereture: 25, humidity: 50, condition: "good", sunrise: "12:00", sunset: "18:00", id: 5))
        
        refreshControl?.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
    }
    
    func addSampleLocations(){
        addCityLocation(city: "Moscow")
        addCityLocation(city: "Tel Aviv")
        addCityLocation(city: "New York")
    }
    
    func addCityLocation(city:String){
        requestsCount += 1
        let escapedString = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        NetworkManager.getCurrentWeatherForCity(city: escapedString!) { data, notFound in
            self.requestsCount -= 1
            
            if notFound{
                self.showCityNotFoundError(cityName: city)
                return
            }
            
            if let locationData = data{
                locationData.currentLocation = false
                self.locationsList = self.locationsList.filter{ $0.id != locationData.id}
                self.locationsList.append(locationData)
                
                self.checkAndEndRefresh()
            } else{
                self.showInternetUnreachable()
            }
        }
    }
    
    func showCityNotFoundError(cityName: String){
        let alert = UIAlertController(title: "Error", message: "City \(cityName) not found", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {_ in
            
        }))
        self.present(alert, animated: true, completion: {
            
        })
    }
    
    func updateLocation(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.delegate = nil
        manager.stopUpdatingLocation()
        
        let userLocation:CLLocation = locations[0] as CLLocation
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        self.requestsCount += 1
        NetworkManager.getCurrentWeatherForLocation(lon: userLocation.coordinate.longitude, lat: userLocation.coordinate.latitude) { locationData in
            self.requestsCount -= 1
            if let locationData = locationData{
                locationData.currentLocation = true
                self.locationsList = self.locationsList.filter{ $0.id != locationData.id}
                self.locationsList.insert(locationData, at: 0)
                //self.tableView.reloadData()
                
                self.checkAndEndRefresh()
            } else{
                self.showInternetUnreachable()
            }
        }
    }
    
    func showInternetUnreachable(){
        guard !showingAlert else {
            return
        }
        showingAlert = true
        let alert = UIAlertController(title: "Error", message: "Some error occured. Probably internet unreachable", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {_ in
            self.showingAlert = false
        }))
        self.present(alert, animated: true, completion: {
            self.checkAndEndRefresh()
        })
    }
    
    func checkAndEndRefresh(){
        if requestsCount == 0{
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
            checkForEmptyList()
        }
    }
    
    func checkForEmptyList() {
        if locationsList.isEmpty{
            if emptyView != nil {return}
            
            emptyView = UILabel()
            emptyView?.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(emptyView!)
            emptyView?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            emptyView?.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
            emptyView?.text = "Pull to update"
        } else{
            if let view = emptyView{
                view.removeFromSuperview()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return locationsList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OneLocationCell", for: indexPath) as! OneLocationTableViewCell
        let data = locationsList[indexPath.row]
        
        cell.locationName.text = data.name
        cell.temperatureLabel.text = data.curentTemperature.description + "℃"
        cell.locationIcon.isHidden = !data.currentLocation
        cell.expanded = data.expanded
        cell.minTemperatureLabel.text = "Min: " + data.minTempereture.description + "℃"
        cell.maxTemperatureLabel.text = "Max: " + data.maxTemperature.description + "℃"
        cell.humidityLabel.text = "Humidity: " + data.humidity.description + "%"
        cell.conditionLabel.text = "Condition: " + data.condition
        cell.sunriseLabel.text = "Sunrise: " + data.sunrise
        cell.sunsetLabel.text = "Sunset: " + data.sunset

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let data = locationsList[indexPath.row]
        data.expanded = !data.expanded
        
        UIView.animate(withDuration: 1) {
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
    }
    
    func refreshLocations(){
        for location in locationsList {
            if !location.currentLocation{
                addCityLocation(city: location.name)
            }
        }
    }
    
    @objc func refreshWeatherData(_ sender: Any) {
        updateLocation()
        refreshLocations()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            locationsList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    
}
