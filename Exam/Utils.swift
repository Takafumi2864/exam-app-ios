import SwiftUI
import UIKit



struct ViewWillAppearHandler: UIViewControllerRepresentable {
    func makeCoordinator() -> ViewWillAppearHandler.Coordinator {
        Coordinator(onWillAppear: onWillAppear)
    }

    let onWillAppear: () -> Void

    func makeUIViewController(context: UIViewControllerRepresentableContext<ViewWillAppearHandler>) -> UIViewController {
        context.coordinator
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<ViewWillAppearHandler>) {
    }

    typealias UIViewControllerType = UIViewController

    class Coordinator: UIViewController {
        let onWillAppear: () -> Void

        init(onWillAppear: @escaping () -> Void) {
            self.onWillAppear = onWillAppear
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            onWillAppear()
        }
    }
}
struct ViewWillAppearModifier: ViewModifier {
    let callback: () -> Void

    func body(content: Content) -> some View {
        content
            .background(ViewWillAppearHandler(onWillAppear: callback))
    }
}
extension View {
    func onWillAppear(_ perform: @escaping (() -> Void)) -> some View {
        self.modifier(ViewWillAppearModifier(callback: perform))
    }
}

struct ViewWillDisappearHandler: UIViewControllerRepresentable {
    func makeCoordinator() -> ViewWillDisappearHandler.Coordinator {
        Coordinator(onWillDisappear: onWillDisappear)
    }

    let onWillDisappear: () -> Void

    func makeUIViewController(context: UIViewControllerRepresentableContext<ViewWillDisappearHandler>) -> UIViewController {
        context.coordinator
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<ViewWillDisappearHandler>) {
    }

    typealias UIViewControllerType = UIViewController

    class Coordinator: UIViewController {
        let onWillDisappear: () -> Void

        init(onWillDisappear: @escaping () -> Void) {
            self.onWillDisappear = onWillDisappear
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            onWillDisappear()
        }
    }
}
struct ViewWillDisappearModifier: ViewModifier {
    let callback: () -> Void

    func body(content: Content) -> some View {
        content
            .background(ViewWillDisappearHandler(onWillDisappear: callback))
    }
}
extension View {
    func onWillDisappear(_ perform: @escaping (() -> Void)) -> some View {
        self.modifier(ViewWillDisappearModifier(callback: perform))
    }
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




func dfS_D(date: String) -> Date{
    let df = DateFormatter()
    df.locale = Locale(identifier: "ja_JP")
    df.dateStyle = .medium
    df.timeStyle = .short
    return df.date(from: date) ?? Date()
}
