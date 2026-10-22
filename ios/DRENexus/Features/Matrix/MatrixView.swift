import SwiftUI

struct MatrixGrid: View {
    var detail: [String: [String: MatrixEngine.CellMatch]] = [:]
    var body: some View {
        ScrollView(.horizontal) {
            Grid(alignment: .center, horizontalSpacing: 0, verticalSpacing: 0) {
                GridRow {
                    Text("").frame(width: 120)
                    ForEach(Seed.categories) { c in VStack(spacing: 4) { CategoryIcon(id: c.id, size: 28); Text(c.short).font(.caption2.weight(.semibold)) }.frame(width: 92).padding(.vertical, 6) }
                }
                ForEach(Seed.data.matrixRows, id: \.k) { r in
                    Divider().gridCellColumns(8)
                    GridRow {
                        Text(r.label).font(.footnote.weight(.semibold)).frame(width: 120, alignment: .leading)
                        ForEach(Seed.categories) { c in
                            let m = detail[c.id]?[r.k]
                            Text(Seed.data.matrix[c.id]?[r.k]?.t ?? "").font(.caption).multilineTextAlignment(.center)
                                .frame(width: 92, height: 44)
                                .background(m == .hit ? DN.ok.opacity(0.18) : m == .alt ? DN.warn.opacity(0.18) : .clear)
                                .foregroundStyle(m == .miss ? .secondary : .primary)
                        }
                    }
                }
            }
            .padding(.vertical, 6)
        }
        .scrollIndicators(.hidden)
    }
}

struct FootnotesView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Seed.data.footnotes.sorted(by: { $0.key < $1.key }), id: \.key) { k, v in Text("(\(k)) \(v)").font(.caption).foregroundStyle(.secondary) }
        }
    }
}

struct MatrixView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Drug Symptomatology Matrix (IACP / NHTSA DEC Program)").foregroundStyle(.secondary)
                ContentCard { MatrixGrid(); FootnotesView() }
                ForEach(Seed.categories) { c in
                    ContentCard {
                        HStack { CategoryIcon(id: c.id); VStack(alignment: .leading) { Text(c.name).font(.headline); Text(Seed.data.admin[c.id] ?? "").font(.footnote).foregroundStyle(.secondary) } }
                        Text(c.desc).foregroundStyle(.secondary)
                        Text("Duration: \(Seed.data.onset[c.id] ?? "")").font(.subheadline)
                        Text("Overdose: \(Seed.data.overdose[c.id] ?? "")").font(.subheadline)
                    }
                    .materialize()
                }
            }
            .padding()
        }
        .navigationTitle("DRE Matrix")
    }
}

/// Live Matrix sheet driven by the current case.
struct LiveMatrixSheet: View {
    let payload: CasePayload
    var body: some View {
        let ind = MatrixEngine.indicators(for: payload)
        let r = MatrixEngine.rank(ind)
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Green: consistent. Amber: consistent via a Matrix footnote.").font(.footnote).foregroundStyle(.secondary)
                    ContentCard { MatrixGrid(detail: Dictionary(uniqueKeysWithValues: r.categories.map { ($0.category.id, $0.detail) })); FootnotesView() }
                    MatrixResults(indicators: ind)
                }.padding()
            }
            .navigationTitle("Live Matrix").navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
        .presentationBackgroundInteraction(.enabled(upThrough: .medium))
    }
}
