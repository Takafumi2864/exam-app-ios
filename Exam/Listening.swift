//
//  View2.swift
//  Exam
//
//  Created by 宮田尚文 on 2023/05/28.
//

import UIKit
import SwiftUI
import Foundation
import AVFoundation

struct Listening: View {
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var appData: AppData
    @State var editName: Bool = false
    @State var editName2: Bool = false
    @State var name: String = ""
    @State var name2: String = ""
    @State var editMode: EditMode = .inactive
    @State var showAlert: Bool = false
    @State var alert_offsets: IndexSet = []
    var body: some View {
        NavigationStack {
            List {
                var sortedDict = userData.listening.sorted(by: {$0.key < $1.key})
                if !editMode.isEditing {
                    ForEach(Array(sortedDict), id: \.key) { key, value in
                        Listening_SubView(key: key, value: value)
                    }
                    .onDelete(perform: { offset in
                        alert_offsets = offset
                        showAlert = true
                    })
                } else {
                    ForEach(Array(sortedDict), id: \.key) { key, value in
                        HStack {
                            Text(key)
                                .font(.system(size: 20))
                                .foregroundColor(Color.primary)
                                .bold()
                                .opacity(0.5)
                            Spacer()
                            Button(action: {
                                editName.toggle()
                                name = key
                                name2 = key
                            }, label: {
                                Image(systemName: "pencil")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color.primary)
                                    .bold()
                                    .opacity(0.5)
                            })
                        }
                    }
                    .onDelete(perform: { offset in
                        sortedDict.remove(atOffsets: offset)
                        userData.listening = Dictionary(uniqueKeysWithValues: sortedDict)
                    })
                }
            }
            .environment(\.editMode, self.$editMode)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        editName.toggle()
                    }, label: {
                        Image(systemName: "plus")
                    })
                    .disabled(editMode.isEditing)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        self.editMode = self.editMode.isEditing ? .inactive : .active
                    }, label: {
                        Image(systemName: editMode.isEditing ? "checkmark" : "square.and.pencil")
                    })
                }
            }
        }
        .alert("削除", isPresented: $showAlert) {
            Button("削除", role: .destructive){
                var sortedDict = userData.listening.sorted(by: {$0.key < $1.key})
                sortedDict.remove(atOffsets: alert_offsets)
                userData.listening = Dictionary(uniqueKeysWithValues: sortedDict)
            }
            Button("キャンセル", role: .cancel){
                showAlert = false
            }
        } message: {
            Text("削除すると戻せません。実行しますか？")
        }
        .alert(editMode.isEditing ? "タイトルを変更" : "新しいリスニング", isPresented: $editName) {
            TextField("タイトルを入力", text: $name)
            Button("完了"){
                if userData.listening.keys.contains(name) {
                    editName2.toggle()
                } else {
                    if editMode.isEditing {
                        let array = userData.listening[name2]!
                        userData.listening.removeValue(forKey: name2)
                        userData.listening.updateValue(array, forKey: name)
                        replaceName()
                    } else {
                        userData.listening.updateValue(Array<Dictionary<String, String>>(), forKey: name)
                    }
                    name = ""
                }
            }
            Button("キャンセル", role: .cancel){
                editName.toggle()
                name = ""
            }
        } message: {
            Text("リスニングのタイトル")
        }
        .alert("既存でないタイトルにしてください", isPresented: $editName2) {
            TextField("タイトルを入力", text: $name)
            Button("完了"){
                if userData.listening.keys.contains(name) {
                    editName2.toggle()
                } else {
                    userData.listening.updateValue(Array<Dictionary<String, String>>(), forKey: name)
                    name = ""
                }
            }
            Button("キャンセル", role: .cancel){
                editName.toggle()
                name = ""
            }
        } message: {
            Text("リスニングのタイトル")
        }
        .onChange(of: editName, { oldValue, newValue in
            if newValue == true {
                appData.tabZIndex = 2.0
            } else {
                appData.tabZIndex = 0.0
            }
        })
        .onChange(of: editName2, { oldValue, newValue in
            if newValue == true {
                appData.tabZIndex = 2.0
            } else {
                appData.tabZIndex = 0.0
            }
        })
    }
    func replaceName(){
        userData.component = userData.component.map { array in
            return array.map { array2 in
                return array2.map { dictionary in
                    if let listening = dictionary["listening"] {
                        if listening == name2 {
                            var modifiedDic = dictionary
                            modifiedDic.updateValue(name, forKey: "listening")
                            return modifiedDic
                        } else {
                            return dictionary
                        }
                    } else {
                        return dictionary
                    }
                }
            }
        }
    }
}

