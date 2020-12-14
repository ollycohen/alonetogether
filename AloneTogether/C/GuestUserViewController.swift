//
//  GuestUserViewController.swift
//  AloneTogether
//
//  Created by Benjamin Faber on 11/29/20.
//  Copyright © 2020 Oliver K Cohen. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CoreLocation
class GuestUserViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var sendSegue:Bool = false
    @IBOutlet weak var gueset_name: UITextField!
    var guestHuman = Human()
    override func viewDidLoad() {
        super.viewDidLoad()

        //key board -> tap view escape -nads
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        //location set up -nads
        locationManager.delegate = self;
        locationManager.requestWhenInUseAuthorization();
        locationManager.startUpdatingLocation();
        
    }
    
    @IBAction func goPressed(_ sender: Any) {
        add_guest()
        
    }
    
    
    func add_guest(){
        
         guard let name = gueset_name.text, !name.isEmpty
         else{
             print("missing a field");
             return;
         }
        
             
                 print("assume guest user added named ", name)
                 var ref: DatabaseReference!

                  ref = Database.database().reference()
        ref.child("guest_users").child(name).setValue(["name": name, "city":guestHuman.city,"country":guestHuman.country,"uid":nil,"guest":true,"latitude": guestHuman.user_coord.latitude, "longitude": guestHuman.user_coord.longitude])
        
        ///PERFRORM SEGUE
        self.performSegue(withIdentifier: "GuesttoMain", sender: self)
        sendSegue = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       // login()
        guard let destination = segue.destination as? Main_ViewController
        else {
            return
        }
        destination.human = Human(name: self.gueset_name.text ?? "guest", city: guestHuman.city, country: guestHuman.country, user_coord: guestHuman.user_coord, guest: true)
    }
    
    //ACCESS LOCATION DATA
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0];
        //print(location);
        guestHuman.user_coord=location.coordinate
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler:
        {
                        placemarks, error -> Void in

                        // Place details
                        guard let placeMark = placemarks?.first else { return }

                        // City
                        if let myCity = placeMark.subAdministrativeArea {
                            self.guestHuman.city = myCity
                            //print(self.city)
                        }
                        // Zip code
                        if let zip = placeMark.isoCountryCode {
                            self.guestHuman.country = zip
                            //print(self.country)
                        }
                })
        
    }

}
