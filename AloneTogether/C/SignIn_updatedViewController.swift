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
    
    var city: String = ""
    var country : String = ""
    var userId: Any = ""
    var name : String = ""
    var loginSuccess : Bool = false
    var guest: Bool = false
    var user_coord = CLLocationCoordinate2D(); //HEY OLLY OVER HERE -nads
    
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
        login()
        
    }
    
    func login() -> Bool {
        guard let myEmail = email.text, !myEmail.isEmpty,
              let myPw = pw.text, !myPw.isEmpty
        else{
            print("missing field")
            loginSuccess = false
            return loginSuccess
        }
        
        print("OVer here B0!!")
        
       
        Auth.auth().signIn(withEmail: myEmail, password: myPw,completion :{result,error in
            if error == nil{
                self.loginSuccess = true;
                
                print("user logged in")
                
               
                self.userId = result?.user.uid
                print(self.userId)
                //var ref: DatabaseReference!

                var ref = Database.database().reference(withPath: "users/"+(self.userId as! String))
                ref.observe(.value, with: {
                    snapshot in
                       
                        print(snapshot.childSnapshot(forPath: "firstName").value as Any)
                    self.name = snapshot.childSnapshot(forPath: "firstName").value as Any as! String
                    
                    //update registered user loc on sign-in
                    ref.child("country").setValue(self.country)
                    ref.child("city").setValue(self.city)
                    ref.child("lat").setValue(self.user_coord.latitude)
                    ref.child("long").setValue(self.user_coord.longitude)
                    self.performSegue(withIdentifier: "upSigntoMain", sender: self)
                    
                    
                })

                
            }
            else{
                print("something went wrong when logging in user");
                self.loginSuccess = false
                print(error as Any)
                
            }
            
        })
       
        return loginSuccess;
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
        destination.name = self.name
        destination.city = self.city
        destination.country = self.country
        destination.userId = self.userId
        destination.guest = false
        destination.user_coord = self.user_coord
    
    }
    //ACCESS LOCATION DATA
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var location = locations[0];
         user_coord = location.coordinate
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
