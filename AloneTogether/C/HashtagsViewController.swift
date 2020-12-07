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
    
    @IBOutlet weak var mainView: UIView!
    @IBAction func returnBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        //perform segue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        //https://www.hackingwithswift.com/example-code/calayer/how-to-make-a-uiview-fade-out
        let gradientMaskLayer = CAGradientLayer()
        gradientMaskLayer.frame = mainView.bounds
        gradientMaskLayer.frame = mainView.bounds
        gradientMaskLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
        gradientMaskLayer.locations = [0.01, 0.05, 0.95, 0.99]
        mainView.layer.mask = gradientMaskLayer
        view.addSubview(mainView)
        // Do any additional setup after loading the view.

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
