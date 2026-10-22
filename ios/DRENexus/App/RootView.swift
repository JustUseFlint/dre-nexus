import SwiftData
import SwiftUI

struct RootView: View {
    @State private var tab = "home"
    @State private var showMatch = false
    var body: some View {
        TabView(selection: $tab) {
            Tab("Home", systemImage: "house.fill", value: "home") { NavigationStack { HomeView() } }
            Tab("Drugs", systemImage: "square.grid.2x2.fill", value: "hub") { NavigationStack { HubView() } }
            Tab("Cases", systemImage: "folder.fill", value: "cases") { NavigationStack { CasesView() } }
            Tab("Matrix", systemImage: "tablecells.fill", value: "matrix") { NavigationStack { MatrixView() } }
            Tab("Law", systemImage: "building.columns.fill", value: "law") { NavigationStack { CaseLawView() } }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewBottomAccessory {
            Button { showMatch = true } label: { Label("Match observed signs", systemImage: "waveform.path.ecg").frame(maxWidth: .infinity) }
        }
        .sheet(isPresented: $showMatch) { NavigationStack { MatchToolView() }.presentationDetents([.large]) }
    }
}

struct HomeView: View {
    @Query(sort: \Investigation.updated, order: .reverse) private var cases: [Investigation]
    @Environment(\.modelContext) private var ctx
    @AppStorage("role") private var role = Role.dre.rawValue
    @AppStorage("officerName") private var name = ""
    @State private var path: Investigation?
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                hero.materialize()
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    NavigationLink { MatchToolView() } label: { tile("HAL", "Match tool", "Observed signs → categories") }
                    NavigationLink { MatrixView() } label: { tile("DA", "DRE Matrix", "Full symptomatology") }
                    NavigationLink { HubView() } label: { tile("NA", "Drug hub", "\(Seed.data.substances.count) substances") }
                    NavigationLink { CaseLawView() } label: { tile("CAN", "Case law", "Impairment & possession") }
                }
                .buttonStyle(PressScale()).materialize(0.05)
                SectionTitle(text: "Recent cases")
                ForEach(cases.prefix(3)) { c in NavigationLink { CaseDetailView(item: c) } label: { CaseRow(item: c) }.buttonStyle(PressScale()) }
            }
            .padding()
        }
        .scrollEdgeEffectStyle(.soft, for: .top)
        .navigationTitle("DRE Nexus")
        .toolbar { ToolbarItem(placement: .topBarTrailing) { NavigationLink { SettingsView() } label: { Image(systemName: "gearshape") } } }
        .navigationDestination(item: $path) { CaseDetailView(item: $0) }
    }
    var hero: some View {
        ZStack(alignment: .topTrailing) {
            HeroOrbit().frame(width: 200, height: 200).offset(x: 40, y: -30).visualEffect { c, proxy in
                c.offset(y: -proxy.frame(in: .scrollView).minY * 0.25) // parallax
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(role == Role.dre.rawValue ? "DRUG RECOGNITION EXPERT" : "PATROL OFFICER").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                Text(greeting + (name.isEmpty ? "" : ", \(name.split(separator: " ").first ?? "")")).font(.largeTitle.bold()).frame(maxWidth: 230, alignment: .leading)
                Text("\(cases.filter { $0.status != .closed }.count) open cases").foregroundStyle(.secondary)
                Button { newCase() } label: { Label("New investigation", systemImage: "plus").frame(minHeight: 44) }
                    .buttonStyle(.glassProminent).controlSize(.large).padding(.top, 6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(22)
        .background(RadialGradient(colors: [Color(hex: "#1B3A7A"), Color(hex: "#0B1428"), .black], center: .topLeading, startRadius: 0, endRadius: 420), in: .rect(cornerRadius: 28, style: .continuous))
        .clipShape(.rect(cornerRadius: 28, style: .continuous))
    }
    var greeting: String { let h = Calendar.current.component(.hour, from: .now); return h < 12 ? "Good morning" : h < 18 ? "Good afternoon" : "Good evening" }
    func tile(_ cat: String, _ title: String, _ sub: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            CategoryIcon(id: cat)
            Text(title).font(.headline).foregroundStyle(.primary)
            Text(sub).font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.leading)
        }
        .padding(14).frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading)
        .background(DN.card, in: .rect(cornerRadius: 20, style: .continuous))
    }
    func newCase() {
        let n = Investigation(number: String(format: "DN-%d-%03d", Calendar.current.component(.year, from: .now), cases.count + 1), title: "New investigation")
        ctx.insert(n); path = n; Haptics.success()
    }
}

struct HeroOrbit: View {
    @Environment(\.accessibilityReduceMotion) private var rm
    var body: some View {
        TimelineView(.animation(paused: rm)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate / 20
            Canvas { ctx, sz in
                let c = CGPoint(x: sz.width / 2, y: sz.height / 2)
                for r in [44.0, 64, 84] { ctx.stroke(Path(ellipseIn: .init(x: c.x - r, y: c.y - r, width: 2 * r, height: 2 * r)), with: .color(Color(hex: "#9CC2FF").opacity(0.35)), lineWidth: 1) }
                ctx.fill(Path(ellipseIn: .init(x: c.x - 10, y: c.y - 10, width: 20, height: 20)), with: .color(Color(hex: "#9CC2FF")))
                for (i, cat) in Seed.categories.enumerated() {
                    let a = Double(i) / 7 * 2 * .pi + t
                    ctx.fill(Path(ellipseIn: .init(x: c.x + cos(a) * 64 - 5, y: c.y + sin(a) * 64 - 5, width: 10, height: 10)), with: .color(cat.tint))
                }
            }
        }
        .accessibilityHidden(true)
    }
}
