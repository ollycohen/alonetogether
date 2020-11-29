//
//  Main_ViewController.swift
//  AloneTogether
//
//  Created by Benjamin Faber on 11/20/20.
//  Copyright © 2020 Oliver K Cohen. All rights reserved.
//

import UIKit
import FirebaseDatabase
class Main_ViewController: UIViewController {
    
    //global variables_start
    var ref = Database.database().reference()
    var name: String="";
    //var onlineID: String="";
    var city : String="";
    var state: String="";
    var country : String="";
   
    var give_recieve_pressed : Bool = false;
    
    
    //global variables_end
    
    //VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        print ( name+" says hello from " + city + " , " + country)
        // Do any additional setup after loading the view.
    }
    
    //GIVE PRESSED
    @IBAction func givePressed(_ sender: Any) {
        if give_recieve_pressed { //need to update after 24 hours
            return
        }
        give_recieve_pressed = true
        let data = ["time": ServerValue.timestamp(), "user": name,"city": city, "country": country] as [String : Any]
        ref.child("Active_Gives").childByAutoId().setValue(data)
        print("give pressed")
        
       // var refData = ref.child("Active_Recieves").queryOrdered(byChild:"time").observeSingleEvent(of: <#T##DataEventType#>, with: <#T##(DataSnapshot) -> Void#>)
       
        
    }
    //RECIEVE PRESSED
    @IBAction func recievePressed(_ sender: Any) {
        if give_recieve_pressed {
            return
        }
        give_recieve_pressed = true
        let data = ["time": ServerValue.timestamp(), "user": name,"city": city, "country": country] as [String : Any]
        ref.child("Active_Recieves").childByAutoId().setValue(data)
        print("recieved pressed")
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
