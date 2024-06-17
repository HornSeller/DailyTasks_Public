//
//  SearchViewModel.swift
//  DailyTasks
//
//  Created by Mac on 23/04/2024.
//

import Foundation
import Firebase

class SearchViewModel {
    
    var title = ""
    var category = ""
    var priority = ""
    
    func searchTasksByTitle(tasks: [Task]) -> [Task] {
        var searchedTasks: [Task] = []
        for task in tasks {
            if task.title.lowercased().contains(title) {
                searchedTasks.append(task)
            }
        }
        return searchedTasks
    }
    
    func searchTasksByCategory(tasks: [Task]) -> [Task] {
        var searchedTasks: [Task] = []
        for task in tasks {
            if task.category.rawValue.lowercased().contains(category) {
                searchedTasks.append(task)
            }
        }
        return searchedTasks
    }
    
    func searchTasksByPriority(tasks: [Task]) -> [Task] {
        var searchedTasks: [Task] = []
        for task in tasks {
            if task.priority.rawValue.lowercased().contains(priority) {
                searchedTasks.append(task)
            }
        }
        return searchedTasks
    }
}
