import SwiftUI

enum DN {
    static let accent = Color(hex: "#4C8DFF")
    static let ok = Color(hex: "#34D399")
    static let warn = Color(hex: "#FFB547")
    static let bad = Color(hex: "#FF5A5F")
    static let card = Color(uiColor: .secondarySystemGroupedBackground)
    static let spring = Animation.spring(response: 0.42, dampingFraction: 0.78)
    static let snappy = Animation.snappy(duration: 0.28)
    static let radius: CGFloat = 22
}

/// Solid content card. Glass is reserved for the navigation/control layer, never content.
struct ContentCard<Content: View>: View {
    var padding: CGFloat = 16
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 12) { content }
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DN.card, in: .rect(cornerRadius: DN.radius, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: DN.radius, style: .continuous).strokeBorder(.white.opacity(0.06)))
    }
}

struct SectionTitle: View {
    let text: String
    var body: some View { Text(text).font(.title3.weight(.bold)).padding(.top, 18).frame(maxWidth: .infinity, alignment: .leading) }
}

/// Materialize-in transition: blur + rise + fade, respecting Reduce Motion.
struct Materialize: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown = false
    var delay: Double = 0
    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .blur(radius: shown || reduceMotion ? 0 : 8)
            .offset(y: shown || reduceMotion ? 0 : 12)
            .onAppear { withAnimation(reduceMotion ? .none : DN.spring.delay(delay)) { shown = true } }
    }
}
extension View { func materialize(_ delay: Double = 0) -> some View { modifier(Materialize(delay: delay)) } }

/// Springy press response for custom controls.
struct PressScale: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(DN.spring, value: configuration.isPressed)
    }
}

enum Haptics {
    static func tap() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
}
