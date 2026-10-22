import SwiftUI

/// Custom glyphs for the 7 DRE categories, drawn on a 48pt grid (mirrors the web replica's SVGs).
struct CategoryIcon: View {
    let id: String
    var size: CGFloat = 44
    var body: some View {
        let c = Seed.category(id).tint
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.3, style: .continuous).fill(c.opacity(0.14))
            RoundedRectangle(cornerRadius: size * 0.3, style: .continuous).strokeBorder(c.opacity(0.25))
            Canvas { ctx, sz in
                let s = sz.width / 48
                ctx.scaleBy(x: s, y: s)
                let st = StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round)
                switch id {
                case "DEP":
                    for (y, o) in [(18.0, 1.0), (27.0, 0.55)] {
                        var p = Path(); p.move(to: .init(x: 10, y: y))
                        p.addCurve(to: .init(x: 26, y: y), control1: .init(x: 14, y: y), control2: .init(x: 22, y: y + 6))
                        p.addCurve(to: .init(x: 38, y: y + 6), control1: .init(x: 30, y: y), control2: .init(x: 34, y: y + 6))
                        ctx.stroke(p, with: .color(c.opacity(o)), style: st)
                    }
                case "STI":
                    var p = Path(); p.addLines([.init(x: 26, y: 7), .init(x: 14, y: 26), .init(x: 23, y: 26), .init(x: 21, y: 41), .init(x: 34, y: 20), .init(x: 25, y: 20)]); p.closeSubpath()
                    ctx.fill(p, with: .color(c.opacity(0.2))); ctx.stroke(p, with: .color(c), style: st)
                case "HAL":
                    var p = Path(); p.move(to: .init(x: 6, y: 24))
                    p.addQuadCurve(to: .init(x: 42, y: 24), control: .init(x: 24, y: 6)); p.addQuadCurve(to: .init(x: 6, y: 24), control: .init(x: 24, y: 42))
                    ctx.stroke(p, with: .color(c), style: st)
                    ctx.stroke(Path(ellipseIn: .init(x: 18, y: 18, width: 12, height: 12)), with: .color(c), style: st)
                    ctx.fill(Path(ellipseIn: .init(x: 22, y: 22, width: 4, height: 4)), with: .color(c))
                case "DA":
                    ctx.stroke(Path(ellipseIn: .init(x: 10, y: 10, width: 28, height: 28)), with: .color(c), style: StrokeStyle(lineWidth: 2.2, dash: [4, 4]))
                    var p = Path(); p.move(to: .init(x: 24, y: 10)); p.addLine(to: .init(x: 24, y: 38)); ctx.stroke(p, with: .color(c), style: st)
                    ctx.fill(Path(ellipseIn: .init(x: 14, y: 21, width: 6, height: 6)), with: .color(c.opacity(0.4)))
                case "NA":
                    for a in stride(from: 0.0, to: 360, by: 90) {
                        let r = a * .pi / 180
                        ctx.fill(Path(ellipseIn: .init(x: 24 + cos(r) * 7 - 6, y: 22 + sin(r) * 7 - 6, width: 12, height: 12)), with: .color(c.opacity(0.35)))
                    }
                    ctx.fill(Path(ellipseIn: .init(x: 20.8, y: 18.8, width: 6.4, height: 6.4)), with: .color(c))
                    var p = Path(); p.move(to: .init(x: 24, y: 29)); p.addLine(to: .init(x: 24, y: 40)); ctx.stroke(p, with: .color(c), style: st)
                case "INH":
                    ctx.stroke(Path(roundedRect: .init(x: 15, y: 16, width: 12, height: 24), cornerRadius: 3), with: .color(c), style: st)
                    var p = Path(); p.move(to: .init(x: 18, y: 16)); p.addLine(to: .init(x: 18, y: 12)); p.addLine(to: .init(x: 24, y: 12)); p.addLine(to: .init(x: 24, y: 16)); ctx.stroke(p, with: .color(c), style: st)
                    for y in [12.0, 18, 24] { var w = Path(); w.move(to: .init(x: 31, y: y)); w.addQuadCurve(to: .init(x: 38, y: y + 1), control: .init(x: 34, y: y - 2)); ctx.stroke(w, with: .color(c.opacity(0.7)), style: st) }
                case "CAN":
                    var stem = Path(); stem.move(to: .init(x: 24, y: 40)); stem.addLine(to: .init(x: 24, y: 22)); ctx.stroke(stem, with: .color(c), style: st)
                    for (dx, dy) in [(0.0, -14.0), (-12, -5), (12, -5), (-11, 4), (11, 4)] {
                        var leaf = Path(); leaf.move(to: .init(x: 24, y: 24)); leaf.addQuadCurve(to: .init(x: 24 + dx, y: 24 + dy), control: .init(x: 24 + dx * 0.3 - 3, y: 24 + dy * 0.6)); leaf.addQuadCurve(to: .init(x: 24, y: 24), control: .init(x: 24 + dx * 0.6 + 3, y: 24 + dy * 0.3))
                        ctx.fill(leaf, with: .color(c.opacity(0.3))); ctx.stroke(leaf, with: .color(c), style: st)
                    }
                default:
                    ctx.stroke(Path(roundedRect: .init(x: 12, y: 18, width: 24, height: 12), cornerRadius: 6), with: .color(c), style: st)
                }
            }
            .padding(1)
        }
        .frame(width: size, height: size)
        .accessibilityLabel(Seed.category(id).name)
    }
}

