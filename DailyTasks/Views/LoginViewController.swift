//
//  LoginViewController.swift
//  DailyTasks
//
//  Created by Mac on 13/03/2024.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        FirebaseAuth.Auth.auth().createUser(withEmail: "b@gmail.com", password: "abcxyz") { (result, error) in
            print(result)
        }
    }
    
    @IBAction func btnTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "loginSegue", sender: self)
    }
}
