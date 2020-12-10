//
//  StatsViewController.swift
//  AloneTogether
//
//  Created by Seth Ledford on 12/9/20.
//  Copyright © 2020 Oliver K Cohen. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var timePeriodControl: UISegmentedControl!
    @IBOutlet weak var mindfullnessTimeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var data:[String] = ["Activity #1", "Activity #2", "Activity #3", "Activity #4", "Activity #5", "Activity #6", "Activity #7", "Activity #8", "Activity #9", "Activity #10", "Activity #11", "Activity #12", "Activity #13", "Activity #14"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupTableView();
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel!.text = data[indexPath.row]
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
