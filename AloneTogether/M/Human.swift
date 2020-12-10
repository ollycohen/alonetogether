//
//  Human.swift
//  AloneTogether
//
//  Created by Oliver K Cohen on 12/9/20.
//  Copyright © 2020 Oliver K Cohen. All rights reserved.
//

import Foundation; import MapKit

class Human {
    
    var name: String
    var city : String
    var country : String
    var userId: Any
    var user_coord:CLLocationCoordinate2D
    var guest : Bool
    
    init(){
        name = ""
        city = ""
        country = ""
        userId = ""
        user_coord = CLLocationCoordinate2D()
        guest = false
    }
    
    init(name:String, city:String, country:String, user_coord:CLLocationCoordinate2D, guest:Bool){
        self.name = name
        self.city = city
        self.country = country
        self.user_coord = user_coord
        userId = ""
        self.guest = guest
    }
    
    func makeActiveGiveData(timestamp: [AnyHashable:Any])->[String:Any]{
        let data = ["time": timestamp, "user": name,"city": city, "country": country,"uid":userId,"guest":guest] as [String : Any]
        return data
    }
    
 
}
