//
//  View4.swift
//  Exam
//
//  Created by 宮田尚文 on 2023/05/31.
//

import SwiftUI
import UIKit
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseOAuthUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import FirebaseEmailAuthUI
import AudioToolbox
import AVFoundation
import UserNotifications

struct MyPage: View {
    let authUI = FUIAuth.defaultAuthUI()
    let user = Auth.auth().currentUser
    @State var myName: String = Auth.auth().currentUser?.displayName ?? ""
    @State var editName: Bool = false
    @EnvironmentObject var authState: FirebaseAuthStateObserver
    @EnvironmentObject var appData: AppData
    var body: some View {
        VStack {
            NavigationStack {
                List {
                    Section(){
                        HStack {
                            NetworkImage(url: user?.photoURL)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50, alignment: .center)
                                .cornerRadius(8)
                            Text("\(myName)")
                                .bold()
                                .font(.system(size: 25))
                                .foregroundColor(Color.primary)
                                .padding()
                                .frame(width:250, height:50, alignment: .leading)
                            Button(action: {
                                editName.toggle()
                            }, label: {
                                Image(systemName: "pencil")
                                    .frame(width:30, height:30)
                                    .foregroundColor(Color(UIColor.systemBackground))
                                    .bold()
                                    .background(
                                        Circle()
                                            .foregroundColor(Color.gray)
                                    )
                            })
                            .buttonStyle(.plain)
                            .padding(3)
                        }
                        .listRowBackground(Color.white.opacity(0))
                    }
                    Section(header: Text("設定")){
                        NavigationLink("アプリ設定"){
                            AppSettings()
                        }
                        NavigationLink("通知設定"){
                            NoticeSettings()
                        }
                    }
                    Section(header: Text("その他")) {
                        NavigationLink("プライバシーポリシー") {
                            TermsView(index: 0, dismissBool: false)
                        }
                        NavigationLink("利用規約") {
                            TermsView(index: 1, dismissBool: false)
                        }
                    }
                    Section(){
                        HStack {
                            Spacer()
                            Button(action: {
                                do {
                                    try Auth.auth().signOut()
                                    authState.isSignin = false
                                }
                                catch{
                                }
                            }){
                                Text("サインアウト")
                                    .bold()
                                    .padding()
                                    .frame(width: 200, height: 40)
                                    .foregroundColor(Color.gray)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray, lineWidth: 1)
                                    )
                            }
                            Spacer()
                        }
                        .listRowBackground(Color.white.opacity(0))
                    }
                }
            }
        }
        .alert("ユーザーネーム", isPresented: $editName) {
            let initial_name = myName
            TextField("名前を入力", text: $myName)
            Button("名前を変更"){
                let changeRequest = user?.createProfileChangeRequest()
                changeRequest?.displayName = myName
                changeRequest?.commitChanges {_ in }
            }
            Button("キャンセル", role: .cancel){
                myName = initial_name
            }
        } message: {
            Text("ユーザーネームの変更しますか？")
        }
        .onChange(of: editName, { oldValue, newValue in
            if newValue == true {
                appData.tabZIndex = 2.0
            } else {
                appData.tabZIndex = 0.0
            }
        })
    }
}

