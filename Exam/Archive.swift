import SwiftUI
import Charts
import Foundation


enum Sort {
    case up
    case down
    case score
}

struct Archive: View {
    @EnvironmentObject var userData: UserData
    @State var section_index = 0
    @State var indexes = [0, 0, 0]
    @State var sort: Sort = .up
    @State var showAlert: Bool = false
    @State var alert_offsets: IndexSet = []
    @State private var selected = 0
    var body: some View {
        NavigationStack {
            VStack {
                Picker("データ", selection: $selected) {
                    Text("記録").tag(0)
                    Text("グラフ").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(10)
                if indexes[section_index] < userData.archive[section_index].count {
                    let sortedDict = userData.archive[section_index][indexes[section_index]].sorted(by: {
                        switch sort {
                        case .up:
                            $0.key < $1.key
                        case .down:
                            $0.key > $1.key
                        case .score:
                            $0.key > $1.key
                        }
                    })
                    if selected == 0 {
                        List {
                            ForEach(Array(sortedDict), id: \.key) { key, value in
                                Archive_SubView(date: key, contents: value, section_index: section_index, index: indexes[section_index])
                            }
                            .onDelete(perform: { offset in
                                alert_offsets = offset
                                showAlert = true
                            })
                        }
                    } else {
                        List {
                            AreaChartView(data: makeChartData(sortedDict))
                        }
                    }
                } else {
                    Text("データがありません")
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
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
                            .frame(width: 70, height: 20)
                    }
                    Menu {
                        ForEach(Array(userData.list[section_index].enumerated()), id: \.element){ index, element in
                            Button(action: {
                                indexes[section_index] = index
                            }) {
                                Text("\(element["name"] ?? "")")
                            }
                        }
                    } label: {
                        if userData.list[section_index].count > indexes[section_index] {
                            Text("\(userData.list[section_index][indexes[section_index]]["name"]!)")
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .frame(width: 70, height: 20)
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(action: {sort = .up}, label: {
                            Label("昇順", systemImage: sort == .up ?"checkmark" : "")
                        })
                        Button(action: {sort = .down}, label: {
                            Label("降順", systemImage: sort == .down ?"checkmark" : "")
                        })
                        Button(action: {sort = .score}, label: {
                            Label("点数順", systemImage: sort == .score ?"checkmark" : "")
                        })
                    } label: {
                        Image(systemName: "arrow.up.and.down.text.horizontal")
                    }
                }
            }
        }
        .alert("削除", isPresented: $showAlert) {
            Button("削除", role: .destructive){
                var sortedDict = userData.archive[section_index][indexes[section_index]].sorted(by: {
                    switch sort {
                    case .up:
                        $0.key < $1.key
                    case .down:
                        $0.key > $1.key
                    case .score:
                        $0.key > $1.key
                    }
                })
                sortedDict.remove(atOffsets: alert_offsets)
                userData.archive[section_index][indexes[section_index]] = Dictionary(uniqueKeysWithValues: sortedDict)
            }
            Button("キャンセル", role: .cancel){
                showAlert = false
            }
        } message: {
            Text("削除すると戻せません。実行しますか？")
        }
    }
    func makeChartData(_ group_of_contents: Array<Dictionary<String, Array<Dictionary<String, String>>>.Element>) -> [ChartData3] {
        return group_of_contents.flatMap { contents in
            var contents2: [[String: String]] = []
            var contents3: [String] = []
            for dictionary in contents.value {
                if let holder = dictionary["holder"] {
                    if contents3.contains(holder) {
                        let existingDictIndex = contents2.firstIndex(where: {$0["holder"] == holder})
                        contents2[existingDictIndex!]["time"] = contents2[existingDictIndex!]["time"]! + "+" + dictionary["time"]!
                    } else {
                        contents2.append(dictionary)
                        contents3.append(holder)
                    }
                }
            }
            let contents4 = contents2.map { dictionary in
                var modifiedDictionary: ChartData2 = ChartData2(id: "0000", name: "", time: 2, date: "")
                if let holder = dictionary["holder"] {
                    modifiedDictionary.id = holder
                    let index2 = userData.searchComponents(section_index: section_index, index: indexes[section_index], holder: holder)
                    modifiedDictionary.name = index2 == nil ? "その他" : userData.component[section_index][indexes[section_index]][index2!]["name"]!
                }
                if let time = dictionary["time"] {
                    let expn = NSExpression(format: time)
                    if let time2 = expn.expressionValue(with: nil, context: nil) as? Int {
                        modifiedDictionary.time = time2
                    }
                }
                modifiedDictionary.date = contents.key
                return modifiedDictionary
            }
            return contents4.map { ChartData3(data: $0)}
        }
    }
}


struct Archive_SubView: View {
    let date: String
    let contents: [[String: String]]
    let section_index: Int
    let index: Int
    var body: some View {
        NavigationLink(){
            Archive_ChildView(date: date, contents: contents, section_index: section_index, index: index)
        }
        label: {
            Text(date)
                .font(.system(size: 20))
                .foregroundColor(Color.primary)
                .bold()
        }
    }
}

struct Archive_ChildView: View {
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var appData: AppData
    let date: String
    let contents: [[String: String]]
    let section_index: Int
    let index: Int
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(contents.enumerated()), id: \.offset) { index3, element in
                    let index2 = userData.searchComponents(section_index: section_index, index: index, holder: element["holder"]!)
                    let selectedOption = index2 == nil ? nil : userData.component[section_index][index][index2!]["name"]
                    Archive_SubView2(date: date, section_index: section_index, index: index, index2: index2, index3: index3, selectedOption: selectedOption)
                }
            }
            PieChartView(data: makeChartData(contents))
        }
        .onAppear{
            appData.tabZIndex = 2.0
        }
        .onWillDisappear{
            appData.tabZIndex = 0.0
        }
    }
    func makeChartData(_ contents: Array<Dictionary<String, String>>) -> [ChartData]{
        var contents2: [[String: String]] = []
        var contents3: [String] = []
        for dictionary in contents {
            if let holder = dictionary["holder"] {
                if contents3.contains(holder) {
                    let existingDictIndex = contents2.firstIndex(where: {$0["holder"] == holder})
                    contents2[existingDictIndex!]["time"] = contents2[existingDictIndex!]["time"]! + "+" + dictionary["time"]!
                } else {
                    contents2.append(dictionary)
                    contents3.append(holder)
                }
            }
        }
        return contents2.map {dictionary in
            var modifiedDictionary: ChartData = ChartData(id: "0000", name: "", time: 2)
            if let holder = dictionary["holder"] {
                modifiedDictionary.id = holder
                let index2 = userData.searchComponents(section_index: section_index, index: index, holder: holder)
                modifiedDictionary.name = index2 == nil ? "その他" : userData.component[section_index][index][index2!]["name"]!
            }
            if let time = dictionary["time"] {
                let expn = NSExpression(format: time)
                if let time2 = expn.expressionValue(with: nil, context: nil) as? Int {
                    modifiedDictionary.time = time2
                }
            }
            return modifiedDictionary
        }
    }
}


