import SwiftUI
import UIKit
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseOAuthUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import FirebaseEmailAuthUI
import FirebaseFirestore

import AuthenticationServices
import CryptoKit
import Security

import WebKit



struct FirstView: View {
    @EnvironmentObject var authState: FirebaseAuthStateObserver
    @EnvironmentObject var userData: UserData
    @State var done2: Bool = false
    @State var count_list: [Double] = [0, 0, 0, 0, 20, 40, 60, 80, 105, 125, 155, 195, 210, 190, 180, 170, 180, 180, 180, 180]
    @State var count = 0
    let random = Int.random(in: 0...1)
    var body: some View {
        if authState.isSignin {
            ZStack {
                ContentView()
                    .overlay {
                        if !(userData.done && done2) {
                            VStack {
                                Image("AppIcon2")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 300)
                                    .rotationEffect(.degrees(180 + count_list[count % count_list.count]))
                                    .animation(.linear, value: count)
                            }
                            .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                            .ignoresSafeArea()
                            .background(Color(UIColor.systemBackground))
                        }
                    }
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.8), value: userData.done && done2)
            }
            .onAppear() {
                Timer.scheduledTimer(withTimeInterval: 0.07, repeats: true){ timer in
                    count += 1
                    if count == count_list.count - 1 {
                        done2 = true
                        timer.invalidate()
                    }
                }
            }
        } else {
            Welcome()
                .onAppear() {
                    done2 = false
                }
        }
    }
}




