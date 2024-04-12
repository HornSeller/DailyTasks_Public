//
//  Task.swift
//  DailyTasks
//
//  Created by Mac on 13/03/2024.
//

import Foundation

struct Task {
    let id: String
    var title: String
    var description: String
    var startTime: Date
    var endTime: Date
    var priority: Priority
    var category: Category
    var isCompleted: Bool
    
    enum Priority: String {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
    }

    enum Category: String {
        case work = "Work"
        case personal = "Personal"
        case family = "Family"
        case none = "None"
    }

    init(title: String, description: String, startTime: Date, endTime: Date, priority: Priority, category: Category, isCompleted: Bool) {
        self.id = UUID().uuidString
        self.title = title
        self.description = description
        self.startTime = startTime
        self.endTime = endTime
        self.priority = priority
        self.category = category
        self.isCompleted = isCompleted
    }
    
    init(id: String, title: String, description: String, startTime: Date, endTime: Date, priority: Priority, category: Category, isCompleted: Bool) {
        self.id = id
        self.title = title
        self.description = description
        self.startTime = startTime
        self.endTime = endTime
        self.priority = priority
        self.category = category
        self.isCompleted = isCompleted
    }
}
