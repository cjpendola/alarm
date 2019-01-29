//
//  AlarmController.swift
//  AlarmCJ
//
//  Created by Carlos Pendola on 1/28/19.
//  Copyright © 2019 Carlos Pendola. All rights reserved.
//

import Foundation
import UserNotifications

class AlarmController: AlarmScheduler{
    
    static let shared = AlarmController()
    
    var alarms = [Alarm]()
    
    func addAlarm(name: String, fireDate: Date, enabled: Bool){
        
        let alarm = Alarm(fireDate: fireDate, name: name)
        alarm.enabled = enabled
        AlarmController.shared.alarms.append(alarm)
        scheduleUserNotifications(for: alarm)
        
        saveToPersistentStorage()
    }
    
    func update(alarm: Alarm, name: String, fireDate: Date, enabled: Bool){
        
        cancelUserNotifications(for: alarm)
        
        alarm.name = name
        alarm.fireDate = fireDate
        alarm.enabled = enabled
        
        scheduleUserNotifications(for: alarm)
        
        saveToPersistentStorage()
    }
    
    func delete(alarm: Alarm){
        guard let index = AlarmController.shared.alarms.index(of: alarm) else {return}
        self.cancelUserNotifications(for: alarm)
        alarms.remove(at: index)
        
        saveToPersistentStorage()
    }
    
    func toggleEnabled(for alarm: Alarm){
        alarm.enabled = !alarm.enabled
        
        if alarm.enabled{
            scheduleUserNotifications(for: alarm)
        } else{
            cancelUserNotifications(for: alarm)
        }
    }
    
    //MARK: - Persistence
    
    func fileURL() -> URL{
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = path[0]
        let fileName = "alarm.json"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        return fileURL
    }
    
    func saveToPersistentStorage(){
        
        let encoder = JSONEncoder()
        
        do{
            let data = try encoder.encode(alarms)
            try data.write(to: fileURL())
        } catch{
            print("Failed to Save to Persistent Store \(error) \(error.localizedDescription)")
        }
    }
    
    func loadFromPersistentStorage() -> [Alarm]{
        let decoder = JSONDecoder()
        
        do{
            let data = try Data(contentsOf: fileURL())
            let alarms = try decoder.decode([Alarm].self, from: data)
            return alarms
        } catch {
            print("Failed to Load from Persistent Store \(error) \(error.localizedDescription)")
        }
        return []
    }
}

protocol AlarmScheduler: class{
    func scheduleUserNotifications(for alarm: Alarm)
    func cancelUserNotifications(for alarm: Alarm)
}

extension AlarmScheduler{
    
    func scheduleUserNotifications(for alarm: Alarm){
        
        let content = UNMutableNotificationContent()
        content.title = "Time to get up"
        content.body = "Your alarm named \(alarm.name) is going off!"
        content.sound = UNNotificationSound.default
        
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: alarm.fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: alarm.uuid, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error{
                print("Error scheduling local user notifications \(error.localizedDescription)  :  \(error)")
            }
        }
        
    }
    
    func cancelUserNotifications(for alarm: Alarm){
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [alarm.uuid])
    }
}

