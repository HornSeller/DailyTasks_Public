//
//  HomeViewController.swift
//  DailyTasks
//
//  Created by Mac on 13/03/2024.
//

import UIKit
import Firebase
import UserNotifications

class HomeViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addTaskButton: UIButton!
    
    private let activityIndicatorView = UIActivityIndicatorView.init(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    private let homeViewModel = HomeViewModel()
    private var tableData: [Task] = []
    private var collectionData: [Task] = []
    private let database = Database.database().reference()
    private let dateFormatter = DateFormatter()
    private let currentUid = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "dd MMM, yyyy HH:mm"
        
        activityIndicatorView.transform = CGAffineTransform(scaleX: 2, y: 2)
        activityIndicatorView.color = .gray
        activityIndicatorView.center = CGPoint.init(x: view.frame.size.width / 2, y: view.frame.size.height / 2)
        view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        view.isUserInteractionEnabled = false
        
        database.child("users").child(currentUid!).observeSingleEvent(of: .value) { snapshot in
            guard let userData = snapshot.value as? [String: Any] else {
                print("Error: Unable to fetch user data")
                return
            }
            
            self.activityIndicatorView.stopAnimating()
            self.view.isUserInteractionEnabled = true
            self.emailLabel.text = userData["email"] as? String ?? ""
        }
                
        userButton.showsMenuAsPrimaryAction = true
        userButton.menu = UIMenu(title: "", options: .displayInline, children: [
            UIAction(title: "Sign out", handler: { (_) in
                let alert = UIAlertController(title: "Do you want to sign out this user?", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "No", style: .cancel))
                alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
                    NotificationItem.removeAllScheduledNotifications()
                    UserDefaults.standard.removeObject(forKey: "ScheduledNotificationIDs")
                    do {
                        try Auth.auth().signOut()
                        self.tabBarController?.dismiss(animated: true)
                    } catch {
                        print(error.localizedDescription)
                    }
                }))
                self.present(alert, animated: true)
            })
        ])
        
        collectionView.register(UINib(nibName: "HomeCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "homeCell")
        
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        let width = 0.38677 * view.frame.width - 2
        let height = 0.514 * view.frame.width - 2
        collectionViewLayout.itemSize = CGSize(width: width, height: height)
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.collectionViewLayout = collectionViewLayout
        
        tableView.register(UINib(nibName: "HomeTableViewCell", bundle: .main), forCellReuseIdentifier: "tableCell")
        tableView.rowHeight = 0.21374 * view.frame.width - 1
        
        NotificationCenter.default.addObserver(self, selector: #selector(taskDidAddNotification), name: Notification.Name("TaskDidAdd"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getCollectionAndTableViewData()
        print("viewWillappear")
    }
    
    func getCollectionAndTableViewData() {
        
        if let currentUserUid = currentUid {
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
                        if !task.isCompleted {
                            tasks.append(task)
                        }
                    }
                }
                print(tasks)
                SearchViewController.tasks = tasks
                tableData = tasks.reversed()
                tableView.reloadData()
                let sortedTasks = tasks.sorted { (task1, task2) -> Bool in
                    return task1.endTime < task2.endTime
                }
                collectionData = sortedTasks
                collectionView.reloadData()
                activityIndicatorView.stopAnimating()
            }
        }
    }
    
    @IBAction func searchButtonTouchUpInside(_ sender: UIButton) {
        performSegue(withIdentifier: "searchSegue", sender: self)
    }
    
    @IBAction func addTaskButtonTouchUpInside(_sender: UIButton) {
        present(AddTaskViewController.makeSelf(), animated: true)
    }
    
    @IBAction func viewCompletedTasksButtonTouchUpInside(_ sender: UIButton) {
        performSegue(withIdentifier: "completedSegue", sender: self)
    }
    
    @objc func taskDidAddNotification() {
        getCollectionAndTableViewData()
        homeViewModel.fetchNotifications(for: currentUid!) { children in
            var notifications: [NotificationItem] = []
            var count = 0
            for child in children {
                count += 1
                if let notificationDict = child.value as? [String: Any],
                   let taskId = notificationDict["taskId"] as? String,
                   let title = notificationDict["title"] as? String,
                   let body = notificationDict["body"] as? String,
                   let triggerTimeString = notificationDict["triggerTime"] as? String,
                   let isActiveString = notificationDict["isActive"] as? String,
                   let isActive = Bool(isActiveString) {
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd MMM, yyyy HH:mm"
                    
                    let triggerTime = dateFormatter.date(from: triggerTimeString)
                    let notification = NotificationItem(taskId: taskId, title: title, body: body, triggerTime: triggerTime!, isActive: isActive)
                    if notification.isActive {
                        notifications.append(notification)
                    }
                    
                }
                if count == children.count {
                    NotificationItem.scheduleNotifications(from: notifications)
                }
            }
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension HomeViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCell", for: indexPath) as! HomeCollectionViewCell
        
        cell.name = collectionData[indexPath.row].title
        cell.priority = collectionData[indexPath.row].priority.rawValue
        cell.time = Service.timeDifference(from: collectionData[indexPath.row].startTime, to: .now)
        
        switch collectionData[indexPath.row].priority {
        case .low:
            cell.subView.backgroundColor = UIColor(hex: "74FF58", alpha: 1)
        case .medium:
            cell.subView.backgroundColor = UIColor(hex: "538BFF", alpha: 1)
        case .high:
            cell.subView.backgroundColor = UIColor(hex: "FF422D", alpha: 1)
        }
        cell.titleLabel.text = collectionData[indexPath.row].title
        dateFormatter.dateFormat = "HH:mm"
        cell.endTimeLabel.text = "Time: \(dateFormatter.string(from: collectionData[indexPath.row].endTime))"
        dateFormatter.dateFormat = "dd MMM, yyyy"
        cell.endDateLabel.text = "Date: \(dateFormatter.string(from: collectionData[indexPath.row].endTime))"
        dateFormatter.dateFormat = "dd MMM, yyyy HH:mm"
        cell.doneButtonAction = {
            self.homeViewModel.updateTaskCompletionStatus(withId: self.collectionData[indexPath.row].id, setStatus: true)
            self.getCollectionAndTableViewData()
            self.present(CompletedViewController.makeSelf(name: cell.name, priority: cell.priority, time: cell.time), animated: true)
        }
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! HomeTableViewCell
        cell.titleLabel.text = tableData[indexPath.row].title
        dateFormatter.dateFormat = "HH:mm"
        cell.endTimeLabel.text = dateFormatter.string(from: tableData[indexPath.row].endTime)
        dateFormatter.dateFormat = "dd MMM, yyyy"
        cell.endDateLabel.text = dateFormatter.string(from: tableData[indexPath.row].endTime)
        dateFormatter.dateFormat = "dd MMM, yyyy HH:mm"
        cell.viewDetailButtonAction = {
            TaskDetailViewController.mainTask = self.tableData[indexPath.row]
            TaskDetailViewController.isCompletedTask = false
            TaskDetailViewController.fromCalenderViewController = false
            self.performSegue(withIdentifier: "detailSegue", sender: self)
        }
        
        return cell
    }
    
    
}
