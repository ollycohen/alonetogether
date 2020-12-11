//
//  RegisterUserViewController.swift
//  AloneTogether
//
//  Created by Benjamin Faber on 11/29/20.
//  Copyright © 2020 Oliver K Cohen. All rights reserved.
//

import UIKit
import FirebaseAuth
import CoreLocation
import FirebaseDatabase
class RegisterUserViewController: UIViewController,CLLocationManagerDelegate {

    //Global variables_start
    let locationManager = CLLocationManager()
    var rHuman = Human()
    var userAdded:Bool = false
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var fName: UITextField!
    
    @IBOutlet weak var lName: UITextField!
    
    @IBOutlet weak var phone: UITextField!
    
    @IBOutlet weak var pw_0: UITextField!
    
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
        guard let em = email.text, !em.isEmpty,
              let pw = pw_0.text, !pw.isEmpty,
              let fN = fName.text, !fN.isEmpty,
              let lN = lName.text, !lN.isEmpty,
              let ph = phone.text, !ph.isEmpty
        else{
            print("missing a field");
            return;
        }
        Auth.auth().createUser(withEmail: em, password:pw) { [self] (result, err) in
            if err != nil{
                print("something went wrong when registering user");
                print(err as Any)
            }
            else{
                print("assume user added")
                var ref: DatabaseReference!

                 ref = Database.database().reference()
                ref.child("users").child((result?.user.uid)! as String).setValue(["email":em, "firstName": fN, "lastName":lN,"phone":ph,"city":self.rHuman.city,"country":self.rHuman.country,"uid":result?.user.uid as Any,"TotalMindfulTime":0,"TotalGives":0,"TotalRecieves":0,"guest":false,"latitude":rHuman.user_coord.latitude, "longitude":rHuman.user_coord.longitude])
                
                let defaults = UserDefaults.standard
                defaults.set(true, forKey: "loggedIn")
                defaults.set(result?.user.uid ?? "Error. No user ID found.", forKey: "userID")
                
                userAdded = true
                ///PERFRORM SEGUE
                print("Let's see if we got the location: ", rHuman.user_coord)
                self.performSegue(withIdentifier: "RegtoMain", sender: self)
                
            }
        }
        
    }
    
    //SEND USER DATA VIA SEGUE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? Main_ViewController
        else {
            return
        }

        destination.human = Human(name: fName.text ?? "nadia", city: rHuman.city, country: rHuman.country, user_coord: self.rHuman.user_coord, guest: true)
    
    }
    
    //ACCESS LOCATION DATA
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0];
        rHuman.user_coord=location.coordinate
        //print(location);
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
                            self.rHuman.city = myCity
                            
                            //print(self.city)
                        }
                        // Zip code
                        if let zip = placeMark.isoCountryCode {
                            self.rHuman.country = zip
                            //print(self.country)
                        }
                        // Country
                        if let myCountry = placeMark.country {
                            //print(myCountry)
                        }
            
                })
        
//        if (userAdded){
//            ///PERFRORM SEGUE
//            self.performSegue(withIdentifier: "RegtoMain", sender: self)
//         }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
