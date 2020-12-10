//
//  Main_ViewController.swift
//  AloneTogether
//
//  Created by Benjamin Faber on 11/20/20.
//  Copyright © 2020 Oliver K Cohen. All rights reserved.
//

import UIKit
import FirebaseDatabase
import MapKit
class Main_ViewController: UIViewController {
    @IBOutlet weak var bodybtn: UIButton!
    @IBOutlet weak var mindbtn: UIButton!
    @IBOutlet weak var causebtn: UIButton!
    @IBOutlet weak var givebtn: UIButton! //GIVE BTN IS START BTN
    @IBOutlet weak var welcomeLabel: UILabel!
    
    var progress = Progress()
    
    //global variables_start

    var name: String="";
    //var onlineID: String="";
    var city : String="";
    var state: String="";
    var country : String="";
    var userId: Any = "";
    var user_coord = CLLocationCoordinate2D(); //HEY OLLY OVER HERE!!!
    var guest : Bool = false;
    var give_recieve_pressed : Bool = false;
    var secondsLeft = 0
    var minutesLeft = 0
    //var userFirstName:String = ""
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerSlider: UISlider!
    @IBOutlet weak var progressBar: UIProgressView!
    
    struct connection{
        var other_city : String = ""
        var other_country : String = ""
        var other_user : String = ""
        var other_guest : Bool =  false
        var other_uid : Any = ""
        var request_id : String = ""
    }
    var other_person = connection() //person connected with in give or recieve
    
    
    
    //global variables_end
    
    //VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        print ( name+" says hello from " + city + " , " + country)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mindbtn.titleLabel?.doGlowAnimation(withColor: UIColor.yellow)
        bodybtn.titleLabel?.doGlowAnimation(withColor: UIColor.yellow)
        causebtn.titleLabel?.doGlowAnimation(withColor: UIColor.yellow)
        givebtn.titleLabel?.doGlowAnimation(withColor: UIColor.yellow)
        //receivebtn.titleLabel?.doGlowAnimation(withColor: UIColor.yellow)
        
        // Set "Title" at the top of the view to either say "Welcome, {Name}" or "Welcome, Guest".
        
        let defaults = UserDefaults.standard
        let loggedIn = defaults.bool(forKey: "loggedIn")
        let userID = defaults.string(forKey: "userID")
        
        
        
