import SwiftUI
import AudioToolbox
import AVFoundation
import BackgroundTasks
import UserNotifications


struct Tab: Identifiable, Hashable {
    var id: String
    var title: String
    var image: String
}

let tabs: [Tab] = [
    Tab(id: "0", title: "時間配分", image: "clock"),
    Tab(id: "1", title: "リスニング", image: "headphones"),
    Tab(id: "2", title: "記録", image: "archivebox"),
    Tab(id: "3", title: "マイページ", image: "person.circle")
    ]

struct SelectedTabPath: View {
    let x: CGFloat = UIScreen.main.bounds.size.width / 2
    let y: CGFloat =  UIScreen.main.bounds.size.height / 2 - 50
    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: x - 27, y: y - 25))
                path.addArc(
                    tangent1End: CGPoint(x: x - 27, y: y),
                    tangent2End: CGPoint(x: x - 37, y: y),
                    radius: 10
                )
                path.addLine(to: CGPoint(x: x - 27, y: y))
                path.closeSubpath()
            }
            .fill(Color(UIColor.secondarySystemGroupedBackground))
            Path { path in
                path.move(to: CGPoint(x: x + 27, y: y - 25))
                path.addArc(
                    tangent1End: CGPoint(x: x + 27, y: y),
                    tangent2End: CGPoint(x: x + 37, y: y),
                    radius: 10
                )
                path.addLine(to: CGPoint(x: x + 27, y: y))
                path.closeSubpath()
            }
            .fill(Color(UIColor.secondarySystemGroupedBackground))
        }
    }
}

struct ContentView: View {
    @State var selectedIndex = 0
    @State var saveData = false
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var userData: UserData
    let tabWidth: CGFloat = UIScreen.main.bounds.size.width / CGFloat(tabs.count)
    var body: some View {
        ZStack {
            ZStack {
                if(selectedIndex == 0){
                    Allotment()
                }
                else if(selectedIndex == 1){
                    Listening()
                }
                else if(selectedIndex == 2){
                    Archive()
                }
                else if(selectedIndex == 3){
                    MyPage()
                }
            }
            .zIndex(appData.tabZIndex)
            
            ZStack {
                let selectedTabFloat: CGFloat = tabWidth * CGFloat(Double(self.selectedIndex) + 0.5)
                Circle()
                    .foregroundStyle(Color(UIColor.secondarySystemGroupedBackground))
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: -5)
                    .frame(width: 60, height: 60)
                    .position(x: selectedTabFloat, y: UIScreen.main.bounds.size.height - 130)
                Rectangle()
                    .foregroundStyle(Color(UIColor.secondarySystemGroupedBackground))
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: -5)
                    .frame(width: UIScreen.main.bounds.size.width, height: 90)
                    .ignoresSafeArea(edges: [.trailing, .leading])
                    .position(x: UIScreen.main.bounds.size.width / 2, y: UIScreen.main.bounds.size.height - 90)
                ZStack {
                    Circle()
                        .foregroundStyle(Color(UIColor.secondarySystemGroupedBackground))
                        .frame(width: 60, height: 60)
                    Circle()
                        .foregroundStyle(Color.accentColor)
                        .frame(width: 45, height: 45)
                    SelectedTabPath()
                }
                .position(x: selectedTabFloat, y: UIScreen.main.bounds.size.height - 130)
                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(Array(tabs.enumerated()), id: \.element){ index, element in
                        VStack(spacing: 0) {
                            Spacer()
                            Image(systemName: tabs[index].image)
                                .font(.system(size: 25))
                                .foregroundStyle(self.selectedIndex == index ? Color(UIColor.secondarySystemGroupedBackground) : .accentColor)
                                .frame(height: 55)
                            Text(tabs[index].title)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(self.selectedIndex == index ? Color.primary : .clear)
                                .frame(width: 70)
                            Rectangle()
                                .foregroundStyle(.clear)
                                .frame(height: self.selectedIndex == index ? 25 : 5)
                        }
                        .frame(width: tabWidth)
                        .onTapGesture {
                            withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.7) ) { self.selectedIndex = index }
                        }
                    }
                }
                .frame(height: 130)
                .ignoresSafeArea(edges: [.trailing, .leading])
                .position(x: UIScreen.main.bounds.size.width / 2, y: UIScreen.main.bounds.size.height - 130)
            }
            .zIndex(appData.elseZIndex)
            
            
            Button(action: {
                saveData.toggle()
            }, label: {
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 25))
                    .frame(width: 60, height: 60)
                    .foregroundStyle(Color.white)
                    .background(
                        Circle()
                            .fill(Color.blue.shadow(.drop(color: .black.opacity(0.3), radius: 10)))
                    )
            })
            .position(x: UIScreen.main.bounds.size.width - 50, y: UIScreen.main.bounds.size.height - 200)
            .zIndex(appData.elseZIndex)
        }
        .alert("データを保存", isPresented: $saveData) {
            let save_number = Int(userData.save["number"]!)!
            if(save_number == 0){
                Button("広告を見て保存"){
                    userData.setData()
                }
            }
            else{
                Button("保存"){
                    userData.save["number"] = String(save_number - 1)
                    userData.setData()
                }
            }
            Button("キャンセル", role: .cancel){}
        } message: {
            Text("保存は、1日2回まで自由に利用できます。\n残り0回でも、広告を見れば保存できます。\n\n残り\(userData.save["number"]!)回。")
        }
    }
}








