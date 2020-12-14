//
//  FirebaseFunctions.swift
//  AloneTogether
//
//  Created by Oliver K Cohen on 12/10/20.
//  Copyright © 2020 Oliver K Cohen. All rights reserved.
//

import FirebaseDatabase
import MapKit


var connectionPath:MKPolyline = MKPolyline()
var partnerKey:String = ""

func startListening(ref: DatabaseReference, id:String, theMap: MKMapView, myHuman:Human){
    ref.child("Active_Gives").child(id).observe(DataEventType.value, with: { (snapshot) in
        guard let value = snapshot.value as? [String : AnyObject] else {
//            print("Couldn't get a snapshot of the value")
            return
        }
        let partner_lat = value["partner_latitude"] as? CLLocationDegrees ?? 0.0
        let partner_long = value["partner_longitude"] as? CLLocationDegrees ?? 0.0
        if partner_lat != 0.0 || partner_long != 0.0 {
            let partner_coordinate = CLLocationCoordinate2DMake(partner_lat, partner_long)
            connectionPath = MKPolyline(coordinates: [myHuman.user_coord, partner_coordinate], count: 2)
            theMap.addOverlay(connectionPath)
        }
      })

}

func updatePairedValueInFirebase(ref: DatabaseReference, id: String, paired: Bool){
    ref.child("Active_Gives").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
        // Get user value
        guard var myValue = snapshot.value as? [String: Any] else {
            return
        }
        
        myValue["paired"] = paired
        myValue["partner_coordinates"] =
//        print("Deep into the matrix... / access database for myself:  ", myValue)
        ref.child("Active_Gives").child(id).updateChildValues(myValue)
        
        // ...
        }) { (error) in
          print(error.localizedDescription)
      }
}

// Let's connect two gives
func connectAGive(ref:DatabaseReference, theMap:MKMapView, myHuman:Human){
    
    var sourceCoord:CLLocationCoordinate2D = CLLocationCoordinate2D()
    var destCoord:CLLocationCoordinate2D = CLLocationCoordinate2D()
    var devicePaired:Bool = false
    guard let myId = myHuman.databaseKey.key else {
        print("Failed to unwrap my key")
        return
    }
    ref.child("Active_Gives").observe(DataEventType.value, with: { (snapshot) in

        for give in snapshot.children.allObjects as! [DataSnapshot] {
            let thisKey = give.key
            guard var value = give.value as? [String: Any] else {
                return
            }
//            let thisName = value["user"] as? String ?? "Hello"
            let paired = value["paired"] as? Bool ?? true
            if paired == false && thisKey != myId {
                // Update partner's paired status in Firebase
                value["paired"] = true
                value["partner_latitude"] = myHuman.user_coord.latitude
                value["partner_longitude"] = myHuman.user_coord.longitude
                ref.child("Active_Gives").child(thisKey).updateChildValues(value)
                partnerKey = thisKey
                // Update my paired status in Firebase
                updatePairedValueInFirebase(ref: ref, id: myId, paired: true)
                devicePaired = true
                sourceCoord = myHuman.user_coord
                let destLat = value["latitude"] as? CLLocationDegrees ?? 0.0
                let destLong = value["longitude"] as? CLLocationDegrees ?? 0.0
                destCoord = CLLocationCoordinate2D(latitude: destLat, longitude: destLong)
                
            }
        }
        if devicePaired == false {
//            print("Started listening")
            startListening(ref: ref, id: myId, theMap: theMap, myHuman: myHuman)
        } else {
//            print("Drawing the connection path: source coord ", sourceCoord, ", dest coord ", destCoord)
            connectionPath = MKPolyline(coordinates:[sourceCoord,destCoord],count:2)
            theMap.addOverlay(connectionPath)
        }
        
    }) { (error) in
        print(error.localizedDescription)
    }
    
}


//Getter for the Connection Path
func deleteConnectionPath(theMap:MKMapView){
    theMap.removeOverlay(connectionPath)
}

// Iterate through Active Gives and display them all
func displayAllGivers(ref:DatabaseReference, theMap: MKMapView){
    
    theMap.removeAnnotations(theMap.annotations)
    ref.child("Active_Gives").observe(DataEventType.value, with: { (snapshot) in

        for give in snapshot.children.allObjects as! [DataSnapshot] {
            if let value = give.value as? [String: Any] {
                let lat = value["latitude"] as? CLLocationDegrees ?? 0.0
                let long = value["longitude"] as? CLLocationDegrees ?? 0.0
                let name = value["user"] as? String ?? "Hello"
                let thePin = MKPointAnnotation()
                thePin.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                thePin.title = name
                theMap.addAnnotation(thePin)
            }
        }
    }) { (error) in
        print(error.localizedDescription)
    }
}

// Iterate through database and delete completed gives
//https://stackoverflow.com/questions/53714451/looping-through-firebase-database-to-build-a-table-list-in-swift
func deleteCompletedGives(ref:DatabaseReference){
    
    var idsToDelete:[String] = [String]()
    
    ref.child("Active_Gives").observe(DataEventType.value, with: { (snapshot) in
    
        for give in snapshot.children.allObjects as! [DataSnapshot] {
            let key = give.key
            if let value = give.value as? [String: Any] {
                let duration = value["duration"] as? Float ?? 0.0
                let timestamp = value["time"] as? Int ?? 0
                let currentTime = getCurrentDate()
                
                if(currentTime > timestamp + Int(duration*100)){
                    idsToDelete.append(key)
                    //print("Ids to delete, ", idsToDelete.count)
                }
                //print("Duration is ", duration, ", time is ", timestamp, ", current time is ", currentTime)
            }
        }
        
        deleteHelper(ref: ref, idsToDelete: idsToDelete)

    }) { (error) in
        print(error.localizedDescription)
    }
}

private func deleteHelper(ref: DatabaseReference, idsToDelete: [String]){
    
    for id in idsToDelete{
        ref.child("Active_Gives").child(id).removeValue()
    }
}

func getCurrentDate()->Int{
    let date = Date()
    let calendar = Calendar.current
    let year = calendar.component(.year, from: date)
    var month:Any = calendar.component(.month, from: date)
    var day:Any = calendar.component(.day, from: date)
    var hour:Any = calendar.component(.hour, from: date)
    var minutes:Any = calendar.component(.minute, from: date)
    var seconds:Any = calendar.component(.second, from: date)
    let mo = month as? Int ?? 0
    let d = day as? Int ?? 0
    let h = hour as? Int ?? 0
    let m = minutes as? Int ?? 0
    let s = seconds as? Int ?? 0
    if mo < 10 {
        month = "0\(month)"
    }
    if d < 10 {
        day = "0\(day)"
    }
    if h < 10 {
        hour = "0\(hour)"
    }
    if m < 10 {
        minutes = "0\(minutes)"
    }
    if s < 10 {
        seconds = "0\(seconds)"
    }
    guard let timestamp = Int("\(year)\(month)\(day)\(hour)\(minutes)\(seconds)") else { return 0 }
//    print(timestamp)
    return timestamp
    
}
