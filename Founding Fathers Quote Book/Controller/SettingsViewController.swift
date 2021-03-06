//
//  SettingsViewController.swift
//  Founding Fathers Quote Book
//
//  Created by Gavin Nitta on 9/22/17.
//  Copyright © 2017 Steve Liddle. All rights reserved.
//

import UIKit
import UserNotifications

class SettingsViewController : UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // Mark: - Constants
    private struct Color {
        static let disabled = UIColor.clear
        static let enabled = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
    }
    
    private struct Component {
        static let Hours = 0
        static let Minutes = 1
        static let AmPM = 2
    }
    
    private struct NotificationContent {
        static let body = "Read advice from our Founding Fathers."
        static let identifier = "com.gavinnitta.ffqb"
        static let subtitle = "Quote of the Day"
        static let title = "Founding Fathers"
    }
    
    private struct NotificationAlert {
            static let buttonLabel = "OK"
        static let message = """
                            To allow this app to remind you of the quote of the day, please go to the Settings app and enable notifications for the Quotes app.
                            """
        static let title = "Notifications Are Disabled"
    }
    
    
    
    private struct Picker {
        static let AmPmCount = 2
        static let AM = "AM"
        static let ComponentWidth: CGFloat = 50.0
        static let InitialHourIndex = 6
        static let MinutesPerGroup = 1
        static let NoonIndex = 11
        static let NumberOfHours = 12
        static let NumberOfMinutesElements = 60
        static let PM = "PM"
        static let RowHeight: CGFloat = 30.0
        static let WheelFactor = 500
    }
    
    private enum Settings: String {
        case notificationsOn, hourIndex, minutesIndex, isAm, notifyDays
    }
    
    // Mark: - Outlets
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet var dayButtons: [UIButton]!
    
    // Mark: - Properties
    var notificationsOn = true
    var hourIndex = Picker.InitialHourIndex
    var minutesIndex = 0
    var isAm = true
    var notifyDays = [true, true, true, true, true, true, true]
    
    // Mark: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkNotificationsPermissions()
        restoreSetting()
        updateUI()
    }
    
    // Mark: - Helpers
    private func checkNotificationsPermissions() {
        UNUserNotificationCenter.current().getNotificationSettings() {
            settings in
            if settings.authorizationStatus != .authorized {
                let alertController = UIAlertController(title: NotificationAlert.title, message: NotificationAlert.message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: NotificationAlert.buttonLabel, style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    private func indexForSelection(_ row: Int, inComponent component: Int) -> Int {
        let rowCount = component == Component.Hours ?
                                    Picker.NumberOfHours :
                                    Picker.NumberOfMinutesElements
        if row < Picker.WheelFactor * rowCount || row >= (Picker.WheelFactor + 1) * rowCount {
            pickerView.selectRow(row % rowCount + Picker.WheelFactor * rowCount, inComponent: component, animated: false)
        }
        return row % rowCount
    }
    
    private func registerNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        if notificationsOn {
            let content = UNMutableNotificationContent()
            content.title = NotificationContent.title
            content.subtitle = NotificationContent.subtitle
            content.body = NotificationContent.body
            
            var components = DateComponents()
            components.hour = hourIndex + 1 + (isAm || hourIndex == Picker.NoonIndex ? 0 : Picker.NumberOfHours)
            components.minute = minutesIndex * Picker.MinutesPerGroup
            
            let trigger = UNCalendarNotificationTrigger.init(dateMatching: components, repeats: true)
            
            UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: NotificationContent.identifier, content: content, trigger: trigger))
        }
    }
    
    private func restoreSetting() {
        let defaults = UserDefaults.standard
        if let days = defaults.array(forKey: Settings.notifyDays.rawValue) as? [Bool] {
            notifyDays = days
            notificationsOn = defaults.bool(forKey: Settings.notificationsOn.rawValue)
            hourIndex = defaults.integer(forKey: Settings.hourIndex.rawValue)
            minutesIndex = defaults.integer(forKey: Settings.minutesIndex.rawValue)
            isAm = defaults.bool(forKey: Settings.isAm.rawValue)
        }
    }
    
    private func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(notificationsOn, forKey: Settings.notificationsOn.rawValue)
        defaults.set(hourIndex, forKey: Settings.hourIndex.rawValue)
        defaults.set(minutesIndex, forKey: Settings.minutesIndex.rawValue)
        defaults.set(isAm, forKey: Settings.isAm.rawValue)
        defaults.set(notifyDays, forKey: Settings.notifyDays.rawValue)
        defaults.synchronize()
        registerNotifications()
    }
    
    private func updateUI() {
        notificationSwitch.setOn(notificationsOn, animated: false)
        pickerView.selectRow(hourIndex + Picker.WheelFactor * Picker.NumberOfHours, inComponent: Component.Hours, animated: false)
        pickerView.selectRow(minutesIndex + Picker.WheelFactor * Picker.NumberOfMinutesElements, inComponent: Component.Minutes, animated: false)
        pickerView.selectRow(isAm ? 0 : 1, inComponent: Component.AmPM, animated: false)
        for button in dayButtons {
            button.backgroundColor = notifyDays[button.tag] ? Color.enabled : Color.disabled
        }
    }
    
    // Mark: - Actions
    @IBAction func toggleNotifications(_ sender: UISwitch) {
        notificationsOn = sender.isOn
        
        if notificationsOn {
            checkNotificationsPermissions()
        }
        saveSettings()
    }
    
    @IBAction func toggleDay(_ sender: UIButton) {
        notifyDays[sender.tag] = !notifyDays[sender.tag]
        updateUI()
        saveSettings()
    }
    
    // Mark: - Picker Data Source
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return Component.AmPM + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case Component.Hours:
            return Picker.NumberOfHours * (2 * Picker.WheelFactor + 1)
        case Component.Minutes:
            return Picker.NumberOfMinutesElements * (2 * Picker.WheelFactor + 1)
        case Component.AmPM:
            return Picker.AmPmCount
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case Component.Hours:
            return "\(row % Picker.NumberOfHours + 1)"
        case Component.Minutes:
            return String(format: "%02d", row % Picker.NumberOfMinutesElements * Picker.MinutesPerGroup)
        case Component.AmPM:
            return row <= 0 ? Picker.AM : Picker.PM
        default:
            return nil
        }
    }
    
    // Mark: - Picker Delegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case Component.Hours:
            hourIndex = indexForSelection(row, inComponent: component)
        case Component.Minutes:
            minutesIndex = indexForSelection(row, inComponent: component)
        case Component.AmPM:
            isAm = row <= 0 ? true : false
        default:
            break;
        }
        saveSettings()
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return Picker.RowHeight
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return Picker.ComponentWidth
    }
    
}