struct ClockHands:View {
    let size = UIScreen.main.bounds.width
    let protrusion: CGFloat
    let color: UIColor
    let lineWidth: CGFloat
    var body: some View {
        Path{path in
            path.move(to: CGPoint(x: size/2, y: size/2 + protrusion))
            path.addLine(to: CGPoint(x: size/2, y: size/2 - (size * 3/10)))
        }
        .stroke(Color(color), lineWidth: lineWidth)
    }
}

struct Ticks: View {
    var body: some View {
        ZStack {
            ForEach(0..<60) { position in
                Tick(isLong: position % 5 == 0)
                    .stroke(lineWidth: 2 + (position % 5 == 0 ? 3 : 0) + (position % 15 == 0 ? 3 : 0))
                    .rotationEffect(.radians(Double.pi * 2 / 60 * Double(position)))
            }
        }
    }
}
struct Tick: Shape {
    var isLong: Bool = false
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY + 8 + (isLong ? 12 : 0)))
        return path
    }
}

struct TimerView: View {
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var userSettings: UserSettings
    let section_index: Int
    let index: Int
    let section_notice: Bool
    let time: Int
    let date: Date
    var circleSize = UIScreen.main.bounds.width * 0.65
    @State var restMinute = 0
    @State var restSecond = 0
    @State var hour = 0
    @State var minute = 0
    @State var second = 0
    @State var count = 0
    @State var count2 = 0
    @State var record_count = 0
    @State var index2 = 0
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    @Environment(\.dismiss) var dismiss
    @State private var showAlert = false
    @State var stop = false
    @State var record = Array<Dictionary<String, String>>()
    @State var timerSound = 0
    var formattedDate: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年MM月dd日　HH:mm"
            return formatter.string(from: Date())
        }
    
    @Binding var keys: [String]
    @Binding var selectedFiles: [URL]
    var body: some View {
        VStack{
            if userSettings.digital_clock {
                HStack(alignment: .top){
                    Text("\(time - restMinute)")
                        .foregroundColor(.primary)
                        .font(Font(UIFont.monospacedDigitSystemFont(ofSize: 50, weight: .bold)))
                        .frame(width: 100, alignment: .trailing)
                    Text("m")
                        .foregroundColor(.primary)
                        .frame(width: 20)
                    Text("\(String(format: "%02d", (60 - restSecond) % 60))")
                        .foregroundColor(.primary)
                        .font(Font(UIFont.monospacedDigitSystemFont(ofSize: 50, weight: .bold)))
                        .frame(width: 100, alignment: .trailing)
                    Text("s")
                        .foregroundColor(.primary)
                        .frame(width: 20)
                }
            }
            if userSettings.analog_clock {
                ZStack {
                    Circle()
                        .stroke(.primary, lineWidth: 5)
                        .frame(width: circleSize, height: circleSize)
                    Ticks()
                        .frame(width: circleSize, height: circleSize)
                    Circle()
                        .foregroundStyle(.primary)
                        .frame(width: 14, height: 14)
                    ClockHands(protrusion: 0, color: UIColor(.primary), lineWidth: 8)
                        .scaleEffect(0.7)
                        .rotationEffect(.degrees(Double(hour * 30) + Double(minute) * 0.5))
                    ClockHands(protrusion: 0, color: UIColor(.primary), lineWidth: 4)
                        .rotationEffect(.degrees(Double(minute * 6)))
                    ClockHands(protrusion: 20, color: .red, lineWidth: 2)
                        .rotationEffect(.degrees(Double(second * 6)))
                }
                .frame(height: UIScreen.main.bounds.width)
            }
            HStack{
                if userData.component[section_index][index][index2].keys.contains("listening") {
                    Listening_TimerView(key: keys[index2], files: $selectedFiles)
                        .id(index2)
                } else {
                    Button(action: {showAlert.toggle()}){
                        ZStack {
                            Circle()
                                .stroke(Color(UIColor.secondarySystemBackground), lineWidth: 4)
                                .frame(width: 78, height: 78)
                            Text("停止")
                                .foregroundColor(.primary)
                                .frame(width: 70, height: 70)
                                .background(
                                    Circle()
                                        .foregroundStyle(Color(UIColor.secondarySystemBackground))
                                )
                        }
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("終了"),
                              message: Text("タイマーを停止しますか？"),
                              primaryButton: .cancel(Text("キャンセル")),
                              secondaryButton: .default(Text("OK"), action: {
                            record.append(["holder": record.count < userData.component[section_index][index].count ? userData.component[section_index][index][record.count]["holder"]! : "0000", "time": String(record_count)])
                            dismiss()
                        }))
                    }
                    .padding()
                    Button(action: {stop.toggle()}){
                        ZStack {
                            Circle()
                                .stroke(Color(UIColor.secondarySystemBackground), lineWidth: 4)
                                .frame(width: 78, height: 78)
                            Text(stop ? "再開" : "一時停止")
                                .foregroundColor(.primary)
                                .frame(width: 70, height: 70)
                                .background(
                                    Circle()
                                        .foregroundStyle(Color(UIColor.secondarySystemBackground))
                                )
                        }
                    }
                    .padding()
                    Button(action: {
                        record.append(["holder": record.count < userData.component[section_index][index].count ? userData.component[section_index][index][record.count]["holder"]! : "0000", "time": String(record_count)])
                        self.record_count = 0
                    }){
                        ZStack {
                            Text(record.count < userData.component[section_index][index].count ? userData.component[section_index][index][record.count]["name"]! : "その他")
                                .offset(x: 0, y: -60)
                                .foregroundStyle(.primary)
                                .frame(width: 78)
                            Circle()
                                .stroke(Color(UIColor.secondarySystemBackground), lineWidth: 4)
                                .frame(width: 78, height: 78)
                            Text("記録")
                                .foregroundColor(.primary)
                                .frame(width: 70, height: 70)
                                .background(
                                    Circle()
                                        .foregroundStyle(Color(UIColor.secondarySystemBackground))
                                )
                        }
                    }
                    .padding()
                }
            }
        }
        .onReceive(timer){ _ in
            if !stop{
                self.restSecond = restSecond % 60 + 1
                self.restMinute = restMinute + (restSecond % 60 == 1 ? 1 : 0)
                self.second = (second + 1) % 60
                self.minute = (minute + (second % 60 == 0 ? 1 : 0)) % 60
                self.hour = (hour + (minute % 60 == 0 && second % 60 == 0 ? 1 : 0)) % 12
                self.count += 1
                self.count2 += 1
                self.record_count += 1
            }
            if count != time * 60 && count2 == Int(userData.component[section_index][index][index2]["minute"]!)! * 60 {
                if section_notice {
                    AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)){}
                }
                
                self.count2 = 0
                if index2 < userData.component[section_index][index].count - 1 {
                    self.index2 += 1
                }
            }
            if count == time * 60 && timerSound < 2 {
                stop = true
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ timer in
                    timerSound += 1
                }
                record.append(["holder": record.count < userData.component[section_index][index].count ? userData.component[section_index][index][record.count]["holder"]! : "0000", "time": String(record_count)])
                AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(userSettings.notice_sound), nil)
                dismiss()
            }
        }
        .onAppear(){
            self.hour = Calendar.current.component(.hour, from: date)
            self.minute = Calendar.current.component(.minute, from: date)
        }
        .onDisappear(){
            if !record.isEmpty {
                if index >= userData.archive[section_index].count {
                    userData.archive[section_index].append([:])
                    userData.archive[section_index][index].updateValue(record, forKey: formattedDate)
                } else {
                    userData.archive[section_index][index].updateValue(record, forKey: formattedDate)
                }
            }
        }
    }
}





