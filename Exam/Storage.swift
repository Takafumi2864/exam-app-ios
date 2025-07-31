import SwiftUI
import UIKit
import FirebaseAuthUI
import FirebaseOAuthUI
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Foundation
import Combine


func checkNotificationAuthorization(completion: @escaping (Bool) -> Void) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            completion(true)
        case .denied:
            completion(false)
        case .notDetermined:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
}
func requestNotificationAuthorization() {
    if let appSettingsURL = URL(string: UIApplication.openSettingsURLString) {
        if UIApplication.shared.canOpenURL(appSettingsURL) {
            UIApplication.shared.open(appSettingsURL, options: [:], completionHandler: nil)
        }
    }
}


class UserSettings: ObservableObject {
    @Published var analog_clock = false
    @Published var digital_clock = false
    @Published var notice = false
    @Published var notice_sound = 1002
    @Published var section_notice = false
    @Published var test = false
    @Published var test2 = false
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        getData()
        objectWillChange
            .sink { [self] _ in
                setData()
            }
            .store(in: &cancellables)
    }
    
    let defaults = UserDefaults.standard
    func setData() {
        defaults.set(analog_clock, forKey: "analog_clock")
        defaults.set(digital_clock, forKey: "digital_clock")
        defaults.set(notice, forKey: "notice")
        defaults.set(notice_sound, forKey: "notice_sound")
        defaults.set(section_notice, forKey: "section_notice")
        defaults.set(test, forKey: "test")
        defaults.set(test2, forKey: "test2")
        defaults.synchronize()
    }
    func getData() {
        if defaults.object(forKey: "analog_clock") != nil {
            analog_clock = defaults.bool(forKey: "analog_clock")
            digital_clock = defaults.bool(forKey: "digital_clock")
            notice = defaults.bool(forKey: "notice")
            notice_sound = defaults.integer(forKey: "notice_sound")
            section_notice = defaults.bool(forKey: "section_notice")
            test = defaults.bool(forKey: "test")
            test2 = defaults.bool(forKey: "test2")
        }
    }
}

class AppData: ObservableObject {
    @Published var tabZIndex: Double = 1.0
    @Published var elseZIndex: Double = 1.0
    @Published var notice_response: UNNotificationResponse? = nil
}


class UserData: ObservableObject {
    @Published var done: Bool = false
    @Published var save = ["date": "", "number": "0"]
    @Published var section = ["Section1", "Section2", "Section3"]
    @Published var list = [[["name": "Sample", "image": "pencil", "color": "primary", "time": "60", "date": ""]], Array<Dictionary<String, String>>(), Array<Dictionary<String, String>>()]
    @Published var component = [[[["holder": "1", "name": "", "minute": "10"]]], Array<Array<Dictionary<String, String>>>(), Array<Array<Dictionary<String, String>>>()]
    @Published var listening: Dictionary<String, Array<Dictionary<String, String>>> = ["1": [["holder": "1", "type": "0", "time": "0"]]]
    @Published var archive = [[["2022年2月22日　22:22": [["holder": "1", "time": "2"]]]], Array<Dictionary<String, Array<Dictionary<String, String>>>>(), Array<Dictionary<String, Array<Dictionary<String, String>>>>()]
    
    init(){
        getData {
            self.done = true
        }
    }
    var db: DocumentReference {
        guard let uid = Auth.auth().currentUser?.uid else {
            fatalError("User not authenticated")
        }
        return Firestore.firestore().collection("users").document(uid)
    }
    func setData(){
        var dictionary = Dictionary<String, Array<Dictionary<String, String>>>()
        var dictionary2 = Dictionary<String, Dictionary<String, Array<Dictionary<String, String>>>>()
        
        var archive_dictionary = Dictionary<String, Array<Dictionary<String, Array<Dictionary<String, String>>>>>()
        
        
        var i = 0
        for i in 0..<3  {
            dictionary.updateValue(list[i], forKey: "section\(String(i + 1))")
            var dictionary2_1 = Dictionary<String, Array<Dictionary<String, String>>>()
            var j = 0
            while j < component[i].count {
                dictionary2_1.updateValue(component[i][j], forKey: "\(String(j))")
                j += 1
            }
            dictionary2.updateValue(dictionary2_1, forKey: "section\(String(i + 1))")
            archive_dictionary.updateValue(archive[i], forKey: "section\(String(i + 1))")
        }
        let data = ["save": save, "allotment": ["section": section, "list": dictionary, "component": dictionary2] as [String : Any], "listening": listening, "archive": archive_dictionary]
        db.setData(data)
    }
    func getData(completion: @escaping () -> Void) {
        var firestore_section = Array<String>()
        var firestore_list = Array<Array<Dictionary<String, String>>>()
        var firestore_component = Array<Array<Array<Dictionary<String, String>>>>()
        var firestore_archive = Array<Array<Dictionary<String, Array<Dictionary<String, String>>>>>()
        db.getDocument { [self] document, error in
            var i = 0
            if let document = document, document.exists {
                let data = document.data()
                var firestore_save = data?["save"] as! [String : String]
                if firestore_save["date"] != dateFormat() {
                    firestore_save = ["date": dateFormat(), "number": "2"]
                }
                let allotment_data = data?["allotment"] as! [String: Any]
                let dictionary = allotment_data["list"] as! Dictionary<String, Array<Dictionary<String, String>>>
                let dictionary2 = allotment_data["component"] as! Dictionary<String, Dictionary<String, Array<Dictionary<String, String>>>>
                firestore_section = allotment_data["section"] as! [String]
                
                let firestore_listening = data?["listening"] as! Dictionary<String, Array<Dictionary<String, String>>>
            
                let archive_data = data?["archive"] as! Dictionary<String, Array<Dictionary<String, Array<Dictionary<String, String>>>>>
                
                
                for i in 0..<3 {
                    firestore_list.append(dictionary["section\(String(i + 1))"]!)
                    var dictionary2_1 = Array<Array<Dictionary<String, String>>>()
                    var j = 0
                    while j < dictionary2["section\(String(i + 1))"]!.count {
                        dictionary2_1.append(dictionary2["section\(String(i + 1))"]!["\(j)"]!)
                        j += 1
                    }
                    firestore_component.append(dictionary2_1)
                    firestore_archive.append(archive_data["section\(String(i + 1))"]!)
                }
                save = firestore_save
                section = firestore_section
                list = firestore_list
                component = firestore_component
                listening = firestore_listening
                archive = firestore_archive
                completion()
            } else {
                print("Document does not exist")
                completion()
            }
        }
    }
    func dateFormat() -> String{
        let df = DateFormatter()
        df.locale = Locale(identifier: "ja_JP")
        df.dateFormat = "yyyyMMdd"
        return df.string(from: Date())
    }
    
    func searchComponents(section_index: Int, index: Int, holder: String) -> Int? {
        return component[section_index][index].firstIndex { item in
            item["holder"] == holder
        }
    }
}
