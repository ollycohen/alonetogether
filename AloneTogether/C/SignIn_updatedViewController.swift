//
//  SignIn_updatedViewController.swift
//  AloneTogether
//
//  Created by Benjamin Faber on 11/29/20.
//  Copyright © 2020 Oliver K Cohen. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import CoreLocation
class SignIn_updatedViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    var sHuman:Human = Human()
    var loginSuccess : Bool = false
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var pw: UITextField!
    
    @IBOutlet weak var go_btn: UIButton!
    
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
    
    @IBAction func go_pressed(_ sender: Any) {
        self.loginSuccess = login()
    }
    
    func login() -> Bool {
        var logHumanIn:Bool = false
        guard let myEmail = email.text, !myEmail.isEmpty,
              let myPw = pw.text, !myPw.isEmpty
        else{
            print("missing field")
            logHumanIn = false
            return logHumanIn
        }
        
        print("OVer here B0!!")
        
       
        Auth.auth().signIn(withEmail: myEmail, password: myPw,completion :{result,error in
            if error == nil{
                logHumanIn = true;
                
                print("user logged in")
                
                
                let defaults = UserDefaults.standard
                defaults.set(true, forKey: "loggedIn")
                defaults.set(result?.user.uid ?? "Error. No user ID found.", forKey: "userID")

                self.sHuman.userId = result?.user.uid as Any
                print(self.sHuman.userId)
                //var ref: DatabaseReference!

                let ref = Database.database().reference(withPath: "users/"+(self.sHuman.userId as! String))
                ref.observe(.value, with: {
                    snapshot in
                       
                    print(snapshot.childSnapshot(forPath: "firstName").value as Any)
                    self.sHuman.name = snapshot.childSnapshot(forPath: "firstName").value as Any as! String
                    
                    //update registered user loc on sign-in
                    ref.child("country").setValue(self.sHuman.country)
                    ref.child("city").setValue(self.sHuman.city)
                    ref.child("coordinates").setValue(self.sHuman.user_coord)
                    //self.performSegue(withIdentifier: "upSigntoMain", sender: self)
                })
            }
            else{
                print("something went wrong when logging in user");
                logHumanIn = false
                print(error as Any)
            }
            
        })
        return logHumanIn
    }
 

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       // login()
        guard let destination = segue.destination as? Main_ViewController
        else {
            return
        }
        if(loginSuccess == false){
            return
            
        }
        destination.human = Human(name: self.sHuman.name, city: self.sHuman.city, country: self.sHuman.country, user_coord: self.sHuman.user_coord, guest: false)
    
    }
    //ACCESS LOCATION DATA
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0];
        sHuman.user_coord = location.coordinate
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
                            self.sHuman.city = myCity
                            
                            //print(self.city)
                        }
                        // Zip code
                        if let zip = placeMark.isoCountryCode {
                            self.sHuman.country = zip
                            //print(self.country)
                        }
                        // Country
                        if let myCountry = placeMark.country {
                            //print(myCountry)
                        }
            
                })
        
        if (loginSuccess){
            self.performSegue(withIdentifier: "upSigntoMain", sender: self)
        }
        
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
