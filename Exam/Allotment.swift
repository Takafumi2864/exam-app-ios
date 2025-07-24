//
//  View1.swift
//  Exam
//
//  Created by 宮田尚文 on 2023/05/28.
//

import SwiftUI
import Foundation
import AVFoundation

/*struct View1_Previews: PreviewProvider {
    static var previews: some View {
        @State var tabZIndex: Double = 1.0
        View1()
            .environmentObject(AppData())
            .environmentObject(UserData())
    }
}*/



struct Allotment: View {
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var appData: AppData
    @State private var enable = true
    @State private var active1 = false
    @State private var active2 = false
    @State private var active3 = false
    @State private var active = false
    @State var showOverlay1 = false
    @State var showOverlay2 = false
    @State var editMode: EditMode = .inactive
    @State var showAlert: Bool = false
    @State var alert_section_index: Int = 0
    @State var alert_offsets: IndexSet = []
    
    @State var notice_section_index: Int = 0
    @State var notice_index: Int = 0
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(userData.section.enumerated()), id: \.element){ section_index, section_name in
                    Section(header: Text(section_name)){
                        ForEach(Array(userData.list[section_index].enumerated()), id: \.element){ index, element in
                            SubView(i: section_index, index: index, item: $userData.list[section_index][index])
                        }
                        .onMove(perform: { source, destination in
                            userData.list[section_index].move(fromOffsets: source, toOffset: destination)
                            userData.component[section_index].move(fromOffsets: source, toOffset: destination)
                            userData.archive[section_index].move(fromOffsets: source, toOffset: destination)
                        })
                        .onDelete(perform: { offsets in
                            alert_section_index = section_index
                            alert_offsets = offsets
                            showAlert = true
                        })
                    }
                }
            }
            .environment(\.editMode, self.$editMode)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu{
                        Button(action: {showOverlay1.toggle()}) {
                            Text("セクション名を変更")
                        }
                        Button(action: {showOverlay2.toggle()}) {
                            Text("テストを始める")
                        }
                    }
                    label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu{
                        Button(action: {
                            userData.list[0].append(["name": "", "image": "pencil", "color": "primary", "time": "0", "date": "today"])
                            userData.component[0].append([["holder": "1", "name": "", "minute": "0"]])
                            userData.archive[0].append(Dictionary<String, Array<Dictionary<String, String>>>())
                            active1.toggle()
                        }){
                            Text(userData.section[0])
                        }
                        Button(action: {
                            userData.list[1].append(["name": "", "image": "pencil", "color": "primary", "time": "0", "date": "today"])
                            userData.component[1].append([["holder": "1", "name": "", "minute": "0"]])
                            userData.archive[1].append(Dictionary<String, Array<Dictionary<String, String>>>())
                            active2.toggle()
                        }){
                            Text(userData.section[1])
                        }
                        Button(action: {
                            userData.list[2].append(["name": "", "image": "pencil", "color": "primary", "time": "0", "date": "today"])
                            userData.component[2].append([["holder": "1", "name": "", "minute": "0"]])
                            userData.archive[2].append(Dictionary<String, Array<Dictionary<String, String>>>())
                            active3.toggle()
                        }) {
                            Text(userData.section[2])
                        }
                    }
                    label: {
                        Image(systemName: "plus")
                    }
                    .disabled(!enable)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        self.editMode = self.editMode.isEditing ? .inactive: .active
                        enable.toggle()
                    }, label: {
                        Image(systemName: self.editMode.isEditing ? "checkmark" : "square.and.pencil")
                    })
                }
            }
            .navigationDestination(isPresented: $active1, destination: {
                if userData.list[0].count > 0 {
                    ChildView(section_index: 0, index: userData.list[0].count - 1)
                }
            })
            .navigationDestination(isPresented: $active2, destination: {
                if userData.list[1].count > 0 {
                    ChildView(section_index: 1, index: userData.list[1].count - 1)
                }
            })
            .navigationDestination(isPresented: $active3, destination: {
                if userData.list[2].count > 0 {
                    ChildView(section_index: 2, index: userData.list[2].count - 1)
                }
            })
            .navigationDestination(isPresented: $active, destination: {
                ChildView(section_index: notice_section_index, index: notice_index)
            })
            .sheet(isPresented: $showOverlay1, onDismiss: {}) {
                EditSection()
                    .presentationDetents([.height(220)])
            }
            .sheet(isPresented: $showOverlay2, onDismiss: {}) {
                StartExam()
                    .presentationDetents([.large])
            }
        }
        .onAppear {
            NotificationDelegate.shared.onOpenDetail = {
                if let response = appData.notice_response {
                    notice_section_index = response.notification.request.content.userInfo["section_index"]! as! Int
                    notice_index = response.notification.request.content.userInfo["index"]! as! Int
                    active = true
                }
            }
        }
        .alert("削除", isPresented: $showAlert) {
            Button("削除", role: .destructive){
                userData.list[alert_section_index].remove(atOffsets: alert_offsets)
                userData.component[alert_section_index].remove(atOffsets: alert_offsets)
                userData.archive[alert_section_index].remove(atOffsets: alert_offsets)
            }
            Button("キャンセル", role: .cancel){
                showAlert = false
            }
        } message: {
            Text("削除すると戻せません。実行しますか？")
        }
    }
}

