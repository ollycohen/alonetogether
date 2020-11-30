//
//  HashtagsViewController.swift
//  AloneTogether
//
//  Created by Benjamin Faber on 11/20/20.
//  Copyright © 2020 Oliver K Cohen. All rights reserved.
//

import UIKit

class HashtagsViewController: UIViewController {
    //Objects on Storyboard
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func returnBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        //perform segue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
