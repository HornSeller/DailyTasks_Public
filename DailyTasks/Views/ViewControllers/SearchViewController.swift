//
//  SearchViewController.swift
//  DailyTasks
//
//  Created by Mac on 23/04/2024.
//

import UIKit
import Firebase

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchByButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    enum SearchType: String {
        case title = "title"
        case category = "category"
        case priority = "priority"
    }
    
    private var searchBy: SearchType?
    private var tableViewData: [Task] = []
    private var searchViewModel = SearchViewModel()
    private let dateFormatter = DateFormatter()
    static var tasks: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "dd MMM, yyyy HH:mm"
        
        tableView.register(UINib(nibName: "SearchTableViewCell", bundle: .main), forCellReuseIdentifier: "searchTableCell")
        tableView.rowHeight = 0.21374 * view.frame.width - 1
        
        tableViewData = SearchViewController.tasks
        tableView.reloadData()
        
        searchBar.isEnabled = false
        searchBar.placeholder = "Choose search type..."
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        
        searchByButton.showsMenuAsPrimaryAction = true
        searchByButton.menu = UIMenu(options: .singleSelection, children: [
            UIAction(title: "Title", handler: { (_) in
                self.searchBy = .title
                self.searchBar.text = ""
                self.searchBar.isEnabled = true
                self.searchBar.placeholder = "Enter task title..."
                print(self.searchBy?.rawValue ?? "")
            }),
            
            UIAction(title: "Category", handler: { (_) in
                self.searchBy = .category
                self.searchBar.text = ""
                self.searchBar.isEnabled = true
                self.searchBar.placeholder = "Enter task category..."
                print(self.searchBy?.rawValue ?? "")
            }),
            
            UIAction(title: "Priority", handler: { (_) in
                self.searchBy = .priority
                self.searchBar.text = ""
                self.searchBar.isEnabled = true
                self.searchBar.placeholder = "Enter task priority..."
                print(self.searchBy?.rawValue ?? "")
            })
        ])
    }

    private func fetchTasksData(children: [DataSnapshot]) -> [Task] {
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
        return tasks
    }
    
    @objc func handleTap(_ getsure: UITapGestureRecognizer) {
        searchBar.resignFirstResponder()
    }
    
    @IBAction func backButtonTouchUpInside(_sender: UIButton) {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchTableCell") as! SearchTableViewCell
        cell.titleLabel.text = tableViewData[indexPath.row].title
        dateFormatter.dateFormat = "HH:mm"
        cell.endTimeLabel.text = dateFormatter.string(from: tableViewData[indexPath.row].endTime)
        dateFormatter.dateFormat = "dd MMM, yyyy"
        cell.endDateLabel.text = dateFormatter.string(from: tableViewData[indexPath.row].endTime)
        dateFormatter.dateFormat = "dd MMM, yyyy HH:mm"
        
        return cell
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        print("editing")
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        searchBar.text = ""
        tableViewData = []
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        switch searchBy {
        case .title:
            searchViewModel.title = searchBar.text!.lowercased()
            tableViewData = searchViewModel.searchTasksByTitle(tasks: SearchViewController.tasks)
            tableView.reloadData()
        case .category:
            searchViewModel.category = searchBar.text!.lowercased()
            tableViewData = searchViewModel.searchTasksByCategory(tasks: SearchViewController.tasks)
            tableView.reloadData()
        case .priority:
            searchViewModel.priority = searchBar.text!.lowercased()
            tableViewData = searchViewModel.searchTasksByPriority(tasks: SearchViewController.tasks)
            tableView.reloadData()

        default:
            break
        }
    }
}
