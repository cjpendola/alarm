//
//  Alarm.swift
//  AlarmCJ
//
//  Created by Carlos Pendola on 1/28/19.
//  Copyright © 2019 Carlos Pendola. All rights reserved.
//

import Foundation

class Alarm:Equatable, Codable {

    // MARK: Properties
    var name: String
    var enabled: Bool
    let uuid: String
    var fireDate: Date
    
    var fireTimeAsString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: fireDate)
    }
    
    init(fireDate: Date, name: String, enabled: Bool = true, uuid: String = UUID().uuidString) {
        self.fireDate = fireDate
        self.name = name
        self.enabled = enabled
        self.uuid = uuid
    }
    
    // MARK: - Equatable
    static func == (lhs: Alarm, rhs: Alarm) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
}