struct Listening_TimerView: View {
    @EnvironmentObject var userData: UserData
    let key: String
    @Binding var files: [URL]
    @State var offset: [Int] = []
    @State var indices: [Int] = []
    @State var indices2: [Int] = []
    @State var indices3: [Int: Int] = [:]
    @State var actual_listening: [[String: String]] = []
    @Environment(\.dismiss) var dismiss
    @State private var task: Task<Void, Never>?
    @State private var progress: String = ""
    @State private var showAlert = false
    
    @State var holders: [String] = []
    var body: some View {
        HStack{
            Button(action: {showAlert.toggle()}){
                ZStack {
                    Circle()
                        .stroke(Color(UIColor.secondarySystemBackground), lineWidth: 4)
                        .frame(width: 78, height: 78)
                    Text("停止")
                        .foregroundColor(.primary)
                        .frame(width: 70, height: 70)
                        .background(
                            Circle()
                                .foregroundStyle(Color(UIColor.secondarySystemBackground))
                        )
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("終了"),
                      message: Text("リスニングを停止しますか？"),
                      primaryButton: .cancel(Text("キャンセル")),
                      secondaryButton: .default(Text("OK"), action: {dismiss()}))
            }
            .padding()
            Text(key)
                .foregroundColor(.primary)
                .frame(width: 78, height: 78)
                .padding()
            Text(progress)
                .foregroundColor(.primary)
                .frame(width: 78, height: 78)
        }
        .onAppear() {
            Lsitening_Manage_Repeat(listening: userData.listening[key]!, indices1: $indices, indices2: $indices2, offset: $offset, indices3: $indices3, actual_listening: $actual_listening)
            self.holders = userData.listening[key]!.compactMap {
                if $0["type"] == "0" {
                    return $0["holder"]
                } else {
                    return nil
                }
            }
            self.progress = ""
            task = Task {
                await manageAudios()
            }
        }
        .onDisappear() {
            task?.cancel()
            task = nil
            files.removeSubrange(0..<holders.count)
        }
    }
    func manageAudios() async {
        for element in actual_listening {
            if Task.isCancelled {return}
            await playAudio(element: element)
        }
    }
    func playAudio(element: [String: String]) async {
        if element["type"] == "0" {
            let url = files[holders.firstIndex(of: element["holder"]!)!]
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                self.progress = url.lastPathComponent
                player.play()
                while player.isPlaying {
                    try await Task.sleep(nanoseconds: 100_000_000)
                }
            } catch {
                print("Error playing audio file: \(error.localizedDescription)")
            }
        } else {
            try? await Task.sleep(nanoseconds: UInt64(Double(element["time"]!)!) * 1_000_000_000)
        }
    }
}
class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    private let onFinish: () -> Void

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinish()
    }
}


