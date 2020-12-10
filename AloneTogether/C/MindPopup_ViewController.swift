//
//  MindPopup_ViewController.swift
//  AloneTogether
//
//  Created by Benjamin Faber on 11/20/20.
//  Copyright © 2020 Oliver K Cohen. All rights reserved.
//

import UIKit

class MindPopup_ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //Objects
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var mainView: UIView!
    
    //Actions
    @IBAction func selectButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    //perform segue
        
    }
    
    var data:[String] = ["Option #1", "Option #2", "Option #3", "Option #4", "Option #5", "Option #6", "Option #7", "Option #8", "Option #9", "Option #10", "Option #11", "Option #12", "Option #13", "Option #14"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //https://www.hackingwithswift.com/example-code/calayer/how-to-make-a-uiview-fade-out
        let gradientMaskLayer = CAGradientLayer()
        gradientMaskLayer.frame = mainView.bounds
        gradientMaskLayer.frame = mainView.bounds
        gradientMaskLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
        gradientMaskLayer.locations = [0.01, 0.05, 0.95, 0.99]
        mainView.layer.mask = gradientMaskLayer
        view.addSubview(mainView)
        
        setupTableView();

        // Do any additional setup after loading the view.
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
