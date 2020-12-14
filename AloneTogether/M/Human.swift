//
//  Human.swift
//  AloneTogether
//
//  Created by Oliver K Cohen on 12/9/20.
//  Copyright © 2020 Oliver K Cohen. All rights reserved.
//

import Foundation; import MapKit; import FirebaseDatabase

class Human {
    
    var name: String
    var city : String
    var country : String
    var userId: Any
    var user_coord:CLLocationCoordinate2D
    var guest : Bool
    var databaseKey: DatabaseReference
    
    init(){
        name = ""
        city = ""
        country = ""
        userId = ""
        user_coord = CLLocationCoordinate2D()
        guest = false
        databaseKey = DatabaseReference()
    }
    
    init(name:String, city:String, country:String, user_coord:CLLocationCoordinate2D, guest:Bool){
        self.name = name
        self.city = city
        self.country = country
        self.user_coord = user_coord
        userId = ""
        self.guest = guest
        self.databaseKey = DatabaseReference()
    }
    
    // Still need to add the activity here
    func makeActiveGiveData(duration: Float, paired: Bool)->[String:Any]{
        let data = ["time": getCurrentDate(), "duration": duration, "user": name,"city": city, "country": country,"uid":userId,"guest":guest,"latitude":user_coord.latitude,"longitude":user_coord.longitude,"paired":paired] as [String : Any]
        return data
    }
    
 
}
