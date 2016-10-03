//
//  MainViewController.swift
//  Weather
//
//  Created by Jay on 10/2/16.
//  Copyright © 2016 Juan Pablo. All rights reserved.
//

import UIKit
import SwiftyJSON
import GooglePlaces
import GoogleMaps
import CoreLocation


class ViewController: UIViewController, UICollectionViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    let weatherAPI = OpenWeatherAPI()
    
    var weatherDescription: String?
    var weatherMaxTemp: Double?
    var weatherMinTemp: Double?
    var weatherIcon: String?
    
    var weatherJSON: JSON!
    
    //User Location:
    var locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //User Location:
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 149/255.0, green: 156/255.0, blue: 165/255.0, alpha: 1)
        
        searchField()
        
    }
    
    func getWeather(latitude: Double, longitude: Double, units: String, days: Int) {
        weatherAPI.requestWeatherForecast(latitude: latitude, longitude: longitude, units: units, days: days, completionHandlerForecast: { forecast in
            
            var maxTemp = forecast.forecast[0]["temp"]["max"].doubleValue
            var minTemp = forecast.forecast[0]["temp"]["min"].doubleValue
            var description = forecast.forecast[0]["weather"][0]["main"].stringValue
            let icon = forecast.forecast[0]["weather"][0]["icon"].stringValue
            self.weatherJSON = forecast.forecast
            maxTemp = Double(round(10*maxTemp)/10)
            minTemp = Double(round(10*minTemp)/10)
            description = description.capitalized
            
            self.weatherDescription = description
            self.weatherMaxTemp = maxTemp
            self.weatherMinTemp = minTemp
            self.weatherIcon = icon
            
            // update UI
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.imageView.image = UIImage(named: icon)
                self.weatherLabel.text = description
                self.tempLabel.text = "\(minTemp)° / \(maxTemp)°"
                self.dateLabel.text = self.getDayOfWeek(self.getDates(value: 0))
            }
            
        })
    }
    
    func getDates(value: Int) -> String {
        let today = NSDate()
        let tomorrow = NSCalendar.current.date(byAdding: .day, value: value, to: today as Date, wrappingComponents: false)
        
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.month, .day, .year], from: tomorrow! as Date)
        
        let year =  components.year
        let month = components.month
        let day = components.day
        let dateArranged = "\(month!)-\(day!)-\(year!)"
        return dateArranged
    }
    
    func getDayOfWeek(_ today:String) -> String? {
        
        let weekdays = [1:"Sunday", 2:"Monday", 3:"Tuesday", 4:"Wednesday", 5:"Thursday", 6:"Friday", 7:"Saturday"]
        
        let formatter  = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        if let todayDate = formatter.date(from: today) {
            let myCalendar = Calendar(identifier: .gregorian)
            let weekDay = myCalendar.component(.weekday, from: todayDate)
            let day = weekdays[weekDay]
            
            return day
        } else {
            return nil
        }
    }
    
    
    func searchField() {
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        // Put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        self.navigationItem.titleView = searchController?.searchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        self.definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let long = location.coordinate.longitude;
            let lat = location.coordinate.latitude;
            print(long)
            print(lat)
            locationManager.stopUpdatingLocation()
            getWeather(latitude: lat, longitude: long, units: "metric", days: 7)
        }
        //Do What ever you want with it
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if weatherMaxTemp != nil && weatherMinTemp != nil {
            return 7
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenWidth = collectionView.bounds.width
        let screenHeight = collectionView.bounds.height
        let size = CGSize.init(width: (screenWidth/4), height: screenHeight)
        
        return size
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        // Configure the cell
        
        if weatherMaxTemp != nil && weatherMinTemp != nil {
            var max = weatherJSON[indexPath.row]["temp"]["max"].doubleValue
            var min = weatherJSON[indexPath.row]["temp"]["min"].doubleValue
            var desc = weatherJSON[indexPath.row]["weather"][0]["main"].stringValue
            let icon = weatherJSON[indexPath.row]["weather"][0]["icon"].stringValue
            
            max = Double(round(10*max)/10)
            min = Double(round(10*min)/10)
            desc = desc.capitalized
            
            cell.cellWeatherLabel.text = desc
            cell.cellTempLabel.text = "\(min)° / \(max)°"
            cell.imageView.image = UIImage(named: icon)
            cell.cellDateLabel.text = getDayOfWeek(getDates(value: indexPath.row))
        }
        
        
        return cell
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


// Handle the user's selection.
extension ViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        print("Place name: ", place.name)
        print("Place address: ", place.formattedAddress)
        print("Place attributions: ", place.attributions)
        print("Place Latitude: ", place.coordinate.latitude)
        print("Place Longitude: ", place.coordinate.longitude)
        
        let latitude = place.coordinate.latitude
        let longitude = place.coordinate.longitude
        self.searchController?.searchBar.text = place.name
        
        
        getWeather(latitude: latitude, longitude: longitude, units: "metric", days: 7)
        collectionView.reloadData()
        
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}


