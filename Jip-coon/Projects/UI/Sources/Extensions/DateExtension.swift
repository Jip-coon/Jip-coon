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
        formatter.locale = Locale(identifier: "ko_KR") // 한국어
        formatter.dateFormat = "yyyy년 MM월 d일 E요일"
        return formatter.string(from: self)
    }
    
    var aHHmm: String {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "a hh시 mm분"
            return formatter.string(from: self)
        }
}
