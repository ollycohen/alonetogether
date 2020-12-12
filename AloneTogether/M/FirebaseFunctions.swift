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

// Let's connect two gives
func connectAGive(ref:DatabaseReference, myKey:String, theMap:MKMapView, myHuman:Human){
    
    var twoPinsToConnect:[CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
    ref.child("Active_Gives").observe(DataEventType.value, with: { (snapshot) in

        for give in snapshot.children.allObjects as! [DataSnapshot] {
            let thisKey = give.key
            guard let value = give.value as? [String: Any] else {
                return
            }
            let thisName = value["user"] as? String ?? "Hello"
            let paired = value["paired"] as? Bool ?? true
            if paired == false && thisKey != myKey {
//                print("Connect these two pins")
                for pin in theMap.annotations {
                    if twoPinsToConnect.count > 1 {
                        break
                    }
                    print("pin.title ", pin.title!! , ", myHuman ", myHuman.name, ", thisName ", thisName)
                    if pin.title == myHuman.name || pin.title == thisName {
                        twoPinsToConnect.append(pin.coordinate)
                    }
                }
            }
            
        }
        
//        print(twoPinsToConnect.count)
        connectionPath = MKPolyline(coordinates:twoPinsToConnect,count:twoPinsToConnect.count)
        theMap.addOverlay(connectionPath)
        
        
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
