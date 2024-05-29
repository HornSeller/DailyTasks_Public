//
//  TaskDetailViewController.swift
//  DailyTasks
//
//  Created by Mac on 03/05/2024.
//

import UIKit

class TaskDetailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var fromDateView: UIView!
    @IBOutlet weak var toDateView: UIView!
    @IBOutlet weak var fromTimeLabel: UILabel!
    @IBOutlet weak var fromDateLabel: UILabel!
    @IBOutlet weak var toTimeLabel: UILabel!
    @IBOutlet weak var toDateLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var markDoneButton: UIButton!
    @IBOutlet weak var markUnDoneButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    private let dateFormatter = DateFormatter()
    private let homeViewModel = HomeViewModel()
    static var mainTask: Task?
    static var isCompletedTask: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fromDateView.layer.cornerRadius = 19
        toDateView.layer.cornerRadius = 19
        descriptionTextView.layer.cornerRadius = 19
        
        descriptionTextView.isEditable = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(backHomeButtonTappedNotification), name: Notification.Name("BackHomeButtonTapped"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TaskDetailViewController.mainTask = nil
        
        markDoneButton.isHidden = false
        deleteButton.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        displayViewInfo()
        
        if TaskDetailViewController.isCompletedTask {
            markDoneButton.isHidden = true
            markUnDoneButton.isHidden = false
        } else {
            markDoneButton.isHidden = false
            markUnDoneButton.isHidden = true
        }
    }
    
    @objc func backHomeButtonTappedNotification() {
        if TaskDetailViewController.isCompletedTask {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    private func displayViewInfo() {
        titleLabel.text = TaskDetailViewController.mainTask!.title
        priorityLabel.text = TaskDetailViewController.mainTask!.priority.rawValue
        categoryLabel.text = TaskDetailViewController.mainTask!.category.rawValue
        dateFormatter.dateFormat = "HH:mm"
        fromTimeLabel.text = dateFormatter.string(from: TaskDetailViewController.mainTask!.startTime)
        dateFormatter.dateFormat = "dd MMM, yyyy"
        fromDateLabel.text = dateFormatter.string(from: TaskDetailViewController.mainTask!.startTime)
        dateFormatter.dateFormat = "HH:mm"
        toTimeLabel.text = dateFormatter.string(from: TaskDetailViewController.mainTask!.endTime)
        dateFormatter.dateFormat = "dd MMM, yyyy"
        toDateLabel.text = dateFormatter.string(from: TaskDetailViewController.mainTask!.endTime)
        descriptionTextView.text = TaskDetailViewController.mainTask?.description
    }
    
    @IBAction func doneButtonTouchUpInside(_sender: UIButton) {
        homeViewModel.updateTaskCompletionStatus(withId: TaskDetailViewController.mainTask!.id, setStatus: !TaskDetailViewController.isCompletedTask)
        if !TaskDetailViewController.isCompletedTask {
            present(CompletedViewController.makeSelf(name: TaskDetailViewController.mainTask!.title, priority: (TaskDetailViewController.mainTask?.priority.rawValue)!, time: Service.timeDifference(from: TaskDetailViewController.mainTask!.startTime, to: .now)), animated: true)
        } else {
            let alert = UIAlertController(title: "Success", message: "Check it out!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                if TaskDetailViewController.isCompletedTask {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.dismiss(animated: true)
                }
            })
            present(alert, animated: true)
        }
        
        markDoneButton.isHidden = true
        markUnDoneButton.isHidden = true
        deleteButton.isHidden = true
    }
    
    @IBAction func deleteButtonTouchUpInside(_sender: UIButton) {
        let alert = UIAlertController(title: "Do you want to delete this task?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [self] (_) in
            homeViewModel.deleteTask(withId: TaskDetailViewController.mainTask!.id)
            markDoneButton.isHidden = true
            deleteButton.isHidden = true
            if TaskDetailViewController.isCompletedTask {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.dismiss(animated: true)
            }
        }))
        present(alert, animated: true)
    }
    
    @IBAction func backButtonTouchUpInside(_sender: UIButton) {
        if TaskDetailViewController.isCompletedTask {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
        
    }
    
    static func makeSelf() -> TaskDetailViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "TaskDetailViewController")  as! TaskDetailViewController
        
        return rootViewController
    }
}
