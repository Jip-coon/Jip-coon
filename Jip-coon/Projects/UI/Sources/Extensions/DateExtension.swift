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
    
    var aHHmm: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h시 mm분"
        return formatter.string(from: self)
    }
}