struct Archive_SubView2: View {
    @EnvironmentObject var userData: UserData
    let date: String
    let section_index: Int
    let index: Int
    let index2: Int?
    let index3: Int
    @State var selectedOption: String?
    @State private var time: Int = 0
    var body: some View {
        HStack {
            Text("")//listの線が消えないようにするため
            Menu {
                ForEach(userData.component[section_index][index], id: \.self) { option in
                    Button(action: {
                        selectedOption = option["name"]
                        userData.archive[section_index][index][date]![index3].updateValue(option["holder"]!, forKey: "holder")
                    }) {
                        Text(option["name"]!)
                    }
                }
                Button(action: {
                    selectedOption = nil
                    userData.archive[section_index][index][date]![index3].updateValue("0000", forKey: "holder")
                }) {
                    Text("その他")
                }
            } label: {
                Text(selectedOption ?? "その他")
                    .foregroundColor(selectedOption == nil ? .gray : .primary)
                    .font(.system(size: 20))
            }
            if index2 != nil {
                Text("\(String(userData.component[section_index][index][index2!]["minute"]!))分 ")
            } else {
                Text("")
            }
            Spacer()
            Text("\(String(time / 60) + "分" + String(time % 60))秒")
                .font(.system(size: 20))
        }
        .padding(5)
        .onAppear() {
            self.time = Int(userData.archive[section_index][index][date]![index3]["time"]!)!
        }
    }
}



