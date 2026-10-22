import SwiftUI

/// Large, one-handed clue toggle. The switch is the control; the row is solid content.
struct ClueToggle: View {
    let title: String
    var subtitle: String? = nil
    @Binding var isOn: Bool
    var body: some View {
        Toggle(isOn: $isOn.animation(DN.spring)) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.body.weight(.medium))
                if let subtitle { Text(subtitle).font(.footnote).foregroundStyle(.secondary) }
            }
        }
        .tint(DN.bad)
        .frame(minHeight: 52)
        .sensoryFeedback(.selection, trigger: isOn)
    }
}

struct ChipSet: View {
    let options: [String]
    @Binding var selection: Set<String>
    var tint: Color = DN.accent
    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(options, id: \.self) { o in
                let on = selection.contains(o)
                Button {
                    withAnimation(DN.spring) { if on { selection.remove(o) } else { selection.insert(o) } }
                } label: {
                    Text(o).font(.subheadline.weight(.medium))
                        .padding(.horizontal, 14).frame(minHeight: 40)
                        .background(on ? tint.opacity(0.2) : Color(uiColor: .tertiarySystemFill), in: .capsule)
                        .overlay(Capsule().strokeBorder(on ? tint.opacity(0.7) : .clear))
                }
                .buttonStyle(PressScale())
                .sensoryFeedback(.selection, trigger: on)
            }
        }
    }
}

struct Stepper9: View {
    let label: String
    @Binding var selection: Set<Int>
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.footnote).foregroundStyle(.secondary)
            HStack(spacing: 6) {
                ForEach(1...9, id: \.self) { i in
                    let on = selection.contains(i)
                    Button { withAnimation(DN.spring) { if on { selection.remove(i) } else { selection.insert(i) } } } label: {
                        Text("\(i)").font(.headline.monospacedDigit()).frame(maxWidth: .infinity, minHeight: 46)
                            .background(on ? DN.bad.opacity(0.25) : Color(uiColor: .tertiarySystemFill), in: .rect(cornerRadius: 10))
                    }.buttonStyle(PressScale())
                }
            }
        }
    }
}

struct ClueCounter: View {
    let count: Int
    let total: Int
    let threshold: Int
    var body: some View {
        HStack {
            Text("\(count)").font(.system(size: 54, weight: .bold, design: .rounded)).monospacedDigit()
                .contentTransition(.numericText(value: Double(count)))
            Text("of \(total) clues").foregroundStyle(.secondary)
            Spacer()
            Label(count >= threshold ? "\(threshold)+ clues" : "Below \(threshold)", systemImage: count >= threshold ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 12).padding(.vertical, 8)
                .foregroundStyle(count >= threshold ? DN.bad : DN.ok)
                .background((count >= threshold ? DN.bad : DN.ok).opacity(0.14), in: .capsule)
        }
        .animation(DN.spring, value: count)
    }
}

/// Floating glass control showing the running clue count while the content scrolls beneath.
struct FloatingCounter: View {
    let count: Int, total: Int, threshold: Int
    var body: some View {
        ClueCounter(count: count, total: total, threshold: threshold)
            .padding(.horizontal, 18).padding(.vertical, 6)
            .glassEffect(.regular, in: .rect(cornerRadius: 26))
            .padding(.horizontal)
    }
}

struct PresenceSegment: View {
    let title: String
    @Binding var value: Presence?
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.footnote).foregroundStyle(.secondary)
            Picker(title, selection: $value) {
                Text("–").tag(Presence?.none)
                Text("Absent").tag(Presence?.some(.absent))
                Text("Present").tag(Presence?.some(.present))
            }.pickerStyle(.segmented).controlSize(.large)
        }
    }
}

struct LabeledField: View {
    let label: String
    @Binding var text: String
    var prompt = ""
    var dictation = false
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack { Text(label).font(.footnote).foregroundStyle(.secondary); Spacer(); if dictation { DictationButton(text: $text) } }
            TextField(prompt, text: $text, axis: .vertical)
                .padding(14).frame(minHeight: 50)
                .background(Color(uiColor: .tertiarySystemFill), in: .rect(cornerRadius: 14))
        }
    }
}

struct NumberField: View {
    let label: String
    @Binding var value: Double?
    var unit = ""
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.footnote).foregroundStyle(.secondary)
            HStack {
                TextField("–", value: $value, format: .number).keyboardType(.decimalPad).font(.title3.monospacedDigit())
                if !unit.isEmpty { Text(unit).foregroundStyle(.secondary) }
            }
            .padding(14).frame(minHeight: 50)
            .background(Color(uiColor: .tertiarySystemFill), in: .rect(cornerRadius: 14))
        }
    }
}

struct IntField: View {
    let label: String
    @Binding var value: Int?
    var unit = ""
    var body: some View {
        NumberField(label: label, value: Binding(get: { value.map(Double.init) }, set: { value = $0.map { Int($0) } }), unit: unit)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let w = proposal.width ?? 360; var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0
        for s in subviews { let z = s.sizeThatFits(.unspecified); if x + z.width > w, x > 0 { x = 0; y += rowH + spacing; rowH = 0 }; x += z.width + spacing; rowH = max(rowH, z.height) }
        return CGSize(width: w, height: y + rowH)
    }
    func placeSubviews(in b: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = b.minX, y = b.minY, rowH: CGFloat = 0
        for s in subviews { let z = s.sizeThatFits(.unspecified); if x + z.width > b.maxX, x > b.minX { x = b.minX; y += rowH + spacing; rowH = 0 }; s.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(z)); x += z.width + spacing; rowH = max(rowH, z.height) }
    }
}
