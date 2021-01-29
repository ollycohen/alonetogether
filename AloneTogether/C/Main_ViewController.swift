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


class Main_ViewController: UIViewController, MKMapViewDelegate {
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
        if(segue.identifier == "unwindToWelcome"){
            let destination = segue.destination as! ViewController
            destination.loggedIn = false
        }
        
    
    }
    
    
    
    
    @IBOutlet weak var bodybtn: UIButton!
    //@IBOutlet weak var mindbtn: UIButton!
    @IBOutlet weak var speakerBtn: UIButton!
    @IBOutlet weak var causebtn: UIButton!
    @IBOutlet weak var givebtn: UIButton! //GIVE BTN IS START BTN
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var theMap: MKMapView!
  
    @IBOutlet weak var stopBtn: UIButton!
    var currentKey:DatabaseReference = DatabaseReference()
    var progress = Progress()
    var connectionPath = MKPolyline()
    var devicePaired:Bool = false
    
    //global variables 
    var human = Human()
    var give_recieve_pressed : Bool = false;
    var secondsLeft = 0
    var minutesLeft = 0
    var startDuration = 0
    var startActivity = ""
    let date = Date()
    var theTimer:Timer?
    let formatter = DateFormatter()
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
//        print ( human.name+" says hello from " + human.city + " , " + human.country)
        // Set up the map delegate
        theMap.delegate = self
        changeMapZoom(theMap, theCenter: human.user_coord)