struct Welcome: View {
    let authUI = FUIAuth.defaultAuthUI()
    @State var tabIndex: Int = 1
    @State var count = 0
    @State var showFirebaseAuth: Bool = false
    @State var appearCount: Bool = true
    @State var moveToTab3: Bool = false
    var body: some View {
        VStack {
            TabView(selection: $tabIndex) {
                Welcome1(appearCount: $appearCount, moveToTab3: $moveToTab3)
                    .tag(1)
                Welcome2()
                    .tag(2)
                Welcome2()
                    .tag(3)
                Welcome3()
                    .tag(4)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .animation(.easeInOut(duration: 0.8), value: tabIndex)
            Spacer()
            VStack {
                if tabIndex != 4 {
                    Button(action: {
                        appearCount = false
                        tabIndex = 4
                    }) {
                        Text("新規登録・ログイン")
                            .font(.system(size :20).bold())
                            .frame(width: UIScreen.main.bounds.size.width - 60, height: 40)
                            .foregroundColor(Color(UIColor.systemBackground))
                            .background(Color.accentColor.shadow(.drop(color: .black.opacity(0.3), radius: 10)))
                            .cornerRadius(10)
                    }
                    .disabled(moveToTab3 && !appearCount)
                } else {
                    Text(" ")
                        .font(.system(size :20).bold())
                        .opacity(0)
                        .frame(width: UIScreen.main.bounds.size.width - 60, height: 40)
                        .cornerRadius(10)
                }
            }
            .padding()
            .padding(.bottom, 50)
        }
    }
}

struct Welcome1: View {
    @State var count_list: [Double] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 20, 20, 20, 20, 25, 20, 30, 40, 15, -20, -10, -10, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    @State var degree: Double = 180
    @State var count = 0
    @Binding var appearCount: Bool
    @Binding var moveToTab3: Bool
    var body: some View {
        VStack {
            Image("AppIcon2")
                .resizable()
                .scaledToFit()
                .frame(width: 250)
                .rotationEffect(.degrees(degree))
                .animation(.linear, value: count)
                .onTapGesture {
                    if Int(degree) % 180 == 0 {
                        moveToTab3 = true
                        count = 10
                        Timer.scheduledTimer(withTimeInterval: 0.07, repeats: true){ timer in
                            count += 1
                            degree += count_list[count % count_list.count]
                            if count == count_list.count - 1 {
                                timer.invalidate()
                                moveToTab3 = false
                                count = 0
                            }
                        }
                    }
                }
                .padding(.bottom, 50)
            Text("You passed!")
                .font(.system(size: 25).bold())
                .padding()
            Text("その言葉が聞ける日への一助となるアプリです！")
                .font(.system(size: 20))
                .frame(width: UIScreen.main.bounds.width - 40, alignment: .leading)
                .padding(.leading, 20)
                .padding(.vertical, 10)
            Text("過去問を最大限活用して、合格への一歩を踏み出しましょう！")
                .font(.system(size: 20))
                .frame(width: UIScreen.main.bounds.width - 40, alignment: .leading)
                .padding(.leading, 20)
                .padding(.vertical, 10)
        }
        .onAppear {
            if appearCount {
                Timer.scheduledTimer(withTimeInterval: 0.07, repeats: true){ timer in
                    if appearCount {
                        count += 1
                        degree += count_list[count % count_list.count]
                        if count == count_list.count - 1 {
                            timer.invalidate()
                            appearCount = false
                            count = 0
                        }
                    } else {
                        timer.invalidate()
                        count = 0
                        degree = 0
                    }
                }
            }
        }
    }
}


struct Welcome2: View {
    @State var showFullScreen: Bool = false
    var body: some View {
        Text("123")
    }
}



struct Welcome3: View {
    @StateObject private var appleSignIn = AppleSignIn()
    @State var EmailSingIn: Bool = false
    @State var showPrivacyPolicy: Bool = false
    @State var showTermsOfService: Bool = false
    @State var isChecked: Bool = false
    @State var isChecked2: Bool = false
    var body: some View {
        VStack {
            VStack {
                Text("新規登録・ログインで使用できるもの")
                    .font(.system(size: 20))
                    .frame(width: UIScreen.main.bounds.width - 40, alignment: .leading)
                    .padding(.leading, 20)
                    .padding(.vertical, 10)
                Text("・Googleアカウント\n・Apple ID\n・メールアドレス")
                    .font(.system(size: 20).bold())
                    .frame(width: UIScreen.main.bounds.width - 40, alignment: .leading)
                    .lineSpacing(5)
                    .padding(.leading, 50)
                    .padding(.vertical, 10)
                    .padding(.bottom, 30)
                Text("プライバシーポリシーと利用規約への同意をお願いします")
                    .font(.system(size: 20))
                    .frame(width: UIScreen.main.bounds.width - 40, alignment: .leading)
                    .padding(.leading, 20)
                    .padding(.vertical, 10)
                HStack {
                    Button(action: {isChecked.toggle()}) {
                        Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                            .foregroundColor(isChecked ? .accentColor : .primary)
                            .font(.system(size: 20))
                    }
                    .toggleStyle(.button)
                    .padding(.trailing, 15)
                    Text("プライバシーポリシー")
                        .foregroundColor(.blue)
                        .onTapGesture {
                            showPrivacyPolicy = true
                        }
                    Text("に同意する")
                }
                .frame(width: UIScreen.main.bounds.width - 40, alignment: .leading)
                .padding(.leading, 50)
                .padding(.vertical, 5)
                HStack {
                    Button(action: {isChecked2.toggle()}) {
                        Image(systemName: isChecked2 ? "checkmark.square.fill" : "square")
                            .foregroundColor(isChecked2 ? .accentColor : .primary)
                            .font(.system(size: 20))
                    }
                    .toggleStyle(.button)
                    .padding(.trailing, 15)
                    Text("利用規約")
                        .foregroundColor(.blue)
                        .onTapGesture {
                            showTermsOfService = true
                        }
                    Text("に同意する")
                }
                .frame(width: UIScreen.main.bounds.width - 40, alignment: .leading)
                .padding(.leading, 50)
                .padding(.vertical, 5)
            }
            .padding(.bottom, 80)
            HStack {
                Button(action: {
                    googleSignIn()
                }) {
                    AsyncImage(url: URL(string: "https://logo.clearbit.com/google.com")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 40, height: 40)
                    .cornerRadius(25)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .shadow(color: .primary.opacity(0.3), radius: 25, x: 10, y: 10)
                            .frame(width: 60, height: 60)
                    )
                    .overlay(
                        Circle()
                            .fill(Color.gray.opacity((isChecked && isChecked2) ? 0.0 : 0.6))
                            .frame(width: 60, height: 60)
                    )
                }
                .disabled(!(isChecked && isChecked2))
                .padding(.horizontal, 30)
                Button(action: {
                    appleSignIn.handleSignInWithApple()
                }) {
                    AsyncImage(url: URL(string: "https://logo.clearbit.com/apple.com")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 40, height: 40)
                    .cornerRadius(25)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .shadow(color: .primary.opacity(0.3), radius: 25, x: 5, y: 5)
                            .frame(width: 60, height: 60)
                    )
                    .overlay(
                        Circle()
                            .fill(Color.gray.opacity((isChecked && isChecked2) ? 0.0 : 0.6))
                            .frame(width: 60, height: 60)
                    )
                }
                .disabled(!(isChecked && isChecked2))
                .padding(.horizontal, 30)
                Button(action: {
                    EmailSingIn = true
                }) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.red)
                        .frame(width: 40, height: 40)
                        .cornerRadius(25)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .shadow(color: .primary.opacity(0.3), radius: 25, x: 5, y: 5)
                                .frame(width: 60, height: 60)
                        )
                        .overlay(
                            Circle()
                                .fill(Color.gray.opacity((isChecked && isChecked2) ? 0.0 : 0.6))
                                .frame(width: 60, height: 60)
                        )
                }
                .disabled(!(isChecked && isChecked2))
                .padding(.horizontal, 30)
            }
        }
        .sheet(isPresented: $EmailSingIn, onDismiss: {}) {
            NavigationStack {
                EmailSignInView()
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading){
                            Button(action: {EmailSingIn = false}){
                                Text("キャンセル")
                                    .bold()
                            }
                        }
                    }
            }
        }
        .sheet(isPresented: $showPrivacyPolicy, onDismiss: {}) {
            TermsView(index: 0, dismissBool: true)
        }
        .sheet(isPresented: $showTermsOfService, onDismiss: {}) {
            TermsView(index: 1, dismissBool: true)
        }
    }
    private func googleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let rootViewController = windowScene?.windows.first!.rootViewController!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: rootViewController!) { user, error in
            if let error = error {
                print("GIDSignInError: \(error.localizedDescription)")
                return
            }
            guard let authentication = user?.authentication,
                  let idToken = authentication.idToken else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print("SignInError: \(error.localizedDescription)")
                    return
                }
            }
        }
    }
}