/// Walk-and-Turn line with 9 steps per pass; missed or off-line steps highlighted.
struct WalkTurnDiagram: View {
    var pass1: Set<Int> = [], pass2: Set<Int> = [], improperTurn = false
    var body: some View {
        Canvas { ctx, sz in
            let w = sz.width, mid = sz.height / 2, gap = (w - 60) / 8
            var line = Path(); line.move(to: .init(x: 10, y: mid)); line.addLine(to: .init(x: w - 10, y: mid))
            ctx.stroke(line, with: .color(.secondary.opacity(0.4)), style: StrokeStyle(lineWidth: 2, dash: [6, 5]))
            for i in 0..<9 {
                let x1 = 24 + CGFloat(i) * gap, x2 = 24 + CGFloat(8 - i) * gap
                ctx.fill(Path(roundedRect: .init(x: x1 - 10, y: mid - 26, width: 22, height: 12), cornerRadius: 6), with: .color(pass1.contains(i + 1) ? DN.bad : DN.accent.opacity(0.8)))
                ctx.fill(Path(roundedRect: .init(x: x2 - 10, y: mid + 14, width: 22, height: 12), cornerRadius: 6), with: .color(pass2.contains(i + 1) ? DN.bad : DN.accent.opacity(0.8)))
                ctx.draw(Text("\(i + 1)").font(.caption2).foregroundStyle(.secondary), at: .init(x: x1 + 1, y: mid - 36))
            }
            var turn = Path(); turn.move(to: .init(x: w - 20, y: mid - 20)); turn.addQuadCurve(to: .init(x: w - 20, y: mid + 20), control: .init(x: w, y: mid))
            ctx.stroke(turn, with: .color(improperTurn ? DN.bad : DN.accent), style: StrokeStyle(lineWidth: 2, dash: [3, 3]))
        }
        .frame(height: 110)
        .accessibilityLabel("Walk and Turn step diagram")
    }
}

struct StickFigure: Shape {
    var oneLeg = false, headBack = false
    func path(in r: CGRect) -> Path {
        var p = Path(); let cx = r.midX, s = r.height / 160
        p.addEllipse(in: CGRect(x: cx - 12 * s + (headBack ? 3 * s : 0), y: 6 * s, width: 24 * s, height: 24 * s))
        p.move(to: .init(x: cx, y: 30 * s)); p.addLine(to: .init(x: cx, y: 88 * s))
        p.move(to: .init(x: cx, y: 46 * s)); p.addLine(to: .init(x: cx - 14 * s, y: 84 * s))
        p.move(to: .init(x: cx, y: 46 * s)); p.addLine(to: .init(x: cx + 14 * s, y: 84 * s))
        p.move(to: .init(x: cx, y: 88 * s)); p.addLine(to: .init(x: cx - 6 * s, y: 150 * s))
        p.move(to: .init(x: cx, y: 88 * s)); p.addLine(to: oneLeg ? .init(x: cx + 24 * s, y: 124 * s) : .init(x: cx + 6 * s, y: 150 * s))
        if oneLeg { p.addLine(to: .init(x: cx + 42 * s, y: 124 * s)) }
        return p
    }
}

struct OneLegStandDiagram: View {
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            StickFigure(oneLeg: true).stroke(.primary, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
            Text("≈ 6 in").font(.caption).foregroundStyle(DN.accent).padding(.trailing, 40).padding(.bottom, 14)
        }.frame(height: 160)
    }
}

