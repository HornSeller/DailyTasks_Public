//
//  AnalysisViewController.swift
//  DailyTasks
//
//  Created by Mac on 13/03/2024.
//

import UIKit
import Firebase
import KDCircularProgress

class AnalysisViewController: UIViewController {

    @IBOutlet weak var circularView: UIView!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var circularLabel: UILabel!
    @IBOutlet weak var doneTasksView: UIView!
    @IBOutlet weak var pendingTasksView: UIView!
    @IBOutlet weak var doneTasksLabel: UILabel!
    @IBOutlet weak var pendingTasksLabel: UILabel!
    @IBOutlet weak var noneCategoryPercent: UILabel!
    @IBOutlet weak var workCategoryPercent: UILabel!
    @IBOutlet weak var personalCategoryPercent: UILabel!
    @IBOutlet weak var familyCategoryPercent: UILabel!
    @IBOutlet weak var noneCategoryRatio: UILabel!
    @IBOutlet weak var workCategoryRatio: UILabel!
    @IBOutlet weak var personalCategoryRatio: UILabel!
    @IBOutlet weak var familyCategoryRatio: UILabel!
    @IBOutlet weak var workCategoryProgress: UIProgressView!
    @IBOutlet weak var noneCategoryProgress: UIProgressView!
    @IBOutlet weak var personalCategoryProgress: UIProgressView!
    @IBOutlet weak var familyCategoryProgress: UIProgressView!
    
    
    private var circularProgress = KDCircularProgress()
    private let homeViewModel = HomeViewModel()
    private let currentUid = Auth.auth().currentUser?.uid
    private let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "dd MMM, yyyy HH:mm"
        
        doneTasksView.layer.cornerRadius = 16
        pendingTasksView.layer.cornerRadius = 16
        
        startDatePicker.date = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        endDatePicker.date = Date()
        
        startDatePicker.maximumDate = endDatePicker.date
        endDatePicker.minimumDate = startDatePicker.date
        
        startDatePicker.addTarget(self, action: #selector(datePicker1ValueChanged), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(datePicker2ValueChanged), for: .valueChanged)

        let circularProgressWidth: CGFloat = 0.458 * view.frame.width
        let circularProgressFrame = CGRect(x: 0, y: 0, width: circularProgressWidth, height: circularProgressWidth)
        circularProgress = KDCircularProgress(frame: circularProgressFrame)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        circularProgress.progressThickness = 0.32
        circularProgress.trackThickness = 0.32
        circularProgress.clockwise = false
        circularProgress.gradientRotateSpeed = 2
        //circularProgress.roundedCorners = true
        //circularProgress.glowAmount = 0.9
        circularProgress.trackColor = UIColor(hex: "#E4EBF1", alpha: 1)
        circularProgress.set(colors: UIColor(hex: "#612EF7", alpha: 1))
        circularView.addSubview(circularProgress)
        
        let calendar = Calendar.current
        let startOfDayStartDatePicker = calendar.startOfDay(for: startDatePicker.date)
        let endOfDayEndDatePicker = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDatePicker.date)!
        
