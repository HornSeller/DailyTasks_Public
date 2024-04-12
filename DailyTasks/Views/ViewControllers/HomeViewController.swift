//
//  HomeViewController.swift
//  DailyTasks
//
//  Created by Mac on 13/03/2024.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addTaskButton: UIButton!
    
    private let homeViewModel = HomeViewModel()
    private var tableData: [Task] = []
    private var collectionData: [Task] = []
    private let database = Database.database().reference()
    private let dateFormatter = DateFormatter()
    private let currentUserUid = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "dd MMM, yyyy HH:mm"
        
        database.child("users").child(currentUserUid!).observeSingleEvent(of: .value) { snapshot in
            guard let userData = snapshot.value as? [String: Any] else {
                print("Error: Unable to fetch user data")
                return
            }
            
            self.emailLabel.text = userData["email"] as? String ?? ""
        }
        
        getCollectionAndTableViewData()
        
        userButton.showsMenuAsPrimaryAction = true
        userButton.menu = UIMenu(title: "", options: .displayInline, children: [
            UIAction(title: "Sign out", handler: { (_) in
                let alert = UIAlertController(title: "Do you want to sign out this user?", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "No", style: .cancel))
                alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
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
    }
    
    func getCollectionAndTableViewData() {
        if let currentUserUid = currentUserUid {
            homeViewModel.fetchUserData(uid: currentUserUid) { [self] children in
                var tasks: [Task] = []
                for child in children {
                    if let taskData = child.value as? [String: Any],
                       let id = taskData["id"] as? String,
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
                        let task = Task(id: id, title: title, description: description, startTime: startTime, endTime: endTime, priority: priority, category: category, isCompleted: isCompleted)
                        tasks.append(task)
                    }
                }
                print(tasks[0].title)
                tasks.remove(at: 0)
                tableData = tasks
                tableView.reloadData()
                let sortedTasks = tasks.sorted { (task1, task2) -> Bool in
                    return task1.endTime < task2.endTime
                }
                collectionData = sortedTasks
                collectionView.reloadData()
                
            }
            //{ [self] email, tasksData in
            //                emailLabel.text = email
            //                var tasks: [Task] = []
            //                for taskData in tasksData {
            //                    if let id = taskData["id"] as? String,
            //                       let title = taskData["title"] as? String,
            //                       let description = taskData["description"] as? String,
            //                       let startTime = taskData["startTime"] as? String,
            //                       let endTime = taskData["endTime"] as? String,
            //                       let priorityRawValue = taskData["priority"] as? String,
            //                       let priority = Task.Priority(rawValue: priorityRawValue),
            //                       let categoryRawValue = taskData["category"] as? String,
            //                       let category = Task.Category(rawValue: categoryRawValue),
            //                       let isCompletedString = taskData["isCompleted"] as? String,
            //                       let isCompleted = Bool(isCompletedString) {
            //                        let task = Task(id: id, title: title, description: description, startTime: startTime, endTime: endTime, priority: priority, category: category, isCompleted: isCompleted)
            //                        print(task)
            //                        tasks.append(task)
            //                    }
            //                }
//                            tasks.remove(at: 0)
//                            tableData = tasks
//                            tableView.reloadData()
//                            let sortedTasks = tasks.sorted { (task1, task2) -> Bool in
//                                return dateFormatter.date(from: task1.endTime)! < dateFormatter.date(from: task1.endTime)!
//                            }
//                            collectionData = sortedTasks
//                            collectionView.reloadData()
        }
    }
    
    @IBAction func addTaskButtonTouchUpInside(_sender: UIButton) {
        self.present(AddTaskViewController.makeSelf(), animated: true)
    }
    
    @objc func taskDidAddNotification() {
        getCollectionAndTableViewData()
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension HomeViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCell", for: indexPath) as! HomeCollectionViewCell
        
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
        
        return cell
    }
    
    
}
