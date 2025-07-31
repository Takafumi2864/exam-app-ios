import SwiftUI
import UIKit
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseOAuthUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import FirebaseEmailAuthUI

@main
struct ExamApp: SwiftUI.App {
    init() {
        let center = UNUserNotificationCenter.current()
        let delegate = NotificationDelegate.shared
        center.delegate = delegate
    }
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            FirstView()
                .transition(.opacity)
                .environmentObject(UserSettings())
                .environmentObject(AppData())
                .environmentObject(UserData())
                .environmentObject(FirebaseAuthStateObserver())
                .onAppear(){
                    if Auth.auth().currentUser != nil{
                        FirebaseAuthStateObserver().isSignin = true
                    }
                }
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("許可されました！")
            }else{
                print("拒否されました...")
            }
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        UserSettings().setData()
        //UserData().setData()
        print("success1")
    }
    func applicationWillTerminate(_ application: UIApplication) {
        UserSettings().setData()
        //UserData().setData()
        print("success2 ")
    }
}