struct RombergDiagram: View {
    var body: some View {
        ZStack {
            StickFigure(headBack: true).stroke(.primary, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
            HStack { Image(systemName: "arrow.left.and.right").foregroundStyle(DN.warn); Spacer(); Text("est. 30 s").font(.caption).foregroundStyle(.secondary) }.padding(.horizontal, 40)
        }.frame(height: 160)
    }
}

struct HGNDiagram: View {
    var body: some View {
        Canvas { ctx, sz in
            let c = CGPoint(x: sz.width / 2, y: sz.height - 14), r = min(sz.width / 2 - 20, sz.height - 30)
            var arc = Path(); arc.addArc(center: c, radius: r, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
            ctx.stroke(arc, with: .color(.secondary.opacity(0.35)), lineWidth: 1)
            for a in [135.0, 45.0] {
                var l = Path(); l.move(to: c); l.addLine(to: .init(x: c.x + cos(a * .pi / 180) * r, y: c.y - sin(a * .pi / 180) * r))
                ctx.stroke(l, with: .color(DN.warn), style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
            }
            var md = Path(); md.move(to: .init(x: c.x - r, y: c.y)); md.addLine(to: .init(x: c.x + r, y: c.y))
            ctx.stroke(md, with: .color(DN.bad), lineWidth: 2)
            ctx.fill(Path(ellipseIn: .init(x: c.x - 9, y: c.y - 9, width: 18, height: 18)), with: .color(.primary))
            ctx.draw(Text("45°").font(.caption).foregroundStyle(DN.warn), at: .init(x: c.x - r * 0.75, y: c.y - r * 0.8))
            ctx.draw(Text("45°").font(.caption).foregroundStyle(DN.warn), at: .init(x: c.x + r * 0.75, y: c.y - r * 0.8))
        }
        .frame(height: 140)
        .accessibilityLabel("HGN pass angles: 45 degree onset and maximum deviation")
    }
}

struct ConvergenceDiagram: View {
    @State private var t = 0.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { tl in
            Canvas { ctx, sz in
                let c = CGPoint(x: sz.width / 2, y: 60), r: CGFloat = 40
                ctx.stroke(Path(ellipseIn: .init(x: c.x - r, y: c.y - r, width: 2 * r, height: 2 * r)), with: .color(DN.accent), style: StrokeStyle(lineWidth: 2, dash: [5, 4]))
                var down = Path(); down.move(to: .init(x: c.x, y: c.y + r)); down.addLine(to: .init(x: c.x, y: c.y + r + 30))
                ctx.stroke(down, with: .color(DN.warn), lineWidth: 2.5)
                let a = tl.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 4) / 4 * 2 * .pi
                ctx.fill(Path(ellipseIn: .init(x: c.x + cos(a) * r - 5, y: c.y + sin(a) * r - 5, width: 10, height: 10)), with: .color(.primary))
            }
        }
        .frame(height: 140)
    }
}

struct FingerNoseDiagram: View {
    let attempts: [FTNAttempt]
    var body: some View {
        Canvas { ctx, sz in
            let c = CGPoint(x: sz.width / 2, y: sz.height / 2)
            ctx.stroke(Path(ellipseIn: .init(x: c.x - 46, y: c.y - 58, width: 92, height: 116)), with: .color(.secondary.opacity(0.4)), lineWidth: 1.5)
            let pts: [TouchLocation: CGPoint] = [.tip: .init(x: 0, y: 6), .pad: .init(x: 0, y: 14), .nail: .init(x: 0, y: 20), .bridge: .init(x: 0, y: -20), .upperLip: .init(x: 0, y: 26), .leftCheek: .init(x: -22, y: 8), .rightCheek: .init(x: 22, y: 8), .missed: .init(x: -50, y: 50)]
            for (i, a) in attempts.enumerated() {
                guard let loc = a.location, let p = pts[loc] else { continue }
                let x = c.x + p.x + CGFloat(i - 3) * 5, y = c.y + p.y
                ctx.fill(Path(ellipseIn: .init(x: x - 8, y: y - 8, width: 16, height: 16)), with: .color(loc == .tip ? DN.ok : DN.bad))
                ctx.draw(Text("\(i + 1)").font(.caption2.bold()).foregroundStyle(.black), at: .init(x: x, y: y))
            }
        }
        .frame(height: 150)
    }
}

/// Pupil gauge from 1.5 to 9.0 mm in 0.5 mm steps.
struct PupilGauge: View {
    let label: String
    let normal: ClosedRange<Double>
    @Binding var value: Double?
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(label) · normal \(normal.lowerBound, specifier: "%.1f")–\(normal.upperBound, specifier: "%.1f") mm").font(.footnote).foregroundStyle(.secondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(Array(stride(from: 1.5, through: 9.0, by: 0.5)), id: \.self) { mm in
                        let on = value == mm
                        Button { withAnimation(DN.spring) { value = on ? nil : mm } } label: {
                            VStack(spacing: 4) {
                                ZStack { Circle().fill(Color(hex: "#5B6F8F")); Circle().fill(.black).frame(width: mm * 4.6, height: mm * 4.6) }.frame(width: 40, height: 40)
                                Text(mm, format: .number.precision(.fractionLength(1))).font(.caption2.weight(.semibold)).monospacedDigit()
                            }
                            .frame(width: 52, height: 70)
                            .background(on ? DN.accent.opacity(0.18) : Color(uiColor: .tertiarySystemFill), in: .rect(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(on ? DN.accent : .clear, lineWidth: 1.5))
                        }.buttonStyle(PressScale())
                    }
                }
            }
            .scrollEdgeEffectStyle(.soft, for: .horizontal)
        }
    }
}