        if (loggedIn){
            let ref = Database.database().reference()
            ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
              // Get user value
                    
            let value = snapshot.value as? NSDictionary
            self.welcomeLabel.text = "Welcome, \(value?["firstName"] as? String ?? "")"
            
                
              // ...
              }) { (error) in
                print(error.localizedDescription)
            }

        }
        else{
            self.welcomeLabel.text = "Welcome, Guest"
        }
    
        //welcomeLabel.text = "Welcome, \(userFirstName)"
        
    }
    
    @IBAction func timerSetSlider(_ sender: UISlider)
    {
        sender.setValue(sender.value.rounded(.down), animated: false)
        timerLabel.text = "\(Int(timerSlider.value)):00"
    }
    
    //GIVE PRESSED
    //GIVE PRESSED
    @IBAction func givePressed(_ sender: Any) {
        var ref = Database.database().reference()
        if give_recieve_pressed { //need to update after 24 hours
            //button already pushed
            return
        }
        give_recieve_pressed = true
        //updload give user data
        let data = ["time": ServerValue.timestamp(), "user": name,"city": city, "country": country,"uid":userId,"guest":guest] as [String : Any]
        var giver_request_id = ref.child("Active_Gives").childByAutoId()
        giver_request_id.setValue(data)
        print("give pressed")
        
        //query for first Active Recieved
        var recieveRef = Database.database().reference(withPath: "Active_Recieves").queryOrdered(byChild: "time").queryLimited(toFirst: 1).observeSingleEvent(of: .value) { (snapshot) in
            
            if(snapshot.value == nil ){
                print("no recieves exist")
                return
            }
            
            var dict: NSDictionary = ["":""]
            for case let childSnap as DataSnapshot in snapshot.children {
                dict = childSnap.value as? NSDictionary ?? ["":""]
                self.other_person.request_id = childSnap.key
                if(childSnap.key == nil){
                    
                    return
                }
            }
            //print(dict["user"] as Any)
            self.other_person.other_user = dict["user"] as? String ?? "nil"
            self.other_person.other_uid = dict["uid"]as? String ?? "nil"
            self.other_person.other_city = dict["city"] as? String ?? "nil"
            self.other_person.other_country = dict["country"] as? String ?? "nil"
            self.other_person.other_guest = (dict["guest"] != nil)
           // print(dict)
            
            print(self.other_person.request_id)
            //delete recieve and give pair
            //print(snapshot)

            //print(snapshot.key)
            //print(snapshot.value)
            if(self.other_person.request_id != ""){
                print("Giving Meditation/ Healing to " + self.other_person.other_user + ", from " + self.other_person.other_city + ", " + self.other_person.other_country)
                print("HEY LISTEN OVER HERE B")
                ref.child("Active_Recieves").child(self.other_person.request_id).setValue(nil)
                
                giver_request_id.setValue(nil)
                self.give_recieve_pressed = false
                
            }
            
            //print(self.other_person.request_id)
            
            
            //if the give/ recieve are registered users, update their stats
            return
            
        }
        minutesLeft = Int(timerSlider.value)
        secondsLeft = 0
        progress = Progress(totalUnitCount: Int64(timerSlider.value * 60))
        timerSlider.isHidden = true
        givebtn.isHidden = true
        progressBar.isHidden = false
        
        print("total unit count: \(Int64(timerSlider.value * 60))")
        print("timerSlider.value = \(timerSlider.value)")
        
        runTimer()
    }
    
    func runTimer(){
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ [self] (timer) in
            
            guard progress.isFinished == false else {
                timer.invalidate()
                
                minutesLeft = Int(timerSlider.value)
                secondsLeft = 0
                timerSlider.isHidden = false
                givebtn.isHidden = false
                progressBar.isHidden = true
                
                return
            }
            
            progress.completedUnitCount += 1
            let progressFloat = Float(self.progress.fractionCompleted)
            progressBar.setProgress(progressFloat, animated: true)
            
            if(secondsLeft == 0){
                secondsLeft = 59
                minutesLeft -= 1
            }
            else{
                secondsLeft -= 1
            }
            
            if (secondsLeft < 10){
                timerLabel.text = "\(minutesLeft):0\(secondsLeft)"
            }
            else{
                timerLabel.text = "\(minutesLeft):\(secondsLeft)"
            }
            
            
        }
    }
    
    //RECIEVE PRESSED
//    @IBAction func recievePressed(_ sender: Any) {
//        var ref = Database.database().reference()
//        if give_recieve_pressed {
//            //button already pushed
//            return
//        }
//        give_recieve_pressed = true
//        let data = ["time": ServerValue.timestamp(), "user": name,"city": city, "country": country,"uid":userId,"guest":guest] as [String : Any]
//        var reciever_request_id = ref.child("Active_Recieves").childByAutoId()
//
//        reciever_request_id.setValue(data)
//        print("recieved pressed")
//
//        //query for first Active Give
//        var giveRef = Database.database().reference(withPath: "Active_Gives").queryOrdered(byChild: "time").queryLimited(toFirst: 1).observeSingleEvent(of: .value) { (snapshot) in
//            //var result = snapshot
//
//            var dict: NSDictionary = ["":""]
//            for case let childSnap as DataSnapshot in snapshot.children {
//                dict = childSnap.value as? NSDictionary ?? ["":""]
//                self.other_person.request_id = childSnap.key
//                if(childSnap.key == nil){
//
//                    return
//                }
//            }
//            //print(dict["user"] as Any)
//            self.other_person.other_user = dict["user"] as? String ?? "nil"
//            self.other_person.other_uid = dict["uid"]as? String ?? "nil"
//            self.other_person.other_city = dict["city"] as? String ?? "nil"
//            self.other_person.other_country = dict["country"] as? String ?? "nil"
//            self.other_person.other_guest = (dict["guest"] != nil)
//           // print(dict)
//
//            //print(self.other_person)
//            //delete recieve and give pair
//            //print(snapshot)
//
//            //print(snapshot.key)
//            //print(snapshot.value)
//            if(self.other_person.request_id != ""){
//                print("Recieving Meditation/ Healing from " + self.other_person.other_user + ", in " + self.other_person.other_city + ", " + self.other_person.other_country)
//                print("HEY LISTEN OVER HERE B")
//                print(self.other_person.request_id)
//                ref.child("Active_Gives").child(self.other_person.request_id).setValue(nil)
//                reciever_request_id.setValue(nil)
//                self.give_recieve_pressed = false
//            }
//
//            //print(self.other_person.request_id)
//
//
//            //if the give/ recieve are registered users, update their stats
//            return
//
//        }
//
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
