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
    @IBOutlet weak var deleteButton: UIButton!
    
    private let dateFormatter = DateFormatter()
    private let homeViewModel = HomeViewModel()
    static var mainTask: Task?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayViewInfo()
        
        fromDateView.layer.cornerRadius = 19
        toDateView.layer.cornerRadius = 19
        descriptionTextView.layer.cornerRadius = 19
        
        descriptionTextView.isEditable = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TaskDetailViewController.mainTask = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("aa")
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
        homeViewModel.updateTaskCompletionStatus(withId: TaskDetailViewController.mainTask!.id, isCompleted: true)
        present(CompletedViewController.makeSelf(name: TaskDetailViewController.mainTask!.title, priority: (TaskDetailViewController.mainTask?.priority.rawValue)!, time: Service.timeDifference(from: TaskDetailViewController.mainTask!.startTime, to: .now)), animated: true)
        markDoneButton.isHidden = true
        deleteButton.isHidden = true
    }
    
    @IBAction func deleteButtonTouchUpInside(_sender: UIButton) {
        homeViewModel.deleteTask(withId: TaskDetailViewController.mainTask!.id)
        markDoneButton.isHidden = true
        deleteButton.isHidden = true
    }
    
    @IBAction func backButtonTouchUpInside(_sender: UIButton) {
        dismiss(animated: true)
    }
}