//        updateMapToShowGlobe(location: human.user_coord)
        
        //SOUND FROM https://www.babysleepsite.com/downloads/noise-only.mp3
        let path = Bundle.main.path(forResource: "whiteNoise2.wav", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        do {
            backgroundMusic = try AVAudioPlayer(contentsOf: url)
        } catch {
            // couldn't load file :(
        }
        backgroundMusic?.numberOfLoops = -1
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        bodybtn.titleLabel?.doGlowAnimation(withColor: UIColor.yellow)
        causebtn.titleLabel?.doGlowAnimation(withColor: UIColor.yellow)
        givebtn.titleLabel?.doGlowAnimation(withColor: UIColor.yellow)
        stopBtn.titleLabel?.doGlowAnimation(withColor: UIColor.yellow)
        self.navigationItem.setHidesBackButton(true, animated: false)
        // Set "Title" at the top of the view to either say "Welcome, {Name}"
        timerSlider.value = 30
        self.welcomeLabel.text = "Welcome, \(self.human.name)"
        
        deleteCompletedGives(ref: ref)
        displayAllGivers(ref: ref, theMap: theMap)
        let defaults = UserDefaults.standard
        let loggedIn = defaults.bool(forKey: "loggedIn")
        if(!loggedIn){
            self.navigationItem.setRightBarButton(nil, animated: false)
        }
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
        let data = human.makeActiveGiveData(duration: timerSlider.value, paired: false)
        human.databaseKey = ref.child("Active_Gives").childByAutoId()
        human.databaseKey.setValue(data)
        
        // After device is connected, update Active Give data in the firebase
        connectAGive(ref: ref, theMap: theMap, myHuman: human)
        print("give pressed")
        
        minutesLeft = Int(timerSlider.value)
        startActivity = bodybtn.title(for: .normal) ?? "error in startActivity var assignment"
        startDuration = minutesLeft
        secondsLeft = 0
        progress = Progress(totalUnitCount: Int64(timerSlider.value * 60))
        timerSlider.isHidden = true
        givebtn.isHidden = true
        stopBtn.isHidden = false
        progressBar.isHidden = false
        
        print("total unit count: \(Int64(timerSlider.value * 60))")
        print("timerSlider.value = \(timerSlider.value)")
        
        runTimer()
    }
    
    func runTimer(){
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ [self] (timer) in
            theTimer = timer
            guard progress.isFinished == false else {
                timer.invalidate()
                
                minutesLeft = Int(timerSlider.value)
                secondsLeft = 0
                timerSlider.isHidden = false
                givebtn.isHidden = false
                progressBar.isHidden = true
                
//                print("Should delete this key: ", human.databaseKey)
                human.databaseKey.removeValue()
                displayAllGivers(ref: ref, theMap: theMap)
//                print("The map overlays, ", theMap.overlays)
                theMap.removeOverlays(theMap.overlays)
                changeMapZoom(theMap, theCenter: human.user_coord)
                
                let defaults = UserDefaults.standard
                let userID = defaults.string(forKey: "userID") ?? "error!"
                let ref = Database.database().reference()
                formatter.dateFormat = "MMM dd, yyyy"
                let dateString = formatter.string(from: date)
                ref.child("users").child(userID).child("completedSessions").childByAutoId().setValue(["Type": startActivity, "Date": dateString, "Duration": startDuration])
                
                return
            }
            
            progress.completedUnitCount += 1
            let progressFloat = Float(self.progress.fractionCompleted)
            progressBar.setProgress(progressFloat, animated: true)
            
            if(secondsLeft == 0){
                secondsLeft = 59
                minutesLeft -= 1
            } else if(secondsLeft == -1){
                secondsLeft = 0
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
    
    @IBAction func stopTimer(_ sender: Any) {
        guard let unwrapped = theTimer else{
            print("issue unwrapping timer.")
            return
        }
        unwrapped.invalidate()
        minutesLeft = Int(timerSlider.value)
        secondsLeft = -1
        progress = Progress(totalUnitCount: 0)
        timerSlider.isHidden = false
        givebtn.isHidden = false
        progressBar.isHidden = true
        stopBtn.isHidden = true
        human.databaseKey.removeValue()
        displayAllGivers(ref: ref, theMap: theMap)
        theMap.removeOverlays(theMap.overlays)
        changeMapZoom(theMap, theCenter: human.user_coord)
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
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
           if let overlay = overlay as? MKPolyline {
               let polylineRenderer = MKPolylineRenderer(overlay: overlay)
               polylineRenderer.strokeColor = UIColor.blue
               polylineRenderer.lineWidth = 5
               changeMapZoom(mapView, theCenter: overlay.coordinate)
//               let region = MKCoordinateRegion(center: overlay.coordinate, latitudinalMeters: CLLocationDistance(exactly: 17000000)!, longitudinalMeters: CLLocationDistance(exactly: 17000000)!)
//               mapView.setRegion(mapView.regionThatFits(region), animated: true)
               return polylineRenderer
            
            }
       
            print("Overlay is not MKPolyline")
            return MKPolylineRenderer(overlay: overlay)
       }
    
    func changeMapZoom(_ mapView: MKMapView, theCenter: CLLocationCoordinate2D){
        let region = MKCoordinateRegion(center: theCenter, latitudinalMeters: CLLocationDistance(exactly: 19500000)!, longitudinalMeters: CLLocationDistance(exactly: 19500000)!)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    @IBAction func signOut(_ sender: Any) {
        // Remove Key-Value Pair
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: "loggedIn")
        defaults.removeObject(forKey: "userID")
        defaults.removeObject(forKey: "name")
        self.performSegue(withIdentifier: "unwindToWelcome", sender: self)
        
    }
    
    // https://stackoverflow.com/questions/48370852/how-to-display-entire-globe-in-mkmapview?noredirect=1&lq=1
    // MARK: Snippet to show full globe in 3d view
//    private func updateMapToShowGlobe(location :CLLocationCoordinate2D) {
//        let span = MKCoordinateSpan(latitudeDelta: 130, longitudeDelta: 130)
//        let region = MKCoordinateRegion(center: location, span: span)
//        if( region.center.latitude > -90 && region.center.latitude < 90 && region.center.longitude > -180 && region.center.longitude < 180 ){
//            mapView.setRegion(region, animated: true)
//        }
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