        loadAndPresentData(startDate: startOfDayStartDatePicker, endDate: endOfDayEndDatePicker)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        circularProgress.removeFromSuperview()
    }
    
    @objc func datePicker1ValueChanged() {
        let selectedDate = startDatePicker.date
        endDatePicker.minimumDate = selectedDate
        let calendar = Calendar.current
        let startOfDayStartDatePicker = calendar.startOfDay(for: selectedDate)
        let endOfDayEndDatePicker = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDatePicker.date)!
        print("selec \(selectedDate)")

        loadAndPresentData(startDate: startOfDayStartDatePicker, endDate: endOfDayEndDatePicker)
    }
    
    @objc func datePicker2ValueChanged() {
        let selectedDate = endDatePicker.date
        startDatePicker.maximumDate = selectedDate
        let calendar = Calendar.current
        let startOfDayStartDatePicker = calendar.startOfDay(for: startDatePicker.date)
        let endOfDayEndDatePicker = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: selectedDate)!
        print("selec \(selectedDate)")

        loadAndPresentData(startDate: startOfDayStartDatePicker, endDate: endOfDayEndDatePicker)
    }
    
    private func loadAndPresentData(startDate: Date, endDate: Date) {
        var doneTasks = 0
        var pendingTasks = 0
        var noneDoneTasks = 0
        var nonePendingTasks = 0
        var workDoneTasks = 0
        var workPendingTasks = 0
        var personalDoneTasks = 0
        var personalPendingTasks = 0
        var familyDoneTasks = 0
        var familyPendingTasks = 0
        homeViewModel.fetchUserData(uid: currentUid!) { [self] children in
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
                    print(child.key)
                    if (task.startTime > startDate  && task.startTime < endDate) || (task.endTime > startDate && task.endTime < endDate) {
                        if task.isCompleted {
                            doneTasks += 1
                            switch task.category {
                            case .none:
                                noneDoneTasks += 1
                            case .work:
                                workDoneTasks += 1
                            case .personal:
                                personalDoneTasks += 1
                            case .family:
                                familyDoneTasks += 1
                            }
                        } else {
                            pendingTasks += 1
                            switch task.category {
                            case .none:
                                nonePendingTasks += 1
                            case .work:
                                workPendingTasks += 1
                            case .personal:
                                personalPendingTasks += 1
                            case .family:
                                familyPendingTasks += 1
                            }
                        }
                    }
                    
                    if count == children.count {
                        if doneTasks + pendingTasks != 0 {
                            circularLabel.text = "\(String(Int((doneTasks * 100)/(doneTasks + pendingTasks))))%"
                            circularProgress.startAngle = 270
                            circularProgress.animate(toAngle: Double(Int((doneTasks * 100)/(doneTasks + pendingTasks))) / 100 * 360, duration: 1, completion: nil)
                        } else {
                            circularLabel.text = "0%"
                            circularProgress.startAngle = 270
                            circularProgress.animate(toAngle: 0, duration: 1, completion: nil)
                        }
                        doneTasksLabel.text = String(doneTasks)
                        pendingTasksLabel.text = String(pendingTasks)
                        if noneDoneTasks + nonePendingTasks != 0 {
                            noneCategoryProgress.progress = Float(noneDoneTasks) / Float(noneDoneTasks + nonePendingTasks)
                            noneCategoryRatio.text = "\(noneDoneTasks)/\(noneDoneTasks + nonePendingTasks)"
                            noneCategoryPercent.text = "(\(noneDoneTasks * 100 / (noneDoneTasks + nonePendingTasks))%)"
                        } else {
                            noneCategoryProgress.progress = 0
                            noneCategoryRatio.text = "0/0"
                            noneCategoryPercent.text = "(0%)"
                        }
                        if workDoneTasks + workPendingTasks != 0 {
                            workCategoryProgress.progress = Float(workDoneTasks) / Float(workDoneTasks + workPendingTasks)
                            workCategoryRatio.text = "\(workDoneTasks)/\(workDoneTasks + workPendingTasks)"
                            workCategoryPercent.text = "(\(workDoneTasks * 100 / (workDoneTasks + workPendingTasks))%)"
                        } else {
                            workCategoryProgress.progress = 0
                            workCategoryRatio.text = "0/0"
                            workCategoryPercent.text = "(0%)"
                        }
                        if personalDoneTasks + personalPendingTasks != 0 {
                            personalCategoryProgress.progress = Float(personalDoneTasks) / Float(personalDoneTasks + personalPendingTasks)
                            personalCategoryRatio.text = "\(personalDoneTasks)/\(personalDoneTasks + personalPendingTasks)"
                            personalCategoryPercent.text = "(\(personalDoneTasks * 100 / (personalDoneTasks + personalPendingTasks))%)"
                        } else {
                            personalCategoryProgress.progress = 0
                            personalCategoryRatio.text = "0/0"
                            personalCategoryPercent.text = "(0%)"
                        }
                        if familyDoneTasks + familyPendingTasks != 0 {
                            familyCategoryProgress.progress = Float(familyDoneTasks) / Float(familyDoneTasks + familyPendingTasks)
                            familyCategoryRatio.text = "\(familyDoneTasks)/\(familyDoneTasks + familyPendingTasks)"
                            familyCategoryPercent.text = "(\(familyDoneTasks * 100 / (familyDoneTasks + familyPendingTasks))%)"
                        } else {
                            familyCategoryProgress.progress = 0
                            familyCategoryRatio.text = "0/0"
                            familyCategoryPercent.text = "(0%)"
                        }
                    }
                }
            }
        }
    }
}
