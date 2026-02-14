//
//  DateExtension.swift
//  UI
//
//  Created by 예슬 on 9/11/25.
//

import Foundation

public extension Date {
    var yyyyMMdEE: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MM월 dd일 E요일"
        return formatter.string(from: self)
    }
    
    var aHmm: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h시 mm분"
        return formatter.string(from: self)
    }
    
    var mmDDe: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "MM월 dd일 E요일"
        return formatter.string(from: self)
    }
    
    var hhMM: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    var mmDD: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: self)
    }
    
    /// 경과 시간을 표시하는 문자열
    var timeAgoString: String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(self)
        
        let minutes = Int(timeInterval / 60)
        let hours = Int(timeInterval / 3600)
        let days = Int(timeInterval / 86400)
        
        if days > 0 {
            return "\(days)일 전"
        } else if hours > 0 {
            return "\(hours)시간 전"
        } else if minutes > 0 {
            return "\(minutes)분 전"
        } else {
            return "방금 전"
        }
    }
}