struct ChartData: Identifiable {
    var id: String
    var name: String
    var time: Int
}

struct PieChartView: View {
    let data: [ChartData]
    @State var selectedAngle: Int?
    var selectedData: [String: String] {
        guard let selectedAngle else { return ["id": "a", "name": "カテゴリー", "time": "時間"] }
        var sum = 0
        for item in data {
            sum += item.time
            if selectedAngle < sum {
                let time = String(item.time / 60) + "分" + String(item.time % 60) + "秒"
                return ["id": item.id, "name": item.name, "time": time]
            }
        }
        return ["id": "a", "name": "カテゴリー", "time": "時間"]
    }

    var body: some View {
        Chart(data) { item in
            SectorMark(
                angle: .value("時間", item.time),
                innerRadius: .ratio(0.6),
                outerRadius: .ratio(1.5),
                angularInset: 1.0
            )
            .foregroundStyle(by: .value("カテゴリー", item.name))
            .opacity(item.id == selectedData["id"] ? 1.0 : 0.3)
        }
        .frame(width: 300, height: 300)
        .padding()
        .chartAngleSelection(value: $selectedAngle)
        .chartBackground { chartProxy in
            GeometryReader { geometry in
                let frame = geometry[chartProxy.plotFrame!]
                VStack {
                    Text(selectedData["name"]!)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    Text(selectedData["time"]!)
                        .font(.title2.bold())
                        .foregroundColor (.primary)
                }
                .position(x: frame.midX, y: frame.midY)
            }
        }
    }
}


struct ChartData2: Identifiable {
    var id: String
    var name: String
    var time: Int
    var date: String
}
struct ChartData3: Identifiable {
    let id = UUID()
    var data: ChartData2
}
enum MixedValue {
    case String(String)
    case Dictionary([String: String])
}

struct AreaChartView: View {
    @EnvironmentObject var userData: UserData
    let data: [ChartData3]
    @State var selectedX: Int?
    @State var selectedY: String?
    var selectedData: [String: MixedValue] {
        guard let selectedX else { return ["id": .String(""), "data": .Dictionary(["id": "a", "name": "カテゴリー", "time": "時間", "date": "日付"])] }
        var sum = 0
        for items in data {
            if items.data.date == selectedY {
                sum += items.data.time
                if selectedX < sum {
                    let time = String(items.data.time / 60) + "分" + String(items.data.time % 60) + "秒"
                    return ["id": .String(items.data.date), "data": .Dictionary(["id": items.data.id, "name": items.data.name, "time": time, "date": items.data.date])]
                }
            }
        }
        return ["id": .String(""), "data": .Dictionary(["id": "a", "name": "カテゴリー", "time": "時間", "date": "日付"])]
    }

    var body: some View {
        Chart(data) { item in
            if case .Dictionary(let value) = selectedData["data"] {
                BarMark(
                    x: .value("Time", item.data.time),
                    y: .value("Date", item.data.date)
                )
                .foregroundStyle(by: .value("カテゴリー", item.data.name))
                .opacity(item.data.date == value["date"]! && item.data.id == value["id"]! ? 1.0 : 0.3)
            }
        }
        .frame(height: CGFloat(50 * count(data) + 100))
        .padding()
        .padding(.bottom, 100)
        .chartXSelection(value: $selectedX)
        .chartYSelection(value: $selectedY)
        .chartBackground { chartProxy in
            GeometryReader { geometry in
                let frame = geometry[chartProxy.plotFrame!]
                if case .Dictionary(let value) = selectedData["data"] {
                    VStack {
                        Text(value["date"]!)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                        Text("\(value["name"]!): \(value["time"]!)")
                            .font(.system(size: 18))
                            .foregroundColor (.primary)
                    }
                    .position(x: frame.midX, y: frame.maxY + 100)
                }
            }
        }
    }
    func count(_ data: [ChartData3]) -> Int {
        var set: Array<String> = []
        for dictionary in data {
            set.append(dictionary.data.date)
        }
        return Set(set).count
    }
}