struct SubView: View{
    @EnvironmentObject var userData: UserData
    let i: Int
    let index: Int
    @Binding var item: Dictionary<String, String>
    var body: some View {
        NavigationLink() {
            ChildView(section_index: i, index: index)
        }
        label: {
            HStack {
                Text("")
                Image(systemName: item["image"]!)
                    .frame(width:40, height:40)
                    .foregroundColor(Color(UIColor.systemBackground))
                    .bold()
                    .background(
                        Circle()
                            .foregroundColor(Color(wordName: item["color"]!))
                    )
                    .padding(3)
                Text(item["name"]!)
                    .font(.system(size: 20))
                    .foregroundColor(Color(wordName: item["color"]!))
                    .bold()
                Text("[\(item["time"]!)分]")
                    .font(.system(size: 15))
                    .bold()
            }
        }
    }
}



// MARK: EditSection
struct EditSection: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userData: UserData
    @FocusState var focus1: Bool
    @FocusState var focus2: Bool
    @FocusState var focus3: Bool
    var body: some View {
        NavigationStack{
            HStack{
                Text("セクション1 : ")
                    .font(.system(size: 20))
                VStack{
                    TextField("Section1", text: $userData.section[0])
                        .font(.system(size: 22))
                        .frame(width:200)
                        .textInputAutocapitalization(.never)
                        .multilineTextAlignment(.center)
                        .modifier(TextFieldClearButton(text: $userData.section[0], focus: _focus1))
                        .focused($focus1)
                    Divider()
                        .frame(width:200)
                        .offset(y: -5)
                }
            }
            HStack{
                Text("セクション2 : ")
                    .font(.system(size: 20))
                VStack{
                    TextField("Section2", text: $userData.section[1])
                        .font(.system(size: 22))
                        .frame(width:200)
                        .textInputAutocapitalization(.never)
                        .multilineTextAlignment(.center)
                        .modifier(TextFieldClearButton(text: $userData.section[1], focus: _focus2))
                        .focused($focus2)
                    Divider()
                        .frame(width:200)
                        .offset(y: -5)
                }
            }
            HStack{
                Text("セクション3 : ")
                    .font(.system(size: 20))
                VStack{
                    TextField("Section3", text: $userData.section[2])
                        .font(.system(size: 22))
                        .frame(width:200)
                        .textInputAutocapitalization(.never)
                        .multilineTextAlignment(.center)
                        .modifier(TextFieldClearButton(text: $userData.section[2], focus: _focus3))
                        .focused(self.$focus3)
                    Divider()
                        .frame(width:200)
                        .offset(y: -5)
                }
            }
            .toolbar{
                Button(action: {dismiss()}){
                    Text("完了")
                        .bold()
                }
            }
        }
    }
}

struct TextFieldClearButton: ViewModifier {
    @Binding var text: String
    @FocusState var focus: Bool
    func body(content: Content) -> some View {
        ZStack(alignment: .trailing){ content
            if !text.isEmpty {
                Button(action: {
                    self.text = ""
                    focus = true
                })
                {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(UIColor.opaqueSeparator))
                        .disabled(false)
                }
            }
            else{
                Button(action: {}){
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .opacity(0.0)
                        .disabled(true)
                }
            }
        }
    }
}



