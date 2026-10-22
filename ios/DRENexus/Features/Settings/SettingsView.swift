import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("role") private var role = Role.dre.rawValue
    @AppStorage("officerName") private var name = ""
    @AppStorage("agency") private var agency = ""
    @AppStorage("lockEnabled") private var lockEnabled = true
    @AppStorage("spanish") private var spanish = false
    @Environment(\.modelContext) private var ctx
    @State private var confirmWipe = false
    var body: some View {
        Form {
            Section("Profile") {
                Picker("Role", selection: $role) { ForEach(Role.allCases) { Text($0.rawValue).tag($0.rawValue) } }.pickerStyle(.segmented)
                TextField("Name", text: $name); TextField("Agency", text: $agency)
            }
            Section("Field") { Toggle("Spanish instructions by default", isOn: $spanish) }
            Section {
                Toggle("Require Face ID / passcode", isOn: $lockEnabled)
            } header: { Text("Security") } footer: { Text("Case data is stored on-device with Data Protection (complete). Nothing is uploaded.") }
            Section { Button("Delete all cases", role: .destructive) { confirmWipe = true } }
            Section("About") {
                Text("Reference content follows the IACP/NHTSA DEC Drug Symptomatology Matrix. Trend figures are illustrative. Always follow agency policy and current training.").font(.footnote).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
        .confirmationDialog("Delete all cases and media?", isPresented: $confirmWipe, titleVisibility: .visible) {
            Button("Delete everything", role: .destructive) { try? ctx.delete(model: Investigation.self); try? ctx.delete(model: MediaItem.self); try? ctx.save() }
        }
    }
}