struct NetworkImage: View {
    let url: URL?
    var body: some View {
        if let url = url {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
}




struct AppSettings: View {
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var appData: AppData
    @State var showClock = false
    var circleSize = UIScreen.main.bounds.width * 0.65
    @State var hour = 4
    @State var minute = 56
    @State var second = 7
    var body: some View {
        List {
            Section(header: Text("時計の表示")) {
                HStack {
                    Text("デジタル時計を表示")
                    Spacer()
                    Toggle("", isOn: $userSettings.digital_clock)
                        .labelsHidden()
                        .toggleStyle(.switch)
                }
                HStack {
                    Text("アナログ時計を表示")
                    Spacer()
                    Toggle("", isOn: $userSettings.analog_clock)
                        .labelsHidden()
                        .toggleStyle(.switch)
                }
                Button(action: {showClock = true}) {
                    Text("イメージ")
                }
                .sheet(isPresented: $showClock) {
                    VStack {
                        if userSettings.digital_clock {
                            HStack(alignment: .top){
                                Text("1")
                                    .foregroundColor(.primary)
                                    .font(Font(UIFont.monospacedDigitSystemFont(ofSize: 50, weight: .bold)))
                                    .frame(width: 100, alignment: .trailing)
                                Text("m")
                                    .foregroundColor(.primary)
                                    .frame(width: 20)
                                Text("23")
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
                                    .foregroundColor(.primary)
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
                        HStack {
                            Button(action: {showClock = false}){
                                ZStack {
                                    Circle()
                                        .stroke(Color(UIColor.secondarySystemBackground), lineWidth: 4)
                                        .frame(width: 78, height: 78)
                                    Text("停止")
                                        .foregroundColor(.primary)
                                        .frame(width: 70, height: 70)
                                        .background(
                                            Circle()
                                                .foregroundColor(Color(UIColor.secondarySystemBackground))
                                        )
                                }
                            }
                            .padding()
                            Button(action: {}){
                                ZStack {
                                    Circle()
                                        .stroke(Color(UIColor.secondarySystemBackground), lineWidth: 4)
                                        .frame(width: 78, height: 78)
                                    Text("一時停止")
                                        .foregroundColor(.primary)
                                        .frame(width: 70, height: 70)
                                        .background(
                                            Circle()
                                                .foregroundColor(Color(UIColor.secondarySystemBackground))
                                        )
                                }
                            }
                            .padding()
                            Button(action: {}){
                                ZStack {
                                    Text("その他")
                                        .offset(x: 0, y: -60)
                                        .foregroundColor(.primary)
                                        .frame(width: 78)
                                    Circle()
                                        .stroke(Color(UIColor.secondarySystemBackground), lineWidth: 4)
                                        .frame(width: 78, height: 78)
                                    Text("記録")
                                        .foregroundColor(.primary)
                                        .frame(width: 70, height: 70)
                                        .background(
                                            Circle()
                                                .foregroundColor(Color(UIColor.secondarySystemBackground))
                                        )
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
        }
        .onAppear {
            appData.tabZIndex = 2.0
        }
        .onWillDisappear {
            appData.tabZIndex = 0.0
        }
    }
}


struct Sound: Identifiable {
    let id: Int
    let name: String
}
struct NoticeSettings: View {
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var appData: AppData
    let sounds: [Sound] = [
        Sound(id: 1002, name: "ベル"),
        Sound(id: 1005, name: "ビープ"),
        Sound(id: 1003, name: "ガラス"),
        Sound(id: 1008, name: "チャイム"),
        Sound(id: 1009, name: "ピン"),
        Sound(id: 1310, name: "ホーン"),
        Sound(id: 1013, name: "ティンク"),
        Sound(id: 1014, name: "ポップ"),
        Sound(id: 1320, name: "シャーウッドの森"),
        Sound(id: 1335, name: "オーロラ"),
        Sound(id: 1330, name: "エレクトロニック"),
        Sound(id: 1321, name: "優雅"),
        Sound(id: 1334, name: "シークエンス")
    ]
    @State var authorized: Bool = false
    @State var showAlert: Bool = false
    @State var navigate: Bool = false

    var body: some View {
        List {
            Section(header: Text("iPhone 通知")) {
                HStack {
                    Button(action: {authorized = true}) {
                        Text("通知設定\(authorized ? "はオン" : "がオフ")になっています")
                    }
                    Spacer()
                }
            }
            Section(footer: Text("オンにするとバックグラウンドでテストができますが、リスニングや記録ができなくなります。")) {
                HStack {
                    Text("テスト日までの通知")
                    Spacer()
                    Toggle("", isOn: $userSettings.test)
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .disabled(!authorized)
                }
                HStack {
                    Text("テストの開始と終了だけ通知")
                    Spacer()
                    Toggle("", isOn: $userSettings.test2)
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .disabled(!authorized)
                }
            }
            Section(header: Text("アプリ内通知")) {
                HStack {
                    Text("テスト終了時の通知")
                    Spacer()
                    Toggle("", isOn: $userSettings.notice)
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .disabled(userSettings.test2)
                }
                HStack {
                    Button(action: {
                        if userSettings.notice {
                            navigate = true
                        }
                        
                    }) {
                        HStack {
                            Text("")
                            Spacer()
                            Text("\(sounds.first(where: {$0.id == userSettings.notice_sound})!.name)")
                                .foregroundStyle(Color(UIColor.placeholderText))
                            Image(systemName: "chevron.forward")
                                .foregroundStyle(Color(UIColor.placeholderText))
                                .font(.system(size: 14))
                        }
                    }
                }
                HStack {
                    Text("セクションごとに通知")
                    Spacer()
                    Toggle("", isOn: $userSettings.section_notice)
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .disabled(userSettings.test2)
                }
            }
        }
        .navigationDestination(isPresented: $navigate, destination: {
            List {
                ForEach(sounds){ sound in
                    Button(action:{
                        userSettings.notice_sound = sound.id
                        var timerSound: Int = 0
                        if timerSound < 2 {
                            Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ timer in
                                timerSound += 1
                            }
                            AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(sound.id), nil)
                        }
                    }){
                        HStack {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                                .bold()
                                .opacity(sound.id == userSettings.notice_sound ? 1.0 : 0.0)
                            Text("\(sound.name)")
                                .foregroundColor(.primary)
                            Spacer()
                        }
                    }
                    .disabled(userSettings.test2)
                }
            }
        })
        .onChange(of: authorized) { _, newValue in
            if newValue {
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    switch settings.authorizationStatus {
                    case .authorized, .provisional, .ephemeral:
                        break
                    case .denied:
                        showAlert = true
                    case .notDetermined:
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {_,_ in }
                    @unknown default:
                        showAlert = true
                    }
                }
            }
        }
        .alert("通知", isPresented: $showAlert) {
            Button("設定を開く"){
                requestNotificationAuthorization()
            }
            Button("キャンセル", role: .cancel){
                authorized = false
            }
        } message: {
            Text("通知を許可しますか？")
        }
        .onAppear {
            appData.tabZIndex = 2.0
            checkNotificationAuthorization { isAuthorized in
                authorized = isAuthorized
            }
        }
        .onWillDisappear {
            if !navigate {
                appData.tabZIndex = 0.0
            }
        }
    }
}



struct TermsView: View {
    @EnvironmentObject var appData: AppData
    let index: Int
    let texts: [String] = [privacyPolicyText, termsOfServiceText]
    let texts2: [String] = ["プライバシーポリシー", "利用規約"]
    let dismissBool: Bool
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(lines, id: \.self) { line in
                        if containsNumber(line: line) {
                            Text(line)
                                .font(.headline)
                                .foregroundColor(.primary)
                        } else {
                            Text(line)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(texts2[index])
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if dismissBool {
                    ToolbarItem(placement: .topBarTrailing){
                        Button(action: {dismiss()}){
                            Text("閉じる")
                                .bold()
                        }
                    }
                }
            }
        }
        .onAppear{
            appData.tabZIndex = 2.0
        }
        .onWillDisappear{
            appData.tabZIndex = 0.0
        }
    }
    var lines: [String] {
        texts[index].components(separatedBy: "\n")
    }
    func containsNumber(line: String) -> Bool {
        let pattern = "\\d+\\."
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let range = NSRange(line.startIndex..<line.endIndex, in: line)
            return regex.firstMatch(in: line, options: [], range: range) != nil
        }
        return false
    }
}




let privacyPolicyText = """
1. はじめに

[アプリ名]（以下「当アプリ」といいます）は、Googleが提供するFirebaseを利用してユーザー認証を行います。このプライバシーポリシーでは、ユーザーの個人情報の収集、使用、保護、共有について説明します。


2. 収集する情報

当アプリは、次の情報を収集する場合があります：
• Firebase Authentication
メールアドレス、電話番号、GoogleアカウントやApple IDなどの認証情報。

• ログ情報
Firebaseの統計ツールを使用して、アプリの使用状況やエラー情報を収集します。

• デバイス情報
デバイスのモデル、オペレーティングシステム、言語設定など。


3. 情報の利用目的

収集した情報は以下の目的で使用します：
• アカウント認証とユーザー管理。
• サービスの提供、維持、改善。
• セキュリティの向上と不正利用の防止。
• 必要に応じたユーザーへの通知。


4. 情報の共有

当アプリは、以下の場合を除き、ユーザー情報を第三者に共有しません：
• Firebaseを含む信頼できるサービスプロバイダーとの連携。
• 法令に基づく場合や法的要求への対応。
• アプリの合併や事業譲渡などが発生した場合。


5. 情報の保護

当アプリは、ユーザー情報を保護するために適切なセキュリティ対策を講じます。ただし、完全な安全性を保証するものではありません。


6. ユーザーの権利

ユーザーは、自身の情報について以下の権利を有します：
• 情報へのアクセス、修正、削除の要求。
• プライバシーポリシーに同意しない場合のサービス利用停止。


7. お問い合わせ

プライバシーポリシーについてご質問がある場合は、以下の連絡先までお問い合わせください：
[連絡先情報：メールアドレスや電話番号]
"""



let termsOfServiceText = """

1. はじめに

この利用規約（以下「本規約」といいます）は、[アプリ名]（以下「当アプリ」といいます）の使用条件を定めたものです。本規約に同意いただけない場合、当アプリをご利用いただくことはできません。


2. サービス内容

当アプリは、Firebaseを使用した認証機能を提供します。当アプリを使用する際には、適切なログイン情報を提供していただく必要があります。


3. 禁止事項

ユーザーは、当アプリの利用において以下の行為を行ってはなりません：
• 他人のアカウントを不正に使用する行為。
• アプリのソースコードを改変またはリバースエンジニアリングする行為。
• 法令または公序良俗に反する行為。


4. 免責事項

当アプリは、サービスの中断、エラー、データ損失に対する一切の責任を負いません。


5. 知的財産権

当アプリに含まれるすべてのコンテンツおよび機能は、[アプリ開発者]またはそのライセンサーが所有しています。無断での使用は禁止されています。


6. 本規約の変更

当アプリは、本規約を随時変更することができます。本規約の変更後に当アプリを利用することで、変更内容に同意したものとみなされます。


7. お問い合わせ

本規約に関するお問い合わせは、以下までご連絡ください：
[連絡先情報：メールアドレスや電話番号]
"""