/// Tappable body map used for muscle tone and injection sites.
struct BodyMap: View {
    enum Mode { case tone, injection }
    let mode: Mode
    @Binding var marks: [String: String]
    @State private var side = "front"
    static let regions: [(String, CGRect)] = [
        ("head", .init(x: 84, y: 12, width: 32, height: 36)), ("neck", .init(x: 92, y: 50, width: 16, height: 12)),
        ("chestL", .init(x: 70, y: 70, width: 28, height: 32)), ("chestR", .init(x: 102, y: 70, width: 28, height: 32)),
        ("abdomen", .init(x: 78, y: 106, width: 44, height: 36)), ("armUL", .init(x: 55, y: 70, width: 14, height: 44)),
        ("armUR", .init(x: 131, y: 70, width: 14, height: 44)), ("elbowL", .init(x: 51, y: 115, width: 14, height: 14)),
        ("elbowR", .init(x: 135, y: 115, width: 14, height: 14)), ("forearmL", .init(x: 48, y: 128, width: 12, height: 36)),
        ("forearmR", .init(x: 140, y: 128, width: 12, height: 36)), ("handL", .init(x: 45, y: 167, width: 14, height: 18)),
        ("handR", .init(x: 141, y: 167, width: 14, height: 18)), ("thighL", .init(x: 78, y: 156, width: 20, height: 52)),
        ("thighR", .init(x: 102, y: 156, width: 20, height: 52)), ("kneeL", .init(x: 80, y: 207, width: 16, height: 14)),
        ("kneeR", .init(x: 104, y: 207, width: 16, height: 14)), ("calfL", .init(x: 81, y: 222, width: 14, height: 40)),
        ("calfR", .init(x: 105, y: 222, width: 14, height: 40)), ("footL", .init(x: 77, y: 266, width: 18, height: 12)),
        ("footR", .init(x: 105, y: 266, width: 18, height: 12))]
    var cycle: [String] { mode == .tone ? ["normal", "flaccid", "rigid"] : ["fresh", "old"] }
    func color(_ v: String?) -> Color {
        switch v ?? "" { case "normal": DN.ok; case "flaccid": Color(hex: "#5B8CFF"); case "rigid", "fresh": DN.bad; case "old": DN.warn; default: DN.accent.opacity(0.12) }
    }
    var body: some View {
        VStack(spacing: 10) {
            Picker("Side", selection: $side.animation(DN.spring)) { Text("Front").tag("front"); Text("Back").tag("back") }.pickerStyle(.segmented).frame(maxWidth: 260)
            GeometryReader { g in
                let s = min(g.size.width / 200, g.size.height / 290)
                ZStack(alignment: .topLeading) {
                    ForEach(Self.regions, id: \.0) { name, rect in
                        let key = "\(side).\(name)"
                        Ellipse().fill(color(marks[key])).overlay(Ellipse().strokeBorder(DN.accent.opacity(0.35)))
                            .frame(width: rect.width * s, height: rect.height * s)
                            .offset(x: rect.minX * s, y: rect.minY * s)
                            .onTapGesture {
                                withAnimation(DN.spring) {
                                    let i = cycle.firstIndex(of: marks[key] ?? "") ?? -1
                                    if i == cycle.count - 1 { marks[key] = nil } else { marks[key] = cycle[i + 1] }
                                }
                                Haptics.tap()
                            }
                            .accessibilityLabel("\(side) \(name)")
                    }
                }
                .frame(width: 200 * s, height: 290 * s).frame(maxWidth: .infinity)
            }
            .frame(height: 340)
            Text(mode == .tone ? "Tap: normal → flaccid → rigid → clear" : "Tap: fresh → old/healing → clear").font(.footnote).foregroundStyle(.secondary)
        }
    }
}