struct AudioPicker: View {
    @State private var showFileImporter = false
    @State private var selectedFiles: [URL] = []
    var body: some View {
        Text("")
    }
}





func setupInteractiveNotificationActions() {
    let action1 = UNNotificationAction(identifier: "ACCEPT_ACTION",
                                       title: "開始する",
                                       options: [.foreground])
    let action2 = UNNotificationAction(identifier: "DECLINE_ACTION",
                                       title: "中止する",
                                       options: [.destructive])
    
    let category = UNNotificationCategory(identifier: "INTERACTIVE_CATEGORY",
                                          actions: [action1, action2],
                                          intentIdentifiers: [],
                                          options: [])
    
    UNUserNotificationCenter.current().setNotificationCategories([category])
}

func scheduleInteractiveNotification(title: String, section_index: Int, index: Int, day: Int, hour: Int, minute: Int, identifier: String) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = "まもなくテストの時間です。準備をしましょう！"
    content.sound = .default
    content.categoryIdentifier = "INTERACTIVE_CATEGORY"
    content.userInfo = ["section_index": section_index, "index": index]
    
    var dateComponents = DateComponents()
    dateComponents.day = day
    dateComponents.hour = hour
    dateComponents.minute = minute - 5
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("通知スケジュールエラー: \(error)")
        } else {
            print("通知がスケジュールされました: \(hour):\(minute)")
        }
    }
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    var onOpenDetail: (() -> Void)?
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case "ACCEPT_ACTION":
            let appData = AppData()
            appData.notice_response = response
            onOpenDetail?()
        case "DECLINE_ACTION":
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        default:
            print("その他の操作")
        }
        completionHandler()
    }
}
