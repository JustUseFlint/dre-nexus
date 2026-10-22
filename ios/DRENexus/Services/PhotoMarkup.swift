import PencilKit
import SwiftUI

/// PencilKit markup over a captured evidence photo. The original is retained; the annotated render is stored separately.
struct PhotoMarkupView: View {
    let image: UIImage
    var onSave: (Data) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var canvas = PKCanvasView()
    var body: some View {
        NavigationStack {
            GeometryReader { g in
                let size = fitted(image.size, in: g.size)
                ZStack {
                    Image(uiImage: image).resizable().scaledToFit()
                    CanvasRep(canvas: canvas)
                }
                .frame(width: size.width, height: size.height)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(.black)
            .navigationTitle("Markup").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel", role: .cancel) { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark") { onSave(render()); dismiss() }.buttonStyle(.glassProminent)
                }
            }
        }
    }
    private func fitted(_ s: CGSize, in b: CGSize) -> CGSize { let r = min(b.width / s.width, b.height / s.height); return CGSize(width: s.width * r, height: s.height * r) }
    private func render() -> Data {
        let r = UIGraphicsImageRenderer(size: canvas.bounds.size)
        return r.jpegData(withCompressionQuality: 0.85) { _ in
            image.draw(in: CGRect(origin: .zero, size: canvas.bounds.size))
            canvas.drawing.image(from: canvas.bounds, scale: 1).draw(in: canvas.bounds)
        }
    }
    struct CanvasRep: UIViewRepresentable {
        let canvas: PKCanvasView
        func makeUIView(context: Context) -> PKCanvasView {
            canvas.backgroundColor = .clear; canvas.isOpaque = false; canvas.drawingPolicy = .anyInput
            canvas.tool = PKInkingTool(.marker, color: .systemRed, width: 8)
            let picker = PKToolPicker(); picker.setVisible(true, forFirstResponder: canvas); picker.addObserver(canvas); canvas.becomeFirstResponder()
            context.coordinator.picker = picker
            return canvas
        }
        func updateUIView(_ v: PKCanvasView, context: Context) {}
        func makeCoordinator() -> Coord { Coord() }
        final class Coord { var picker: PKToolPicker? }
    }
}

/// Simple stopwatch bound to a TimeInterval, with an optional target (e.g. 30 s for OLS).
struct StopwatchCard: View {
    let title: String
    var target: Double? = nil
    @Binding var elapsed: TimeInterval
    var onStop: ((TimeInterval) -> Void)? = nil
    @State private var startedAt: Date?
    var body: some View {
        ContentCard {
            Text(title.uppercased()).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            TimelineView(.periodic(from: .now, by: 0.1)) { _ in
                let t = elapsed + (startedAt.map { Date().timeIntervalSince($0) } ?? 0)
                Text(t, format: .number.precision(.fractionLength(1)))
                    .font(.system(size: 48, weight: .bold, design: .rounded)).monospacedDigit()
                    .foregroundStyle(target.map { t >= $0 } == true ? DN.ok : .primary)
                    .frame(maxWidth: .infinity)
            }
            GlassEffectContainer(spacing: 12) {
                HStack(spacing: 12) {
                    Button(startedAt == nil ? "Start" : "Stop", systemImage: startedAt == nil ? "play.fill" : "pause.fill") {
                        if let s = startedAt { elapsed += Date().timeIntervalSince(s); startedAt = nil; onStop?(elapsed) } else { startedAt = .now }
                        Haptics.tap()
                    }
                    .buttonStyle(.glassProminent).controlSize(.large)
                    Button("Reset", systemImage: "arrow.counterclockwise") { startedAt = nil; elapsed = 0 }
                        .buttonStyle(.glass).controlSize(.large)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
