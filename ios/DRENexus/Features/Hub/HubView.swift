import Charts
import SwiftUI

struct HubView: View {
    @State private var query = ""
    @State private var cat: String? = nil
    @State private var type = "All"
    var results: [Substance] {
        Seed.data.substances.filter { s in
            (cat == nil || s.cat == cat) && (type == "All" || s.type == type) &&
            (query.isEmpty || ([s.name, s.official, s.sched] + s.street).joined(separator: " ").localizedCaseInsensitiveContains(query))
        }
    }
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        chip(nil, "All")
                        ForEach(Seed.categories) { c in chip(c.id, c.short) }
                        chip("NONE", "Reference")
                    }
                }
                Picker("Type", selection: $type) { ForEach(["All", "Prescription", "OTC", "Illicit", "Inhalant"], id: \.self) { Text($0) } }.pickerStyle(.segmented)
                ContentCard(padding: 0) {
                    ForEach(results) { s in
                        NavigationLink { DrugDetailView(substance: s) } label: {
                            HStack(spacing: 12) {
                                CategoryIcon(id: s.cat, size: 40)
                                VStack(alignment: .leading) {
                                    Text(s.name).font(.headline).foregroundStyle(.primary)
                                    Text(s.street.prefix(3).joined(separator: ", ")).font(.footnote).foregroundStyle(.secondary).lineLimit(1)
                                }
                                Spacer()
                                Text(s.sched.components(separatedBy: " (").first ?? "").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                                Image(systemName: "chevron.right").font(.footnote).foregroundStyle(.tertiary)
                            }
                            .padding(.horizontal, 16).frame(minHeight: 60)
                        }
                        if s.id != results.last?.id { Divider().padding(.leading, 68) }
                    }
                }
                .animation(DN.spring, value: results.map(\.id))
                Text("\(results.count) of \(Seed.data.substances.count) substances").font(.footnote).foregroundStyle(.secondary)
            }
            .padding()
        }
        .searchable(text: $query, prompt: "Name, street name, schedule")
        .scrollEdgeEffectStyle(.soft, for: .top)
        .navigationTitle("Drug Hub")
    }
    func chip(_ id: String?, _ t: String) -> some View {
        Button { withAnimation(DN.spring) { cat = id } } label: {
            HStack(spacing: 6) { if let id { Circle().fill(Seed.category(id).tint).frame(width: 8, height: 8) }; Text(t) }
                .font(.subheadline.weight(.medium)).padding(.horizontal, 14).frame(minHeight: 40)
        }
        .buttonStyle(.glass)
        .tint(cat == id ? DN.accent : nil)
    }
}

struct DrugDetailView: View {
    let substance: Substance
    @State private var mode = "Seizures"
    var cat: DrugCategory { Seed.category(substance.cat) }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 14) {
                        CategoryIcon(id: substance.cat, size: 56)
                        VStack(alignment: .leading) { Text(cat.name.uppercased()).font(.caption.weight(.semibold)).foregroundStyle(cat.tint); Text(substance.name).font(.largeTitle.bold()) }
                    }
                    Text(substance.official).foregroundStyle(.secondary)
                    FlowLayout { ForEach(substance.street, id: \.self) { Text($0).font(.caption.weight(.semibold)).padding(.horizontal, 10).padding(.vertical, 5).background(.quaternary, in: .capsule) } }
                }
                .padding(20).frame(maxWidth: .infinity, alignment: .leading)
                .background(RadialGradient(colors: [cat.tint.opacity(0.3), .clear], center: .topTrailing, startRadius: 0, endRadius: 320), in: .rect(cornerRadius: 28))
                .background(DN.card, in: .rect(cornerRadius: 28))
                .materialize()
                HStack(spacing: 10) { fact("DEA schedule", substance.sched); fact("Rx status", substance.rx) }
                ContentCard {
                    row("Medical use", substance.use); row("Typical dosage", substance.dose); row("Onset", substance.onset); row("Duration", substance.duration); row("Routes", substance.routes)
                    HStack { Text("Abuse potential").foregroundStyle(.secondary).frame(width: 130, alignment: .leading); HStack(spacing: 3) { ForEach(1...5, id: \.self) { i in Capsule().fill(i <= substance.abuse ? cat.tint : Color.secondary.opacity(0.25)).frame(width: 22, height: 8) } } }
                    row("Street price", substance.price)
                }
                if substance.cat != "NONE", let m = Seed.data.matrix[substance.cat] {
                    SectionTitle(text: "Indicators vs Matrix")
                    ContentCard {
                        ForEach(Seed.data.matrixRows, id: \.k) { r in
                            HStack(alignment: .top) {
                                Text(r.label).font(.subheadline.weight(.semibold)).frame(width: 120, alignment: .leading)
                                Text(m[r.k]?.t ?? "").frame(width: 110, alignment: .leading)
                                Text(substance.flags[r.k] ?? "As Matrix").foregroundStyle(substance.flags[r.k] == nil ? Color.secondary : DN.warn).font(.subheadline)
                            }
                            Divider()
                        }
                        Text("General indicators").font(.headline)
                        FlowLayout { ForEach(Seed.data.general[substance.cat] ?? [], id: \.self) { Text($0).font(.caption).padding(.horizontal, 10).padding(.vertical, 5).background(.quaternary, in: .capsule) } }
                        Text("Overdose signs").font(.headline)
                        Text(Seed.data.overdose[substance.cat] ?? "").foregroundStyle(.secondary)
                    }
                }
                SectionTitle(text: "History")
                ContentCard { Text(substance.history) }
                SectionTitle(text: "Trends")
                ContentCard {
                    Picker("Series", selection: $mode) { Text("Seizures").tag("Seizures"); Text("Arrests").tag("Arrests") }.pickerStyle(.segmented)
                    let s = Seed.data.trends[substance.id]
                    let values = (mode == "Seizures" ? s?.seizures : s?.arrests) ?? []
                    Chart(Array(zip(Seed.data.years, values)), id: \.0) { pt in
                        AreaMark(x: .value("Year", String(pt.0)), y: .value("Index", pt.1)).foregroundStyle(cat.tint.opacity(0.2).gradient)
                        LineMark(x: .value("Year", String(pt.0)), y: .value("Index", pt.1)).foregroundStyle(cat.tint).symbol(.circle)
                    }
                    .chartYScale(domain: 0...100).frame(height: 180).animation(DN.spring, value: mode)
                    Text(Seed.data.trendsNote).font(.caption).foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle(substance.name).navigationBarTitleDisplayMode(.inline)
    }
    func fact(_ k: String, _ v: String) -> some View { ContentCard { Text(k.uppercased()).font(.caption.weight(.semibold)).foregroundStyle(.secondary); Text(v).font(.headline) } }
    func row(_ k: String, _ v: String) -> some View { HStack(alignment: .top) { Text(k).foregroundStyle(.secondary).frame(width: 130, alignment: .leading); Text(v) } }
}

