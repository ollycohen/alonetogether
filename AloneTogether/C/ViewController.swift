//
//  ViewController.swift
//  AloneTogether
//
//  Created by Oliver K Cohen on 11/15/20.
//  Copyright © 2020 Oliver K Cohen. All rights reserved.
//

import UIKit
//WELCOME PAGE
import CoreLocation
import FirebaseDatabase
class ViewController: UIViewController, CLLocationManagerDelegate{
    
    //global variables_start
    var ref = Database.database().reference()
    let locationManager = CLLocationManager()
    @IBOutlet weak var name: UITextField! //UI text field from storyboard
    var city: String = ""
    var country : String = ""
    var user_coord = CLLocationCoordinate2D();
    var loggedIn:Bool = false
    //global variables_end
    
    //VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self;
        locationManager.requestWhenInUseAuthorization();
        locationManager.startUpdatingLocation();
        // Do any additional setup after loading the view.
        // First Commit - Benjamin
        
        let defaults = UserDefaults.standard
        loggedIn = defaults.bool(forKey: "loggedIn")
        
    }
    //START PRESSED
    @IBAction func startPressed(_ sender: Any) {
        print(city)
        print (country)
        
        //add user to database
        ref.child("currently online").child(self.name.text ?? "nads").child("name").setValue(self.name.text ?? "nads")
        ref.child("currently online").child(self.name.text ?? "nads").child("city").setValue(city ?? "STL")
        ref.child("currently online").child(self.name.text ?? "nads").child("country").setValue(country ?? "US")

    }
    //ACCESS LOCATION DATA
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var location = locations[0];
        self.user_coord = location.coordinate
        print("Update location.coordinate in view controller is", user_coord)
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler:
        {
                        placemarks, error -> Void in

                        // Place details
                        guard let placeMark = placemarks?.first else { return }

                        // Location name
                        if let locationName = placeMark.location {
                           // print(locationName)
                        }
                        // Street address
                        if let street = placeMark.thoroughfare {
                           // print(street)
                        }
                        // City
                        if let myCity = placeMark.subAdministrativeArea {
                            self.city = myCity
                            
                            //print(self.city)
                        }
                        // Zip code
                        if let zip = placeMark.isoCountryCode {
                            self.country = zip
                            //print(self.country)
                        }
                        // Country
                        if let myCountry = placeMark.country {
                            //print(myCountry)
                        }
            
                })
        checkForLogin()
    }
    
    //SEND USER DATA VIA SEGUE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? Main_ViewController
        else {
            return
        }
//        if let theName = name.text {
//            destination.name = theName
//        } else {
//            destination.name = "Human"
//        }
        destination.name = "Human"
        destination.city = self.city
        destination.country = self.country
        destination.user_coord = user_coord
        print("My ViewController Coordinates are,", user_coord)
    }
    
    func checkForLogin(){
        if(loggedIn){
                print("Previous user login detected. User automatically segued to new view.")
                performSegue(withIdentifier: "welcomeToMain", sender: nil)
                loggedIn = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          hideNavigationBar(animated: animated)
      }

      override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
          showNavigationBar(animated: animated)
      }
    
}