// MARK: StartExam

struct StartExam: View {
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.dismiss) var dismiss
    @State var section_index: Int = 0
    @State var checked_index: [Int] = []
    
    @State var ongoing: Bool = false
    @State var keys: [String] = []
    @State var selectedFiles: [URL] = []
    @State var showAlert: Bool = false
    @State var userNotice: Bool = false
    var body: some View {
        NavigationStack {
            List {
                Section(header:
                            Menu {
                    ForEach(0..<3, id: \.self){ index in
                        Button(action: {
                            section_index = index
                        }) {
                            Text(userData.section[index])
                        }
                    }
                } label: {
                    Text("\(userData.section[section_index])")
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                ) {
                    ForEach(Array(userData.list[section_index].enumerated()), id: \.element){ index, element in
                        Button(action: {
                            if checked_index.contains(index) {
                                checked_index.remove(at: checked_index.firstIndex(of: index)!)
                            } else {
                                checked_index.append(index)
                            }
                        }) {
                            HStack {
                                Text("")
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                                    .bold()
                                    .opacity(checked_index.contains(index) ? 1.0 : 0.0)
                                Image(systemName: element["image"]!)
                                    .frame(width:40, height:40)
                                    .foregroundColor(Color(UIColor.systemBackground))
                                    .bold()
                                    .background(
                                        Circle()
                                            .foregroundColor(Color(wordName: element["color"]!))
                                    )
                                    .padding(3)
                                Text(userData.list[section_index][index]["name"]!)
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(wordName: element["color"]!))
                                    .bold()
                                Text("[\(element["time"]!)分]")
                                    .font(.system(size: 15))
                                    .bold()
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("テストを始める")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {dismiss()}){
                        Text("閉じる")
                            .bold()
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    if checked_index.count == 0 {
                        Text("開始するテストを選択してください")
                    } else if checked_index.count == 1 {
                        HStack{
                            FileImportButton(color: Color(wordName: userData.list[section_index][checked_index[0]]["color"]!)!,
                                             keys: keys,
                                             selectedFiles: $selectedFiles,
                                             start_listening: $ongoing,
                                             showAlert: $showAlert)
                            .padding()
                            Text("「\(userData.list[section_index][checked_index[0]]["name"]!)」を開始する")
                        }
                        .sheet(isPresented: $ongoing, onDismiss: {}) {
                            TimerView(section_index: section_index,
                                      index: checked_index[0],
                                      section_notice: userSettings.section_notice,
                                      time: Int(userData.list[section_index][checked_index[0]]["time"]!)!,
                                      date: dfS_D(date: userData.list[section_index][checked_index[0]]["date"]!),
                                      keys: $keys,
                                      selectedFiles: $selectedFiles)
                            .presentationDetents([.large])
                        }
                    } else {
                        if userNotice {
                            let checker = checked_index.compactMap { (index) -> Int? in
                                if userData.list[section_index][index]["date"]! == "" {
                                    return index
                                } else {
                                    return nil
                                }
                            }
                            if !checker.isEmpty {
                                Text("日付が設定されていません")
                            } else {
                                HStack{
                                    FileImportButton(color: .accentColor,
                                                     keys: keys,
                                                     selectedFiles: $selectedFiles,
                                                     start_listening: $ongoing,
                                                     showAlert: $showAlert)
                                    .padding()
                                    Text("\(String(checked_index.count))個のテストを開始する")
                                }
                            }
                        } else {
                            Text("通知が許可されていません")
                        }
                    }
                }
            }
        }
        .onChange(of: section_index) { _, _ in
            self.checked_index = []
        }
        .onChange(of: checked_index) { _, _ in
            self.checked_index = checked_index.sorted(by: <)
            self.keys = []
            for dictionary in userData.component[section_index][checked_index[0]] {
                if dictionary.keys.contains("listening") {
                    self.keys.append(dictionary["listening"]!)
                } else {
                    self.keys.append("")
                }
            }
        }
        .onAppear {
            checkNotificationAuthorization { isAuthorized in
                userNotice = isAuthorized
            }
        }
    }
}


// MARK: ChildView

struct ChildView: View {
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var appData: AppData
    let section_index: Int
    let index: Int
    @State var showTextField = false
    @State var showEditIcon = false
    @State var showEditTime = false
    @State var editMode: EditMode = .inactive
    @State private var name: String = ""
    @State private var name2: String = ""
    @State var numberPad: Bool = false
    @FocusState var nameFocus: Bool
    @Environment(\.dismiss) var dismiss
    @State var id = 1
    @State var id2 = 1

    @State var section_notice: Bool = false
    @State var ongoing: Bool = false
    @State var keys: [String] = []
    @State var selectedFiles: [URL] = []
    @State var showAlert: Bool = false
    
    @State var listening_sheet: Bool = false
    @State var listening_sheet2: Int = 0
    
    var body: some View {
        VStack(spacing : 0){
            HStack{
                Text("\(userData.list[section_index][index]["time"]!) 分")
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .bold()
                Text(userData.list[section_index][index]["date"]! == "" ? "日時未設定" : "\(userData.list[section_index][index]["date"]!) ~")
                    .sheet(isPresented: $showEditTime, onDismiss: {}) {
                        EditTime(section_index: section_index, index: index)
                            .presentationDetents([.large])
                    }
                Spacer()
                Button(action: {
                    userData.component[section_index][index].append(["holder": UUID().uuidString, "name": "", "minute": "0"])
                    keys.append("")
                }, label: {
                    Image(systemName: "plus")
                        .font(.system(size: 20))
                        .frame(width: 25)
                })
                .disabled(editMode.isEditing)
                .padding(.trailing, 15)
                Button(action: {
                    self.editMode = self.editMode.isEditing ? .inactive: .active
                }, label: {
                    Image(systemName: self.editMode.isEditing ? "checkmark" : "square.and.pencil")
                })
                .padding(.trailing, 20)
            }
            .padding(10)
            .background(Color(UIColor.systemGroupedBackground))
            NavigationStack{
                List {
                    ForEach(Array(userData.component[section_index][index].enumerated()), id: \.element){ index2, element in
                        SubView2(section_index: section_index, index: index, index2: index2, date: userData.list[section_index][index]["date"]!, numberPad: $numberPad)
                            .contextMenu(menuItems: {
                                Button {
                                    listening_sheet = true
                                    listening_sheet2 = index2
                                } label: {
                                    if let listening = element["listening"] {
                                        Text("\("リスニング: " + listening)")
                                    } else {
                                        Text("リスニングと紐付ける")
                                    }
                                }
                            })
                    }
                    .onMove(perform: { source, destination in
                        self.userData.component[section_index][index].move(fromOffsets: source, toOffset: destination)
                        self.keys.move(fromOffsets: source, toOffset: destination)
                        id += 1
                    })
                    .onDelete(perform: { offsets in
                        self.userData.component[section_index][index].remove(atOffsets: offsets)
                        self.keys.remove(atOffsets: offsets)
                    })
                }
                .id(id)
                .environment(\.editMode, self.$editMode)
            }
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(Color(UIColor.secondarySystemGroupedBackground), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(UIColor.secondarySystemGroupedBackground), for: .bottomBar)
            .toolbarBackground(.visible, for: .bottomBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading){
                    HStack {
                        Button(action: {showEditIcon.toggle()}){
                            HStack {
                                Image(systemName: userData.list[section_index][index]["image"]!)
                                    .foregroundColor(Color(UIColor.systemBackground))
                                    .font(.system(size: 13))
                                    .frame(width:24, height:24)
                                    .bold()
                                    .background(
                                        RoundedRectangle(cornerRadius: 4.0)
                                            .foregroundColor(Color(wordName: userData.list[section_index][index]["color"]!))
                                    )
                            }
                            .sheet(isPresented: $showEditIcon, onDismiss: {}) {
                                EditIcon(section_index: section_index, index: index)
                                    .presentationDetents([.large])
                            }
                        }
                        .disabled(showTextField)
                        VStack {
                            TextField(showTextField ? userData.list[section_index][index]["name"]! : "名称未設定", text: $name)
                                .foregroundColor(Color(wordName: userData.list[section_index][index]["color"]!))
                                .opacity(showTextField ? 1 : 0.5)
                                .font(.system(size: 20))
                                .frame(width: 180)
                                .textInputAutocapitalization(.never)
                                .multilineTextAlignment(.center)
                                .focused($nameFocus)
                                .bold()
                                .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)){ obj in
                                    if let textField = obj.object as? UITextField {
                                        if name == "Sample" {
                                            textField.selectedTextRange = textField.textRange(
                                                from: textField.beginningOfDocument,
                                                to: textField.endOfDocument
                                            )
                                        }
                                    }
                                }
                                .onSubmit {
                                    userData.list[section_index][index]["name"] = self.name
                                    showTextField = false
                                }
                                .onTapGesture {
                                    nameFocus = true
                                }
                                .disabled(!showTextField)
                            Divider()
                                .opacity(showTextField ? 1 : 0)
                                .frame(width:180)
                                .offset(y: -10)
                        }
                        .offset(y: 3)
                        if showTextField {
                            Text("")
                                .modifier(TextFieldClearButton(text: showTextField ? $name : $name2, focus: _nameFocus))
                        }
                        else {
                            Menu {
                                Button(action: {
                                    showTextField.toggle()
                                    nameFocus = true
                                }){
                                    HStack{
                                        Text("名称を変更")
                                        Spacer()
                                        Image(systemName: "pencil")
                                    }
                                }
                                Button(action: {showEditIcon.toggle()}){
                                    HStack{
                                        Text("アイコンを選択")
                                        Spacer()
                                        Image(systemName: "photo")
                                    }
                                }
                                Button(action: {showEditTime.toggle()}){
                                    HStack{
                                        Text("時間を編集")
                                        Spacer()
                                        Image(systemName: "clock")
                                    }
                                }
                            }
                            label: {
                                Image(systemName: "chevron.down.circle.fill")
                                    .foregroundColor(Color(UIColor.opaqueSeparator).opacity(showTextField ? 0: 1))
                            }
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
                        FileImportButton(color: Color(wordName: userData.list[section_index][index]["color"]!)!,
                                         keys: keys,
                                         selectedFiles: $selectedFiles,
                                         start_listening: $ongoing,
                                         showAlert: $showAlert)
                        .id(id2)
                        .padding()
                        Text("セクションごとに通知")
                        Toggle("", isOn: $section_notice)
                            .labelsHidden()
                            .toggleStyle(.switch)
                    }
                    .sheet(isPresented: $ongoing, onDismiss: {}) {
                        TimerView(section_index: section_index,
                                  index: index,
                                  section_notice: section_notice,
                                  time: Int(userData.list[section_index][index]["time"]!)!,
                                  date: dfS_D(date: userData.list[section_index][index]["date"]!),
                                  keys: $keys,
                                  selectedFiles: $selectedFiles)
                        .presentationDetents([.large])
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    if numberPad {
                        Spacer()
                        Button("完了"){
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            numberPad = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $listening_sheet, onDismiss: {}) {
            Listening2(section_index: section_index, index: index, index2: listening_sheet2, keys: $keys)
                .presentationDetents([.medium])
        }
        .onTapGesture {
            if showTextField {
                userData.list[section_index][index]["name"] = self.name
                showTextField = false
            }
        }
        .onAppear{
            appData.tabZIndex = 2.0
            self.name = userData.list[section_index][index]["name"]!
            self.section_notice = userSettings.section_notice
            for dictionary in userData.component[section_index][index] {
                if dictionary.keys.contains("listening") {
                    self.keys.append(dictionary["listening"]!)
                } else {
                    self.keys.append("")
                }
            }
        }
        .onWillDisappear{
            appData.tabZIndex = 0.0
        }
        .onDisappear{
            userData.list[section_index][index]["name"] = self.name
        }
        .onChange(of: keys) { oldValue, newValue in
            self.id2 += 1
        }
    }
}
func dfS_D(date: String) -> Date{
    let df = DateFormatter()
    df.locale = Locale(identifier: "ja_JP")
    df.dateStyle = .medium
    df.timeStyle = .short
    return df.date(from: date) ?? Date()
}


// MARK: EditTime
struct EditTime: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userData: UserData
    let section_index: Int
    let index: Int
    @State private var time: Int = 0
    @State private var date: Date = Date()
    @State var toggle: Bool = true
    @FocusState var timeFocus: Bool
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    VStack{
                        ZStack{
                            Text("分")
                                .frame(width: 100, alignment: .trailing)
                                .font(.system(size: 20))
                            TextField("", value: $time, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .frame(width: 100)
                                .font(.system(size: 22))
                                .multilineTextAlignment(.center)
                                .focused($timeFocus)
                                .onTapGesture {
                                    timeFocus = true
                                }
                        }
                        Divider()
                            .frame(width:100)
                            .offset(y: -8)
                    }
                    .offset(y: 2)
                    .padding(.trailing, 20)
                    if toggle {
                        Text("\(dfD_S2(date: date)) ~ \(dfD_S2(date: start_end(time: time, date: date)))")
                            .font(.system(size: 20))
                    }
                }
                .padding(.bottom, 20)
                HStack {
                    Text("日時を設定")
                    Toggle("", isOn: $toggle)
                        .labelsHidden()
                        .toggleStyle(.switch)
                }
                HStack {
                    if toggle {
                        DatePicker("", selection: $date)
                            .environment(\.locale, Locale(identifier: "ja_JP"))
                            .font(.system(size: 20))
                            .frame(alignment: .leading)
                            .datePickerStyle(GraphicalDatePickerStyle())
                    }
                }
            }
            .padding(.leading, 20)
            .navigationTitle("時間")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {dismiss()}){
                        Text("完了")
                            .bold()
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("完了"){
                        timeFocus = false
                    }
                }
            }
        }
        .onAppear{
            self.time = Int(userData.list[section_index][index]["time"]!)!
            self.date = dfS_D(date: userData.list[section_index][index]["date"]!)
            if userData.list[section_index][index]["date"]! == "" {
                self.toggle = false
            }
        }
        .onDisappear{
            userData.list[section_index][index]["time"] = String(self.time)
            if toggle {
                userData.list[section_index][index]["date"] = dfD_S(date: self.date)
            }
            else {
                userData.list[section_index][index]["date"] = ""
            }
        }
    }
    func dfD_S(date: Date) -> String{
        let df = DateFormatter()
        df.locale = Locale(identifier: "ja_JP")
        df.dateStyle = .medium
        df.timeStyle = .short
        return df.string(from: date)
    }
    func dfD_S2(date: Date) -> String{
        let df = DateFormatter()
        df.locale = Locale(identifier: "ja_JP")
        df.dateStyle = .none
        df.timeStyle = .short
        return df.string(from: date)
    }
    func dfS_D(date: String) -> Date{
        let df = DateFormatter()
        df.locale = Locale(identifier: "ja_JP")
        df.dateStyle = .medium
        df.timeStyle = .short
        return df.date(from: date) ?? Date()
    }
    func start_end(time: Int, date: Date) -> Date{
        return Calendar.current.date(byAdding: .minute, value: time, to: date)!
    }
}