struct EmailSignInView: View {
    @State private var mailAddress = ""
    @State private var password = ""
    @State private var passwordConfirm = ""
    @State private var isShowAlert = false
    @State private var errorMessage = ""
    var body: some View {
        VStack {
            VStack {
                Text("メールで新規登録・ログイン")
                    .font(.system(size: 25).bold())
                    .padding()
                Text("メールアドレスとパスワードを入力してください。\nパスワードは、小文字英字・数字を含む６〜20字で設定してください。")
                    .font(.system(size: 20))
                    .frame(width: UIScreen.main.bounds.width - 40, alignment: .leading)
                    .padding(.leading, 20)
                    .padding(.vertical, 10)
            }
            VStack {
                HStack {
                    Text("メールアドレス")
                    Spacer()
                }
                TextField("メールアドレス", text: $mailAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.emailAddress)
            }
            .padding()
            VStack {
                HStack {
                    Text("パスワード")
                    Spacer()
                }
                SecureField("英数字・６〜20字", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.password)
                    .onSubmit() {
                        EmailSignIn()
                    }
            }
            .padding()
            Button(action: {EmailSignIn()}) {
                Text("新規登録・ログイン")
                    .font(.system(size :20).bold())
                    .foregroundColor(Color(UIColor.systemBackground))
                    .background(
                        Rectangle()
                            .fill(Color.accentColor.shadow(.drop(color: .black.opacity(0.3), radius: 10)))
                            .frame(width: UIScreen.main.bounds.size.width - 60, height: 40)
                            .cornerRadius(10)
                    )
            }
            .padding(.vertical, 50)
        }
        .padding()
        .alert("エラー", isPresented: $isShowAlert) {
            Button("OK", role: .cancel) {
                isShowAlert = false
            }
        } message: {
            Text(errorMessage)
        }
    }
    private func EmailSignIn() {
        Auth.auth().createUser(withEmail: self.mailAddress, password: self.password) { authResult, error in
            if let error = error as NSError?, let errorCode = AuthErrorCode.Code(rawValue: error.code) {
                switch errorCode {
                case .invalidEmail:
                    self.errorMessage = "メールアドレスの形式が正しくありません"
                    self.isShowAlert = true
                case .emailAlreadyInUse:
                    self.EmailSignIn2()
                case .weakPassword:
                    self.errorMessage = "パスワードは６〜20字で入力してください"
                    self.isShowAlert = true
                default:
                    self.errorMessage = error.domain
                    self.isShowAlert = true
                }
            }
            
            if let user = authResult?.user {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = self.mailAddress
                changeRequest.commitChanges {_ in }
            }
        }
    }
    private func EmailSignIn2() {
        Auth.auth().signIn(withEmail: self.mailAddress, password: self.password) { authResult, error in
            if let error = error as NSError?, let errorCode = AuthErrorCode.Code(rawValue: error.code) {
                switch errorCode {
                case .invalidEmail:
                    self.errorMessage = "メールアドレスの形式が正しくありません"
                case .userNotFound, .wrongPassword:
                    self.errorMessage = "パスワードが間違っています"
                case .userDisabled:
                    self.errorMessage = "このユーザーアカウントは無効化されています"
                default:
                    self.errorMessage = error.domain
                    print(errorCode)
                }
                self.isShowAlert = true
            }
        }
    }
}




class AppleSignIn: NSObject, ObservableObject {
    @Published var isSignedIn = false
    @Published var errorMessage: String?
    private var currentNonce: String?
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    // SHA256でハッシュ化
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    // Apple Sign In の処理
    func handleSignInWithApple() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    private func authenticateWithFirebase(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { [weak self] (result, error) in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            self?.isSignedIn = true
            
            // ユーザー情報の保存やその他の処理をここに追加
        }
    }
}

extension AppleSignIn: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                    idToken: idTokenString,
                                                    rawNonce: nonce)
            authenticateWithFirebase(credential: credential)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.errorMessage = error.localizedDescription
    }
}

extension AppleSignIn: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else {
            fatalError("No window found")
        }
        return window
    }
}






class FirebaseAuthStateObserver: ObservableObject {
    @Published var isSignin: Bool = false
    private var listener: AuthStateDidChangeListenerHandle!
    init() {
        listener = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let _ = user {
                self.isSignin = true
            } else {
                self.isSignin = false
            }
        }
    }
    deinit {
        Auth.auth().removeStateDidChangeListener(listener)
    }
}
