//
//  Service.swift
//  DailyTasks
//
//  Created by Mac on 19/03/2024.
//

import Foundation
import FirebaseAuth

class Service {
    static func timeDifference(from startDate: Date, to endDate: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour, .minute], from: startDate, to: endDate)
        
        if let days = components.day, let hours = components.hour, let minutes = components.minute {
            if days > 0 {
                return "\(days)d\(hours)h\(minutes)m"
            } else if hours > 0 {
                return "\(hours)h\(minutes)m"
            } else if minutes > 0 {
                return "\(minutes)m"
            }
        }
        print("\(startDate), \(endDate)")
        return "0m"
    }
}

enum AuthResult {
    case success(AuthDataResult)
    case failure(Error)
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
