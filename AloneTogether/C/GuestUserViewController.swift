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
    @IBOutlet weak var gueset_name: UITextField!
    var city: String = ""
    var country : String = ""

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
        
             
                 print("assume guest user added")
                 var ref: DatabaseReference!

                  ref = Database.database().reference()
                 ref.child("guest_users").child(name).setValue(["name": name, "city":self.city,"country":self.country,"uid":nil,"guest":true])
                 
                 ///PERFRORM SEGUE
                 self.performSegue(withIdentifier: "GuesttoMain", sender: self)

         
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       // login()
        guard let destination = segue.destination as? Main_ViewController
        else {
            return
        }
        /*if(loginSuccess == false){
            return
            
        }
         */
        destination.name = self.gueset_name.text ?? "guest"
        destination.city = self.city
        destination.country = self.country
        //destination.userId = nil
        
        destination.guest = true
    }
    
    //ACCESS LOCATION DATA
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var location = locations[0];
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
