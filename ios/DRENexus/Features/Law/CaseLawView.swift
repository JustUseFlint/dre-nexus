import SwiftUI

struct CaseLawView: View {
    @State private var query = ""
    @State private var area = "All"
    var results: [CaseLaw] {
        Seed.data.caseLaw.filter { c in (area == "All" || c.t == area) && (query.isEmpty || ([c.n, c.c, c.ct, c.s] + c.tags).joined(separator: " ").localizedCaseInsensitiveContains(query)) }
    }
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                Picker("Area", selection: $area) { ForEach(["All", "Impairment", "Possession"], id: \.self) { Text($0) } }.pickerStyle(.segmented)
                ForEach(results) { c in
                    ContentCard {
                        HStack { Text(c.ct.uppercased()).font(.caption.weight(.semibold)).foregroundStyle(.secondary); Spacer(); Text(c.t).font(.caption.weight(.semibold)).padding(.horizontal, 8).padding(.vertical, 4).background(.quaternary, in: .capsule) }
                        Text(c.n).font(.title3.weight(.semibold))
                        Text(c.c).font(.footnote.monospaced()).foregroundStyle(.secondary).textSelection(.enabled)
                        Text(c.s)
                        FlowLayout { ForEach(c.tags, id: \.self) { t in Button(t) { query = t }.font(.caption).buttonStyle(.bordered).controlSize(.small) } }
                    }
                    .materialize()
                }
                Text("Summaries are for training; confirm current law in your jurisdiction.").font(.footnote).foregroundStyle(.secondary)
            }
            .padding()
        }
        .searchable(text: $query, prompt: "Case, citation, issue")
        .navigationTitle("Case Law")
    }
}
