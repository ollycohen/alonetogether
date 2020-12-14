//
//  StatsViewController.swift
//  AloneTogether
//
//  Created by Seth Ledford on 12/9/20.
//  Copyright © 2020 Oliver K Cohen. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

struct activityLog {
    var type = ""
    var date = ""
    var duration:Int = 0
}

class StatsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var timePeriodControl: UISegmentedControl!
    @IBOutlet weak var mindfullnessTimeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var data:[activityLog] = []
    var boundedData:[activityLog] = []
    let defaults = UserDefaults.standard
    var userID = "placeholder"
    let ref = Database.database().reference()
    
    let formatter = DateFormatter()
    
    @IBOutlet weak var timePeriodSelector: UISegmentedControl!
    @IBAction func timePeriodChanged(_ sender: Any) {
        
        formatter.dateFormat = "MMM dd, yyyy"
        let currentDate = Date()
        //let dateString = formatter.string(from: date)
        //let currentDate = formatter.date(from: dateString)!
        var offsetConstant:Int
        
        if(timePeriodSelector.selectedSegmentIndex == 0){ // Day
            offsetConstant = -1
        }
        else if (timePeriodSelector.selectedSegmentIndex == 1){ // Week
            offsetConstant = -8
        }
        else if (timePeriodSelector.selectedSegmentIndex == 2){ // Month
            offsetConstant = -31
        }
        else if (timePeriodSelector.selectedSegmentIndex == 3){ // Year
            offsetConstant = -366
        }
        else{
            offsetConstant = -54751
        }
        
        let boundaryDate:Date = Calendar.current.date(byAdding: .day, value: offsetConstant, to: currentDate)!
        boundedData = []
        for i in data{
            let thisDate = formatter.date(from: i.date)
            if (thisDate! > boundaryDate){
                boundedData.append(i)
            }
        }
        tableView.reloadData()
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        userID = defaults.string(forKey: "userID") ?? "error!"
        
        // ref.child("users").child(userID).completedSessions()

        fetchDataForTableview()
        setupTableView()
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return boundedData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let duration:Int = Int(boundedData[indexPath.row].duration)
        cell.textLabel!.text = boundedData[indexPath.row].type
        
        if(duration == 1){
            cell.detailTextLabel!.text = "\(boundedData[indexPath.row].date), \(duration) minute"
        }
        else{
            cell.detailTextLabel!.text = "\(boundedData[indexPath.row].date), \(duration) minutes"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Write/Execute any code you want to run when a specific cell is tapped within the TableView.
    }
    
    func setupTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func fetchDataForTableview(){
        
        // data = whatever you want the contents of the "data" array to contain (I.E. a list of options).
        ref.child("users").child(userID).child("completedSessions").observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children {
                let dataSnap = child as! DataSnapshot
                let activityDict = dataSnap.value as! [String: Any]
                var activity = activityLog()
                activity.date = activityDict["Date"] as! String
                activity.type = activityDict["Type"] as! String
                activity.duration = activityDict["Duration"] as! Int
                
                self.data.append(activity)
                self.boundedData = self.data
                self.tableView.reloadData()
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
