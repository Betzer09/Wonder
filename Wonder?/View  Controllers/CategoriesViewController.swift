//
//  WatchTabViewController.swift
//  Wonder?
//
//  Created by Austin Betzer on 12/4/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class CategoriesViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - Properties
    var locationManager = CLLocationManager()
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpCLLocationManager()
        self.locationManager.startUpdatingLocation()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Actions

    
    // MARK: - Functions
    private func setUpCLLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - CLLocation Delegates
     func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            NSLog("We have permission to use their location ")
            
            guard let userLocation = locationManager.location else {return}
            CLGeocoder().reverseGeocodeLocation(userLocation, completionHandler: { (placemarks, error) in
                
                if let error = error {
                    NSLog("Error getting the zip code: \(error.localizedDescription) in function: \(#function) ")
                }
                
                
                guard let placemark = placemarks?.first, let zip = placemark.postalCode else {return}
                
                let lat = userLocation.coordinate.latitude
                let long = userLocation.coordinate.longitude
                
                UserLocationController.shared.createLocationWith(lat: lat , long: long, zip: zip)
                self.locationManager.stopUpdatingLocation()
            })

        }
        
        if status == .denied {
            let alert = UIAlertController(title: "Warning!", message: "By now allowing the use of your location the application will not be able to display resluts!", preferredStyle: .alert)
            
            let goToSettingsAction = UIAlertAction(title: "Go To Settings", style: .default, handler: { (_) in
                guard let settingsURL = URL(string: UIApplicationOpenSettingsURLString) else {return}
                
                if UIApplication.shared.canOpenURL(settingsURL) {
                    UIApplication.shared.open(settingsURL, completionHandler: { (success) in
                        NSLog("Settins opened: \(success)")
                    })
                }
            })
            alert.addAction(goToSettingsAction)
            present(alert, animated: true, completion: nil)
            
        }
        
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else { return }
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if (error != nil) {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            if (placemarks?.count)! > 0 {

//                print("placemarks",placemarks ?? 0)
                let pm = placemarks?[0]
                self.updateUserLocation(pm)
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    

    
    func updateUserLocation(_ placemark: CLPlacemark? ) {
        guard let placemark = placemark else {return}
            
        locationManager.stopUpdatingLocation()
        guard let postalCode = placemark.postalCode,
        let long = placemark.location?.coordinate.longitude,
            let lat = placemark.location?.coordinate.latitude else {return}
        
        UserLocationController.shared.update(lat: lat, long: long, zip: postalCode)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location " + error.localizedDescription)
    }
}