/*
 0...audio
 1...pause
 2...repeat
 */
let listening_dictionary = ["0": "再生", "1": "一時停止", "2": "繰り返し", "3": "繰り返し 終了"]
let listening_dictionary2 = ["0": "play.circle", "1": "pause.circle", "2": "repeat.circle", "3": "repeat.circle.fill"]

struct Listening_SubView: View {
    @EnvironmentObject var userData: UserData
    let key: String
    let value: [[String: String]]
    var body: some View {
        NavigationLink(){
            Listening_ChildView(key: key, offset: Array(repeating: 0, count: value.count))
        }
        label: {
            Text(key)
                .font(.system(size: 20))
                .foregroundColor(Color.primary)
                .bold()
        }
    }
}


struct Listening_ChildView: View {
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var appData: AppData
    @State var editMode: EditMode = .inactive
    let key: String
    @State var offset: [Int]
    @State var indices: [Int] = []
    @State var indices2: [Int] = []
    @State var indices3: [Int: Int] = [:]
    @State var actual_listening: [[String: String]] = Array<Dictionary<String, String>>()
    @State var start_listening: Bool = false
    @State var selectedFiles: [URL] = []
    @State var showAlert: Bool = false
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack(spacing : 0) {
            HStack {
                Spacer()
                Menu{
                    Button(action: {
                        userData.listening[key]!.append(["holder": UUID().uuidString, "type": "0", "time": "0"])
                        Lsitening_Manage_Repeat(listening: userData.listening[key]!, indices1: $indices, indices2: $indices2, offset: $offset, indices3: $indices3, actual_listening: $actual_listening)
                    }){
                        HStack {
                            Image(systemName: listening_dictionary2["0"]!)
                            Text(listening_dictionary["0"]!)
                        }
                    }
                    Button(action: {
                        userData.listening[key]!.append(["holder": UUID().uuidString, "type": "1", "time": "0"])
                        offset.append(0)
                        Lsitening_Manage_Repeat(listening: userData.listening[key]!, indices1: $indices, indices2: $indices2, offset: $offset, indices3: $indices3, actual_listening: $actual_listening)
                    }){
                        HStack {
                            Image(systemName: listening_dictionary2["1"]!)
                            Text(listening_dictionary["1"]!)
                        }
                    }
                    Button(action: {
                        userData.listening[key]!.append(["holder": UUID().uuidString, "type": "2", "time": "0"])
                        userData.listening[key]!.append(["holder": UUID().uuidString, "type": "3", "time": "0"])
                        offset.append(0)
                        offset.append(0)
                        Lsitening_Manage_Repeat(listening: userData.listening[key]!, indices1: $indices, indices2: $indices2, offset: $offset, indices3: $indices3, actual_listening: $actual_listening)
                    }) {
                        HStack {
                            Image(systemName: listening_dictionary2["2"]!)
                            Text(listening_dictionary["2"]!)
                        }
                    }
                }
                label: {
                    Image(systemName: "plus")
                        .font(.system(size: 20))
                        .frame(width: 25)
                }
                .disabled(editMode.isEditing)
                .padding(.trailing, 15)
                Button(action: {
                    self.editMode = self.editMode.isEditing ? .inactive: .active
                }, label: {
                    Image(systemName: self.editMode.isEditing ? "checkmark" : "square.and.pencil")
                        .frame(width: 25)
                })
                .padding(.trailing, 20)
            }
            .padding(10)
            .background(Color(UIColor.systemGroupedBackground))
            NavigationStack {
                List {
                    ForEach(Array(userData.listening[key]!.enumerated()), id: \.element) { index, element in
                        Listening_SubView2(key: key, index: index, type: element["type"]!, offset: offset[index])
                            .onAppear {
                                Lsitening_Manage_Repeat(listening: userData.listening[key]!, indices1: $indices, indices2: $indices2, offset: $offset, indices3: $indices3, actual_listening: $actual_listening)
                            }
                    }
                    .onMove(perform: { source, destination in
                        for index in source {
                            if indices3.values.contains(index) {
                                if let key2 = indices3.first(where: { $0.value == index })?.key {
                                    if destination > key2 {
                                        userData.listening[key]!.move(fromOffsets: [index], toOffset: destination)
                                    }
                                }
                            } else if indices3.keys.contains(index) {
                                let value2 = indices3[index]
                                if destination < value2! {
                                    userData.listening[key]!.move(fromOffsets: [index], toOffset: destination)
                                }
                            } else {
                                userData.listening[key]!.move(fromOffsets: [index], toOffset: destination)
                            }
                        }
                        Lsitening_Manage_Repeat(listening: userData.listening[key]!, indices1: $indices, indices2: $indices2, offset: $offset, indices3: $indices3, actual_listening: $actual_listening)
                    })
                    .onDelete(perform: { offsets in
                        for index in offsets {
                            if indices3.keys.contains(index) {
                                userData.listening[key]!.remove(at: indices3[index]!)
                            }
                        }
                        userData.listening[key]!.remove(atOffsets: offsets)
                        Lsitening_Manage_Repeat(listening: userData.listening[key]!, indices1: $indices, indices2: $indices2, offset: $offset, indices3: $indices3, actual_listening: $actual_listening)
                    })
                    
                }
                .listRowSpacing(10.0)
                .environment(\.editMode, self.$editMode)
            }
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(Color(UIColor.secondarySystemGroupedBackground), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(UIColor.secondarySystemGroupedBackground), for: .bottomBar)
            .toolbarBackground(.visible, for: .bottomBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack {
                        Text(key)
                            .opacity(0.5)
                            .font(.system(size: 20))
                            .frame(width: 180)
                            .multilineTextAlignment(.center)
                            .bold()
                        Menu {
                            Button(action: ({})){
                            }
                        } label: {
                            Image(systemName: "chevron.down.circle.fill")
                                .foregroundColor(Color(UIColor.opaqueSeparator))
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing){
                    Button(action: {dismiss()}){
                        Text("完了")
                            .bold()
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    HStack{
                        let actual_listening_count = userData.listening[key]!.count(where: {$0["type"] == "0"})
                        let actual_listening_count2 = String(actual_listening_count) + " 個"
                        FileImportButton(color: Color.accentColor,
                                         keys: [key],
                                         selectedFiles: $selectedFiles,
                                         start_listening: $start_listening,
                                         showAlert: $showAlert,
                                         actual_listening: actual_listening)
                        .padding()
                        Text("ファイル：\(actual_listening_count2)")
                    }
                    .sheet(isPresented: $start_listening, onDismiss: {}) {
                        Listening_TimerView(key: key, files: $selectedFiles)
                            .presentationDetents([.height(300)])
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("完了"){
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
        }
        .onAppear{
            appData.tabZIndex = 2.0
            Lsitening_Manage_Repeat(listening: userData.listening[key]!, indices1: $indices, indices2: $indices2, offset: $offset, indices3: $indices3, actual_listening: $actual_listening)
        }
        .onWillDisappear{
            appData.tabZIndex = 0.0
        }
    }
}


struct Listening_SubView2: View {
    @EnvironmentObject var userData: UserData
    let key: String
    let index: Int
    let type: String
    let offset: Int
    @State var second: Int = 0
    @FocusState var focus: Bool
    var body: some View {
        HStack {
            if offset != 0 {
                ForEach(Array(0..<offset), id: \.self) { index in
                    Rectangle()
                        .frame(width: 2)
                        .ignoresSafeArea()
                        .padding(.leading, 15)
                        .padding(.trailing, 15)
                }
            }
            Image(systemName: listening_dictionary2[type]!)
                .font(.system(size: 25))
                .padding(.leading, 5)
            Text(listening_dictionary[type]!)
                .foregroundColor(.primary)
                .font(.system(size: 18))
            VStack {
                ZStack{
                    Text(type == "1" ? "秒" : "回")
                        .frame(width: 60, alignment: .trailing)
                        .font(.system(size: 18))
                    TextField("", value: $second, formatter: NumberFormatter())
                        .focused($focus)
                        .keyboardType(.numberPad)
                        .frame(width: 60)
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .disabled(type == "1" || type == "2" ? false : true)
                }
                Divider()
                    .frame(width: 60)
                    .offset(y: -10)
            }
            .opacity(type == "1" || type == "2" ? 1.0 : 0.0)
            .offset(y: 5)
        }
        .onChange(of: focus) { oldValue, newValue in
            if index < userData.listening[key]!.count {
                userData.listening[key]![index]["time"] = String(second)
            }
        }
        .onAppear() {
            self.second = Int(userData.listening[key]![index]["time"]!)!
        }
    }
}




struct FileImportButton: View {
    @EnvironmentObject var userData: UserData
    let color: Color
    
    @State var text: String = ""
    let keys: [String]
    @State var keys2: [String] = []
    @State var showFileImporter: Bool = false
    @Binding var selectedFiles: [URL]
    @Binding var start_listening: Bool
    @Binding var showAlert: Bool
    @State var showAlert2: Bool = false
    
    @State var offset: [Int] = []
    @State var indices: [Int] = []
    @State var indices2: [Int] = []
    @State var indices3: [Int: Int] = [:]
    @State var actual_listening: [[String: String]] = []
    
    @State private var importsIndex = 0
    var body: some View {
        Button(action: {
            keys2 = keys.compactMap({userData.listening.keys.contains($0) ? $0 : nil})
            if !keys2.isEmpty {
                Lsitening_Manage_Repeat(listening: userData.listening[keys2[importsIndex]]!, indices1: $indices, indices2: $indices2, offset: $offset, indices3: $indices3, actual_listening: $actual_listening)
                showFileImporter = true
            } else {
                start_listening = true
            }
        }) {
            if text == "" {
                Image(systemName: "play.fill")
                    .font(.system(size: 25))
                    .foregroundColor(color)
            } else {
                Text(text)
            }
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: true,
            onCompletion: { result in
                switch result {
                case .success(let files):
                    if files.count == userData.listening[keys2[importsIndex]]!.count(where: {$0["type"] == "0"}) {
                        for (_, file) in files.enumerated() {
                            let gotAccess = file.startAccessingSecurityScopedResource()
                            if !gotAccess { return }
                            selectedFiles.append(file)
                        }
                        if importsIndex < keys2.count - 1 {
                            importsIndex += 1
                            Lsitening_Manage_Repeat(listening: userData.listening[keys2[importsIndex]]!, indices1: $indices, indices2: $indices2, offset: $offset, indices3: $indices3, actual_listening: $actual_listening)
                            showAlert2 = true
                        } else {
                            start_listening.toggle()
                        }
                    } else {
                        showAlert = true
                    }
                case .failure(_):
                    showAlert = true
                }
            }
        )
        .alert(isPresented: $showAlert) {
            Alert(title: Text("ファイル選択"),
                  message: Text("ファイルは、\(String(userData.listening[keys2[importsIndex]]!.count(where: {$0["type"] == "0"}))) 個だけ選択してください"),
                  primaryButton: .cancel(Text("キャンセル")),
                  secondaryButton: .default(Text("選び直す"), action: {showFileImporter = true}))
        }
        .alert(isPresented: $showAlert2){
            Alert(title: Text("ファイル選択"),
                  message: Text("\(String(importsIndex + 1)) 個目のリスニングを選択してください。\nファイルは、\(String(userData.listening[keys2[importsIndex]]!.count(where: {$0["type"] == "0"}))) 個です。"),
                  primaryButton: .cancel(Text("キャンセル")),
                  secondaryButton: .default(Text("選ぶ"), action: {showFileImporter = true}))
        }
    }
}




func Lsitening_Manage_Repeat(listening: [[String: String]], indices1: Binding<[Int]>, indices2: Binding<[Int]>, offset: Binding<[Int]>, indices3: Binding<[Int: Int]>, actual_listening: Binding<[[String: String]]>) {
    indices1.wrappedValue = listening.enumerated().compactMap { (index, dictionary) -> Int? in
        if dictionary["type"] == "2" {
            return index
        } else {
            return nil
        }
    }
    indices2.wrappedValue = listening.enumerated().compactMap { (index, dictionary) -> Int? in
        if dictionary["type"] == "3" {
            return index
        } else {
            return nil
        }
    }
    
    
    
    var index1 = 0
    offset.wrappedValue = Array(repeating: 0, count: listening.count)
    while index1 < listening.count {
        if indices1.wrappedValue.contains(index1 - 1) {
            offset.wrappedValue = offset.wrappedValue.enumerated().map { (index2, int) -> Int in
                if index2 > index1 - 1 {
                    return int + 1
                } else {
                    return int
                }
            }
        }
        if indices2.wrappedValue.contains(index1) {
            offset.wrappedValue = offset.wrappedValue.enumerated().map { (index2, int) -> Int in
                if index2 > index1 - 1 {
                    return int - 1
                } else {
                    return int
                }
            }
        }
        index1 += 1
    }
    
    
    
    indices3.wrappedValue = [:]
    for (index, _) in offset.wrappedValue.enumerated() {
        if index < offset.wrappedValue.count - 1 {
            if offset.wrappedValue[index] < offset.wrappedValue[index + 1] {
                if let index2 = offset.wrappedValue[(index + 1)..<offset.wrappedValue.count].firstIndex(where: { $0 == offset.wrappedValue[index] }) {
                    indices3.wrappedValue.updateValue(index2, forKey: index)
                }
            } else if offset.wrappedValue[index] == offset.wrappedValue[index + 1] {
                if indices1.wrappedValue.contains(index) && indices2.wrappedValue.contains(index + 1) {
                    indices3.wrappedValue.updateValue(index + 1, forKey: index)
                }
            }
        }
    }
    
    
    
    
    actual_listening.wrappedValue = listening
    let sorted_indices3 = indices3.wrappedValue.sorted(by: {$0.value < $1.value})
    for element in sorted_indices3 {
        var start = element.key
        var end = element.value + 1
        let sorted_indices4: [Int] = actual_listening.wrappedValue.enumerated().compactMap { (index, dictionary) -> Int? in
            if dictionary["type"] == "3" {
                return index
            } else {
                return nil
            }
        }.sorted()
        
        
        let index2 = sorted_indices4[0]
        end = index2 + 1
        var i = index2 - 1
        while i > -1 {
            if actual_listening.wrappedValue[i]["type"] == "2" {
                start = i
                break
            }
            i -= 1
        }
        let range = start..<end
        let repeat_array = actual_listening.wrappedValue[range].compactMap({ dictionary -> [String : String]? in
            if dictionary["type"] != "2" && dictionary["type"] != "3" {
                return dictionary
            }
            return nil
        })
        
        
        var actual_listening2 = Array<Dictionary<String, String>>()
        var j = 0
        while j < Int(listening[element.key]["time"]!)! {
            actual_listening2.append(contentsOf: repeat_array)
            j += 1
        }
        actual_listening.wrappedValue.replaceSubrange(range, with: actual_listening2)
    }
}
