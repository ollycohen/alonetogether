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
import AVFoundation

extension Main_ViewController: BodyPopDelegate {
    func updateLabel(withText text: String) {
        self.bodybtn.setTitle(text, for: .normal)
    }
}

extension Main_ViewController: HashtagPopDelegate {
    func updateHashtagLab(withText text: String) {
        self.causebtn.setTitle(text, for: .normal)
    }
}

protocol BodyPopDelegate: class {
    func updateLabel(withText text: String)
    }

protocol HashtagPopDelegate: class {
    func updateHashtagLab(withText text: String)
    }






class Main_ViewController: UIViewController {
    //SEGUE TO BODY POPOVER:
    @IBAction func presentActivitiesBtn(_ sender: Any) {
        //presentVC2()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "Load BodyVC") {
            print("Prepare")
            let destination = segue.destination as! BodyPopup_ViewController
            destination.delegate = self
        }
        if (segue.identifier == "Load HashtagVC"){
            print("Prepare")
            let destination = segue.destination as! HashtagsViewController
            destination.delegate = self
        }
    
    }
    
    
    
    
    @IBOutlet weak var bodybtn: UIButton!
    //@IBOutlet weak var mindbtn: UIButton!
    @IBOutlet weak var speakerBtn: UIButton!
    @IBOutlet weak var causebtn: UIButton!
    @IBOutlet weak var givebtn: UIButton! //GIVE BTN IS START BTN
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var theMap: MKMapView!
    var currentKey:DatabaseReference = DatabaseReference()
    var progress = Progress()
    var connectionPath = MKPolyline()
    
    //global variables 
    var human = Human()
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
    let ref = Database.database().reference()
    
    //global variables_end
    
    var backgroundMusic: AVAudioPlayer?
    var soundOn = false
    //VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        print ( human.name+" says hello from " + human.city + " , " + human.country)
        // Do any additional setup after loading the view.
        
        //SOUND FROM https://www.babysleepsite.com/downloads/noise-only.mp3
        let path = Bundle.main.path(forResource: "whiteNoise.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        do {
            backgroundMusic = try AVAudioPlayer(contentsOf: url)
        } catch {
            // couldn't load file :(
        }
        backgroundMusic?.numberOfLoops = -1
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
//        mindbtn.titleLabel?.doGlowAnimation(withColor: UIColor.yellow)
        bodybtn.titleLabel?.doGlowAnimation(withColor: UIColor.yellow)
        causebtn.titleLabel?.doGlowAnimation(withColor: UIColor.yellow)
        givebtn.titleLabel?.doGlowAnimation(withColor: UIColor.yellow)
        //receivebtn.titleLabel?.doGlowAnimation(withColor: UIColor.yellow)
        self.navigationItem.setHidesBackButton(true, animated: false)
        // Set "Title" at the top of the view to either say "Welcome, {Name}" or "Welcome, Guest".
        
        let defaults = UserDefaults.standard
        let loggedIn = defaults.bool(forKey: "loggedIn")
        let userID = defaults.string(forKey: "userID")
        timerSlider.value = 30
        //print("\nMAIN VIEW APPEARED\n")
        
        if (loggedIn){
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
        
        deleteCompletedGives(ref: ref)
        displayAllGivers(ref: ref, theMap: theMap)
    
        //welcomeLabel.text = "Welcome, \(userFirstName)"
        
    }
    
    

    //https://www.hackingwithswift.com/example-code/media/how-to-play-sounds-using-avaudioplayer
    @IBAction func speakerBtnPress(_ sender: Any) {
 
        if !soundOn{
            backgroundMusic?.play()
            soundOn = true
            speakerBtn.setImage(UIImage(systemName: "speaker.wave.2.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
           
            
        } else {
            backgroundMusic?.stop()
            soundOn = false
            speakerBtn.setImage(UIImage(systemName: "speaker.slash.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        }
    }
    
    
    
    
    @IBAction func timerSetSlider(_ sender: UISlider)
    {
        sender.setValue(sender.value.rounded(.down), animated: false)
        timerLabel.text = "\(Int(timerSlider.value)):00"
    }
    
    //GIVE PRESSED
    //GIVE PRESSED
    @IBAction func givePressed(_ sender: Any) {
//        let ref = Database.database().reference()
        if give_recieve_pressed { //need to update after 24 hours
            //button already pushed
            return
        }
        give_recieve_pressed = true
        //upload give user data
        // let timestamp = ServerValue.timestamp(),
        let data = human.makeActiveGiveData(duration: timerSlider.value)
        currentKey = ref.child("Active_Gives").childByAutoId()
        currentKey.setValue(data)
        
        connectAGive(ref: ref, myKey: currentKey.key ?? "None", theMap: theMap, myHuman: human)
        print("give pressed")
        //deleteCompletedGives(ref: ref)
       
        
        
        //query for first Active Recieved
//        var recieveRef = Database.database().reference(withPath: "Active_Recieves").queryOrdered(byChild: "time").queryLimited(toFirst: 1).observeSingleEvent(of: .value) { (snapshot) in
//            
//            if(snapshot.value == nil ){
//                print("no recieves exist")
//                return
//            }
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
//            print(self.other_person.request_id)
//            //delete recieve and give pair
//            //print(snapshot)
//
//            //print(snapshot.key)
//            //print(snapshot.value)
//            if(self.other_person.request_id != ""){
//                print("Giving Meditation/ Healing to " + self.other_person.other_user + ", from " + self.other_person.other_city + ", " + self.other_person.other_country)
//                print("HEY LISTEN OVER HERE B")
//                ref.child("Active_Recieves").child(self.other_person.request_id).setValue(nil)
//                
//                giver_request_id.setValue(nil)
//                self.give_recieve_pressed = false
//                
//            }
//            
//            //print(self.other_person.request_id)
//            
//            
//            //if the give/ recieve are registered users, update their stats
//            return
//            
//        }
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
                
//                print("Should delete this key: ", currentKey)
                currentKey.removeValue()
                displayAllGivers(ref: ref, theMap: theMap)
                theMap.removeOverlay(connectionPath)
                
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
    
    //https://www.hackingwithswift.com/example-code/location/how-to-add-annotations-to-mkmapview-using-mkpointannotation-and-mkpinannotationview
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }

        return annotationView
    }
    
    //https://stackoverflow.com/questions/49417144/how-do-i-create-a-line-polyline-between-location-points-in-swift
//    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
//           if overlay is MKPolyline {
//               let polylineRenderer = MKPolylineRenderer(overlay: overlay)
//               polylineRenderer.strokeColor = UIColor.blue
//               polylineRenderer.lineWidth = 5
//               return polylineRenderer
//           }
//
//           return nil
//       }
    
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
