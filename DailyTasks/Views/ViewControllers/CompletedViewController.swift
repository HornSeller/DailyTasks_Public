//
//  CompletedViewController.swift
//  DailyTasks
//
//  Created by Mac on 30/04/2024.
//

import UIKit

class CompletedViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var subView: UIView!
    
    var name = ""
    var priority = ""
    var time = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        subView.layer.cornerRadius = 34
        
        nameLabel.text = name
        priorityLabel.text = priority
        timeLabel.text = time
    }

    static func makeSelf(name: String, priority: String, time: String) -> CompletedViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "CompletedViewController") as! CompletedViewController
        rootViewController.name = name
        rootViewController.priority = priority
        rootViewController.time = time
        
        return rootViewController
    }
}