struct MatchToolView: View {
    @State private var ind: [String: String] = [:]
    let fields: [(String, String, [(String, String)])] = [
        ("hgn", "HGN", [("present", "Present"), ("none", "None")]), ("vgn", "Vertical nystagmus", [("present", "Present"), ("none", "None")]),
        ("loc", "Lack of convergence", [("present", "Present"), ("none", "None")]), ("pupil", "Pupil size", [("constricted", "Constricted"), ("normal", "Normal"), ("dilated", "Dilated")]),
        ("rtl", "Reaction to light", [("normal", "Normal"), ("slow", "Slow"), ("none", "Little/none")]), ("pulse", "Pulse", [("down", "Down"), ("normal", "Normal"), ("up", "Up")]),
        ("bp", "Blood pressure", [("down", "Down"), ("normal", "Normal"), ("up", "Up")]), ("temp", "Temperature", [("down", "Down"), ("normal", "Normal"), ("up", "Up")]),
        ("tone", "Muscle tone", [("flaccid", "Flaccid"), ("normal", "Normal"), ("rigid", "Rigid")])]
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ContentCard {
                    ForEach(fields, id: \.0) { k, label, opts in
                        Text(label).font(.footnote).foregroundStyle(.secondary)
                        Picker(label, selection: Binding(get: { ind[k] ?? "" }, set: { ind[k] = $0.isEmpty ? nil : $0 })) {
                            Text("–").tag(""); ForEach(opts, id: \.0) { Text($0.1).tag($0.0) }
                        }.pickerStyle(.segmented)
                    }
                }
                SectionTitle(text: "Ranking")
                MatrixResults(indicators: ind)
            }
            .padding()
        }
        .navigationTitle("Match tool")
        .toolbar { Button("Reset", systemImage: "arrow.counterclockwise") { withAnimation(DN.spring) { ind = [:] } } }
    }
}

struct MatrixResults: View {
    let indicators: [String: String]
    var body: some View {
        let r = MatrixEngine.rank(indicators)
        VStack(alignment: .leading, spacing: 10) {
            if indicators.isEmpty { Text("Enter observations to rank categories.").foregroundStyle(.secondary) }
            else {
                ForEach(r.categories) { c in
                    HStack(spacing: 12) {
                        CategoryIcon(id: c.category.id, size: 34)
                        VStack(alignment: .leading, spacing: 6) {
                            HStack { Text(c.category.name).font(.subheadline.weight(.semibold)); Spacer(); Text("\(Int(c.score * 100))%").monospacedDigit().foregroundStyle(.secondary) }
                            Gauge(value: c.score) { EmptyView() }.gaugeStyle(.accessoryLinearCapacity).tint(c.category.tint)
                        }
                    }
                }
                .animation(DN.spring, value: indicators)
                Text("Most consistent substances").font(.headline).padding(.top, 8)
                ForEach(r.substances.prefix(6)) { s in
                    NavigationLink { DrugDetailView(substance: s.substance) } label: {
                        HStack { CategoryIcon(id: s.substance.cat, size: 30); VStack(alignment: .leading) { Text(s.substance.name).foregroundStyle(.primary); if !s.reasons.isEmpty { Text(s.reasons.joined(separator: "; ")).font(.caption).foregroundStyle(DN.warn) } }; Spacer(); Text("\(Int(s.score * 100))%").foregroundStyle(.secondary) }
                    }
                }
                Text("Polydrug use can mask indicators. Rankings support, and never replace, the evaluator's opinion based on the full 12-step evaluation.").font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}
