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
    
    @IBOutlet weak var guestBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    //global variables_start
    var ref = Database.database().reference()
    let locationManager = CLLocationManager()
    @IBOutlet weak var name: UITextField! //UI text field from storyboard
    
    var myHuman:Human = Human()
    var loggedIn:Bool = false
    //global variables_end
    
    //VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        print("WELCOME PAGE LOADED")
        locationManager.delegate = self;
        locationManager.requestWhenInUseAuthorization();
        locationManager.startUpdatingLocation();
        // Do any additional setup after loading the view.
        // First Commit - Benjamin
        signInBtn.layer.cornerRadius = 10.0
        registerBtn.layer.cornerRadius = 10.0
        guestBtn.layer.cornerRadius = 10.0
        let defaults = UserDefaults.standard
        loggedIn = defaults.bool(forKey: "loggedIn")
        myHuman.name = defaults.string(forKey: "name") ?? "hUmAn"
    }
    
//    START PRESSED
    @IBAction func startPressed(_ sender: Any) {
        //add user to database
        ref.child("currently online").child(self.name.text ?? "nads").child("name").setValue(self.name.text ?? "nads")
        ref.child("currently online").child(self.name.text ?? "nads").child("city").setValue("STL")
        ref.child("currently online").child(self.name.text ?? "nads").child("country").setValue(myHuman.country )
    }
    
    //ACCESS LOCATION DATA
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0];
        self.myHuman.user_coord = location.coordinate
        print("Update location.coordinate in view controller is", myHuman.user_coord)
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler:
        {
                        placemarks, error -> Void in

                        // Place details
                        guard let placeMark = placemarks?.first else { return }

                        // City
                        if let myCity = placeMark.subAdministrativeArea {
                            self.myHuman.city = myCity
                            
                            //print(self.city)
                        }
                        // Zip code
                        if let zip = placeMark.isoCountryCode {
                            self.myHuman.country = zip
                            //print(self.country)
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
        destination.human = Human(name: self.myHuman.name, city: self.myHuman.city, country: self.myHuman.country, user_coord: self.myHuman.user_coord, guest:false)
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
    
    @IBAction func unwindToViewController(_ unwindSegue: UIStoryboardSegue) {
//        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    
    
}