// MARK: EditIcon
struct EditIcon: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userData: UserData
    let section_index: Int
    let index: Int
    let colorList = ["uiRed", "red", "pink", "orange", "yellow", "uiGreen", "green", "teal", "cyan", "blue", "indigo", "purple", "gray", "brown", "primary"]
    @State private var selectedIndex = 0
    let iconList = ["circle", "questionmark.circle", "exclamationmark.circle", "pencil", "highlighter", "pencil.tip", "globe.asia.australia", "book", "book.closed", "character.book.closed", "graduationcap", "flag", "clock", "timer", "globe.desk", "globe", "x.squareroot", "angle", "compass.drawing", "sum", "percent", "function", "plus", "minus", "plusminus", "multiply", "divide", "equal", "lessthan", "greaterthan", "number", "moon", "cloud", "bolt", "camera", "doc.text", "pencil.and.ruler", "cube", "chart.xyaxis.line", "tree", "pill", "humidity", "mountain.2", "heart", "star", "play.circle", "speaker.wave.2.circle", "puzzlepiece.extension", "gamecontroller", "a.circle", "b.circle", "c.circle", "d.circle", "e.circle", "f.circle", "g.circle", "h.circle", "i.circle", "j.circle", "k.circle", "l.circle", "m.circle", "n.circle", "o.circle", "p.circle", "q.circle", "r.circle", "s.circle", "t.circle", "u.circle", "v.circle", "w.circle", "x.circle", "y.circle", "z.circle", "0.circle", "1.circle", "2.circle", "3.circle", "4.circle", "5.circle", "6.circle", "7.circle", "8.circle", "9.circle"]
    @State private var selectedIndex2 = 0
    
    var body: some View {
        NavigationView{
            List{
                Section {
                    Image(systemName: userData.list[section_index][index]["image"]!)
                        .font(.system(size: 43))
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color(UIColor.systemBackground))
                        .bold()
                        .background(
                            Circle()
                                .foregroundColor(Color(wordName: userData.list[section_index][index]["color"]!))
                                .frame(width: 80, height: 80)
                        )
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(10)
                }
                Section {
                    VStack{
                        ForEach(0..<3, id: \.self, content: { itemIndex0 in
                            HStack{
                                ForEach(0..<5, id: \.self, content: { itemIndex1 in
                                    Button(action: {}){
                                        ZStack{
                                            Image(systemName: "circle.fill")
                                                .foregroundColor(Color(wordName: colorList[5 * itemIndex0 + itemIndex1]))
                                                .frame(width: 55, height: 55)
                                                .font(.system(size: 38))
                                            Image(systemName: "circle")
                                                .foregroundColor(.gray)
                                                .opacity(self.selectedIndex == 5 * itemIndex0 + itemIndex1 ? 0.5 : 0.0)
                                                .frame(width: 55, height: 55)
                                                .font(.system(size: 50))
                                                .fontWeight(.light)
                                        }
                                        .onTapGesture {
                                            self.selectedIndex = 5 * itemIndex0 + itemIndex1
                                            userData.list[section_index][index]["color"] = colorList[5 * itemIndex0 + itemIndex1]
                                        }
                                    }
                                })
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        })
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                Section{
                    VStack{
                        ForEach(0..<iconList.count/5, id: \.self, content: { itemIndex2 in
                            HStack{
                                ForEach(0..<5, id: \.self, content: { itemIndex3 in
                                    ZStack{
                                        Image(systemName: iconList[5 * itemIndex2 + itemIndex3])
                                            .foregroundColor(Color(UIColor.secondaryLabel))
                                            .frame(width: 55, height: 55)
                                            .font(.system(size: 28))
                                        Image(systemName: "circle.fill")
                                            .foregroundColor(.gray)
                                            .opacity(self.selectedIndex2 == 5 * itemIndex2 + itemIndex3 ? 0.5 : 0.0)
                                            .frame(width: 55, height: 55)
                                            .font(.system(size: 50))
                                            .fontWeight(.light)
                                    }
                                    .onTapGesture {
                                        self.selectedIndex2 = 5 * itemIndex2 + itemIndex3
                                        userData.list[section_index][index]["image"] = iconList[5 * itemIndex2 + itemIndex3]
                                    }
                                })
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        })
                    }
                }
            }
            .navigationTitle("アイコン")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                Button(action: {dismiss()}){
                    Text("完了")
                        .bold()
                }
            }
        }
        .onAppear(){
            selectedIndex = colorList.firstIndex(of: userData.list[section_index][index]["color"]!) ?? 0
            selectedIndex2 = iconList.firstIndex(of: userData.list[section_index][index]["image"]!) ?? 0
        }
    }
}


// MARK: SubView2
struct SubView2 : View {
    let section_index: Int
    let index: Int
    let index2: Int
    let date: String
    @Binding var numberPad: Bool
    @EnvironmentObject var userData: UserData
    @State var name: String = ""
    @State var minute: Int = 0
    @FocusState var focus: FocusField?
    var body: some View{
        HStack{
            Text("")
            VStack{
                TextField("\(index2 + 1)", text: $name)
                    .frame(width:100)
                    .font(.system(size: 20))
                    .submitLabel(.done)
                    .focused($focus, equals: .name)
                    .onTapGesture {
                        focus = .name
                    }
                    .onSubmit {
                        focus = nil
                    }
                Divider()
                    .frame(width: 100)
                    .offset(y: -5)
            }
            .padding(.trailing, 20)
            VStack{
                ZStack{
                    Text("分")
                        .frame(width: 50, alignment: .trailing)
                        .font(.system(size: 18))
                    TextField("", value: $minute, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .frame(width: 50)
                        .font(.system(size: 20))
                        .focused($focus, equals: .minute)
                        .onTapGesture {
                            focus = .minute
                            numberPad = true
                        }
                }
                .offset(y: 4)
                Divider()
                    .frame(width: 70)
                    .offset(y: -5)
            }
            if date != "" {
                VStack{
                    Text(dfD_S2(date: plusTime(minute: minute)))
                }
            }
            if userData.component[section_index][index][index2].keys.contains("listening") {
                Spacer()
                Image(systemName: "headphones.circle.fill")
                    .foregroundColor(Color(wordName: userData.list[section_index][index]["color"]!)!)
            }
        }
        .onChange(of: focus) { oldValue, newValue in
            if newValue == .minute {
                self.numberPad = true
            } else if newValue == .name {
                self.numberPad = false
            } else {
                self.userData.component[section_index][index][index2]["name"] = name
                self.userData.component[section_index][index][index2]["minute"] = String(minute)
            }
        }
        .onAppear(){
            self.name = userData.component[section_index][index][index2]["name"]!
            self.minute = Int(userData.component[section_index][index][index2]["minute"]!)!
        }
    }
    func plusTime(minute: Int) -> Date{
        var j = 0
        var time = minute
        while j < index2 {
            time += Int(userData.component[section_index][index][j]["minute"]!)!
            j += 1
        }
        return Calendar.current.date(byAdding: .minute, value: time, to: dfS_D(date: date))!
    }
    func dfD_S2(date: Date) -> String{
        let df = DateFormatter()
        df.locale = Locale(identifier: "ja_JP")
        df.dateStyle = .none
        df.timeStyle = .short
        return df.string(from: date)
    }
    func dfS_D(date: String) -> Date{
        let df = DateFormatter()
        df.locale = Locale(identifier: "ja_JP")
        df.dateStyle = .medium
        df.timeStyle = .short
        return df.date(from: date) ?? Date()
    }
}

enum FocusField: Hashable {
    case name
    case minute
}




extension Color {
    init?(wordName: String) {
        switch wordName {
        case "primary":     self = .primary
        case "gray":        self = .gray
        case "indigo":      self = .indigo
        case "cyan":        self = .cyan
        case "teal":        self = .teal
        case "yellow":      self = .yellow
        case "pink":        self = .pink
        case "brown":       self = .brown
        case "purple":      self = .purple
        case "blue":        self = .blue
        case "green":       self = .green
        case "uiGreen":     self = Color(UIColor.green)
        case "orange":      self = .orange
        case "red":         self = .red
        case "uiRed":       self = Color(UIColor.red)
        default:            self = .primary
        }
    }
}






struct Listening2: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var zIndex: AppData
    let section_index: Int
    let index: Int
    let index2: Int
    @Binding var keys: [String]
    var body: some View {
        NavigationStack {
            List {
                Section {
                    let sortedDict = userData.listening.sorted(by: {$0.key < $1.key})
                    ForEach(Array(sortedDict), id: \.key) { key2, value in
                        HStack {
                            Button(action: {
                                userData.component[section_index][index][index2].updateValue(key2, forKey: "listening")
                                keys[index2] = key2
                                dismiss()
                                print(keys)
                            }, label: {
                                Text(key2)
                                    .font(.system(size: 20))
                                    .foregroundColor(Color.primary)
                                    .bold()
                            })
                            Spacer()
                        }
                    }
                }
                Section {
                    HStack {
                        Button(action: {
                            userData.component[section_index][index][index2].removeValue(forKey: "listening")
                            keys[index2] = ""
                            dismiss()
                        }, label: {
                            Text("紐付けを解除する")
                                .font(.system(size: 20))
                                .foregroundColor(Color.primary)
                                .bold()
                        })
                        Spacer()
                    }
                }
            }
        }
    }
}
