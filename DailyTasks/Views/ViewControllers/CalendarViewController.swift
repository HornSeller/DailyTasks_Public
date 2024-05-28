//
//  CalendarViewController.swift
//  DailyTasks
//
//  Created by Mac on 13/03/2024.
//

import UIKit
import CVCalendar
import Firebase

class CalendarViewController: UIViewController {

    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var totalTasksLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    private let homeViewModel = HomeViewModel()
    private let currentUid = Auth.auth().currentUser?.uid
    private let dateFormatter = DateFormatter()
    private var tasks: [Task] = []
    private var tableViewData: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "dd MMM, yyyy HH:mm"
        
        tableView.register(UINib(nibName: "CalendarTableViewCell", bundle: .main), forCellReuseIdentifier: "calendarTableCell")
        tableView.rowHeight = 0.21374 * view.frame.width - 1
        
        dateLabel.text = calendarView.presentedDate.commonDescription
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        menuView.commitMenuViewUpdate()
        calendarView.commitCalendarViewUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let currentUid = currentUid {
            homeViewModel.fetchUserData(uid: currentUid) { [self] children in
                tasks = []
                var count = 0
                for child in children {
                    count += 1
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
                        if !task.isCompleted {
                            tasks.append(task)
                        }
                    }
                    if count == children.count {
                        if !tasks.isEmpty {
                            filterTasksAndReloadTableView(fromTasks: tasks, calendarView: calendarView)
                        } else {
                            tableViewData = []
                            totalTasksLabel.text = "Total: 0 tasks"
                            tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    private func filterTasksAndReloadTableView(fromTasks tasks: [Task], calendarView: CalendarView) {
        tableViewData = []
        let calendar = Calendar.current
        var count = 0
        for task in self.tasks {
            count += 1
            let startOfStartDay = calendar.startOfDay(for: task.startTime)
            let endOfEndDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: task.endTime)!
            if calendarView.presentedDate.convertedDate()! >= startOfStartDay && calendarView.presentedDate.convertedDate()! <= endOfEndDay {
                tableViewData.append(task)
            }
            if count == tasks.count {
                totalTasksLabel.text = "Total: \(tableViewData.count) tasks"
                tableView.reloadData()
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "calendarTableCell") as! CalendarTableViewCell
        cell.titleLabel.text = tableViewData[indexPath.row].title
        dateFormatter.dateFormat = "HH:mm"
        cell.endTimeLabel.text = dateFormatter.string(from: tableViewData[indexPath.row].endTime)
        dateFormatter.dateFormat = "dd MMM, yyyy"
        cell.endDateLabel.text = dateFormatter.string(from: tableViewData[indexPath.row].endTime)
        dateFormatter.dateFormat = "dd MMM, yyyy HH:mm"
        cell.viewDetailButtonAction = {
            TaskDetailViewController.mainTask = self.tableViewData[indexPath.row]
            TaskDetailViewController.isCompletedTask = false
            TaskDetailViewController.fromCalenderViewController = true
            self.navigationController?.pushViewController(TaskDetailViewController.makeSelf(), animated: true)
        }
        
        return cell
    }
}

// MARK: - CVCalendarViewDelegate, CVCalendarMenuViewDelegate
extension CalendarViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    func presentationMode() -> CVCalendar.CalendarMode {
        .monthView
    }
    
    func firstWeekday() -> CVCalendar.Weekday {
        .monday
    }
    
    func shouldShowWeekdaysOut() -> Bool {
        true
    }
    
    func didSelectDayView(_ dayView: DayView, animationDidFinish: Bool) {
        navigationItem.title = dayView.date.globalDescription
        filterTasksAndReloadTableView(fromTasks: tasks, calendarView: dayView.calendarView)
        DispatchQueue.main.async { [self] in
            dateLabel.text = calendarView.presentedDate.commonDescription
        }
    }
}
