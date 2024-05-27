//
//  CompletedTasksViewController.swift
//  DailyTasks
//
//  Created by Mac on 13/05/2024.
//

import UIKit
import Firebase

class CompletedTasksViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let homeViewModel = HomeViewModel()
    private let currentUserUid = Auth.auth().currentUser?.uid
    private let dateFormatter = DateFormatter()
    private var tableData: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "dd MMM, yyyy HH:mm"

        tableView.register(UINib(nibName: "CompletedTasksTableViewCell", bundle: .main), forCellReuseIdentifier: "completedCell")
        tableView.rowHeight = 0.21374 * view.frame.width - 1        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getTableData()
    }
    
    func getTableData() {
        if let currentUserUid = currentUserUid {
            homeViewModel.fetchUserData(uid: currentUserUid) { [self] children in
                var tasks: [Task] = []
                for child in children {
                    if let taskData = child.value as? [String: Any],
                       let title = taskData["title"] as? String,
                       let description = taskData["description"] as? String,
                       let startTimeString = taskData["startTime"] as? String,
                       let startTime = dateFormatter.date(from: startTimeString),
                       let endTimeString = taskData["endTime"] as? String,
                       let endTime = dateFormatter.date(from: endTimeString),
                       let priorityRawValue = taskData["priority"] as? String,
                       let priority = Task.Priority(rawValue: priorityRawValue),
                       let categoryRawValue = taskData["category"] as? String,
                       let category = Task.Category(rawValue: categoryRawValue),
                       let isCompletedString = taskData["isCompleted"] as? String,
                       let isCompleted = Bool(isCompletedString) {
                        let task = Task(id: child.key, title: title, description: description, startTime: startTime, endTime: endTime, priority: priority, category: category, isCompleted: isCompleted)
                        print(child.key)
                        if task.isCompleted {
                            tasks.append(task)
                        }
                    }
                }
                print(tasks)
                
                tableData = tasks
                tableView.reloadData()
            }
        }
    }
    
    @IBAction func backButtonTapped(_sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDatasource
extension CompletedTasksViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "completedCell", for: indexPath) as! CompletedTasksTableViewCell
        cell.titleLabel.text = tableData[indexPath.row].title
        dateFormatter.dateFormat = "HH:mm"
        cell.endTimeLabel.text = dateFormatter.string(from: tableData[indexPath.row].endTime)
        dateFormatter.dateFormat = "dd MMM, yyyy"
        cell.endDateLabel.text = dateFormatter.string(from: tableData[indexPath.row].endTime)
        dateFormatter.dateFormat = "dd MMM, yyyy HH:mm"
        cell.viewDetailButtonAction = {
            TaskDetailViewController.mainTask = self.tableData[indexPath.row]
            TaskDetailViewController.isCompletedTask = true
            TaskDetailViewController.fromCalenderViewController = false
            self.navigationController?.pushViewController(TaskDetailViewController.makeSelf(), animated: true)
        }
        return cell
    }
    
    
}
