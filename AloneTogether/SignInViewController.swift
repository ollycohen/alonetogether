//
//  SignInViewController.swift
//  AloneTogether
//
//  Created by Benjamin Faber on 11/20/20.
//  Copyright © 2020 Oliver K Cohen. All rights reserved.
//

import UIKit
import FirebaseDatabase
class SignInViewController: UIViewController {
    //UI variables_start
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var firstName: UITextField!
    
    @IBOutlet weak var lastName: UITextField!
    
    @IBOutlet weak var phoneNumber: UITextField!
    //UI variables_end
    @IBAction func goButtonPress(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func newAccountPressed(_ sender: Any) {
        var ref: DatabaseReference!

         ref = Database.database().reference()
         ref.child("users").child(self.firstName.text ?? "nads").child("FirstName").setValue(self.firstName.text ?? "nadia");
         
         ref.child("users").child(self.firstName.text ?? "nads").child("LastName").setValue(self.lastName.text ?? "myrie");
         
         ref.child("users").child(self.firstName.text ?? "nads").child("password").setValue(self.password.text ?? "12345");
         
         ref.child("users").child(self.firstName.text ?? "nads").child("phone").setValue(self.phoneNumber.text ?? "555-555-555");
         ref.child("users").child(self.firstName.text ?? "nads").child("email").setValue(self.email.text ?? "nads@gmail.com");
        
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
