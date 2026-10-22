import SwiftUI

struct SFSTHubView: View {
    let session: CaseSession
    var body: some View {
        @Bindable var s = session
        let sf = s.payload.sfst
        List {
            Section("Phase 1 · Vehicle in motion") {
                NavigationLink { CuesView(sfst: $s.payload.sfst) } label: { row("NHTSA visual detection cues", "\(sf.cues.count) selected", "car.fill") }
            }
            Section("Phase 2 · Personal contact") {
                NavigationLink { ContactView(sfst: $s.payload.sfst) } label: { row("Contact observations", "\(sf.contactObservations.count + sf.odors.count + sf.speech.count) noted", "person.wave.2.fill") }
                NavigationLink { DriverInfoView(subject: $s.payload.subject) } label: { row("Driver & vehicle", s.payload.subject.last.isEmpty ? "Scan license" : "\(s.payload.subject.last), \(s.payload.subject.first)", "person.text.rectangle") }
            }
            Section("Phase 3 · Pre-arrest screening") {
                NavigationLink { TestPage(title: "HGN", key: "hgn") { HGNTestView(test: $s.payload.sfst.hgn) } } label: { row("Horizontal Gaze Nystagmus", "\(sf.hgn.totalClues)/6 clues", "eye") }
                NavigationLink { TestPage(title: "Walk and Turn", key: "wat") { WATTestView(test: $s.payload.sfst.wat) } } label: { row("Walk and Turn", "\(sf.wat.totalClues)/8 clues", "figure.walk") }
                NavigationLink { TestPage(title: "One Leg Stand", key: "ols") { OLSTestView(test: $s.payload.sfst.ols) } } label: { row("One Leg Stand", "\(sf.ols.totalClues)/4 clues", "figure.stand") }
                NavigationLink { TestPage(title: "ARIDE · Lack of Convergence", key: "loc") { LOCTestView(test: $s.payload.sfst.loc) } } label: { row("Lack of Convergence (ARIDE)", sf.loc.left?.rawValue ?? "–", "eyes") }
                NavigationLink { TestPage(title: "ARIDE · Modified Romberg", key: "rom") { RombergTestView(test: $s.payload.sfst.romberg) } } label: { row("Modified Romberg (ARIDE)", sf.romberg.estimatedSeconds.map { "\($0) s estimate" } ?? "–", "timer") }
                NavigationLink { TestPage(title: "Finger to Nose", key: "ftn") { FTNTestView(test: $s.payload.sfst.ftn) } } label: { row("Finger to Nose", "\(sf.ftn.attempts.filter { $0.location != nil }.count)/6 attempts", "hand.point.up.left.fill") }
                NavigationLink { PBTView(sfst: $s.payload.sfst) } label: { row("Preliminary breath test", sf.pbtRefused ? "Refused" : sf.pbtResult.map { String(format: "%.3f", $0) } ?? "–", "wind") }
            }
            Section("Decision") {
                ChipSet(options: ["Arrest", "Release", "DRE call-out", "Medical"], selection: Binding(get: { [sf.decision] }, set: { s.payload.sfst.decision = $0.subtracting([sf.decision]).first ?? "" }))
                LabeledField(label: "Basis", text: $s.payload.sfst.decisionBasis, dictation: true)
            }
        }
        .navigationTitle("SFST / ARIDE")
    }
    func row(_ t: String, _ sub: String, _ icon: String) -> some View {
        Label { VStack(alignment: .leading) { Text(t); Text(sub).font(.footnote).foregroundStyle(.secondary) } } icon: { Image(systemName: icon).foregroundStyle(DN.accent) }
    }
}

struct TestPage<C: View>: View {
    let title: String, key: String
    @ViewBuilder var content: C
    var body: some View {
        ScrollView { VStack(alignment: .leading, spacing: 12) { InstructionCard(key: key); content }.padding() }
            .background(Color(uiColor: .systemGroupedBackground))
            .scrollEdgeEffectStyle(.soft, for: .top)
            .navigationTitle(title).navigationBarTitleDisplayMode(.inline)
    }
}

struct CuesView: View {
    @Binding var sfst: SFSTRecord
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Seed.data.cues, id: \.g) { g in
                    SectionTitle(text: g.g)
                    ContentCard { ChipSet(options: g.items, selection: $sfst.cues) }
                }
                SectionTitle(text: "Post-stop cues")
                ContentCard { ChipSet(options: Seed.data.postStop, selection: $sfst.cues) }
                ContentCard { LabeledField(label: "Driving narrative", text: $sfst.cueNotes, dictation: true) }
            }.padding()
        }.navigationTitle("Detection cues")
    }
}

struct ContactView: View {
    @Binding var sfst: SFSTRecord
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ContentCard { Text("Observations").font(.headline); ChipSet(options: ["Bloodshot eyes", "Watery eyes", "Fumbling fingers", "Slow response", "Inconsistent answers", "Containers / paraphernalia", "Soiled clothing", "Burn marks on lips/fingers", "Green tongue", "Track marks", "Profuse sweating"], selection: $sfst.contactObservations) }
                ContentCard { Text("Odors").font(.headline); ChipSet(options: ["Alcoholic beverage", "Burnt cannabis", "Raw cannabis", "Chemical", "Cover odor"], selection: $sfst.odors) }
                ContentCard { Text("Speech").font(.headline); ChipSet(options: ["Slurred", "Slow", "Rapid", "Mumbled", "Thick", "Normal"], selection: $sfst.speech) }
                ContentCard {
                    LabeledField(label: "Exit from vehicle", text: $sfst.exit, prompt: "Used door for support…")
                    LabeledField(label: "Contact notes", text: $sfst.contactNotes, dictation: true)
                }
            }.padding()
        }.navigationTitle("Personal contact")
    }
}

struct DriverInfoView: View {
    @Binding var subject: Subject
    @State private var scanning = false
    @State private var paste = ""
    var body: some View {
        Form {
            Section {
                Button { scanning = true } label: { Label("Scan license (PDF417) / VIN", systemImage: "barcode.viewfinder") }
                    .disabled(!BarcodeScannerView.isAvailable)
                if !BarcodeScannerView.isAvailable { Text("Scanner unavailable on this device. Paste AAMVA data below.").font(.footnote).foregroundStyle(.secondary) }
                TextField("Paste raw AAMVA text", text: $paste, axis: .vertical)
                Button("Parse") { AAMVA.apply(paste, to: &subject) }.disabled(paste.isEmpty)
            }
            Section("Driver") {
                TextField("First", text: $subject.first); TextField("Last", text: $subject.last)
                DatePicker("DOB", selection: Binding(get: { subject.dob ?? .now }, set: { subject.dob = $0 }), displayedComponents: .date)
                TextField("Sex", text: $subject.sex); TextField("License #", text: $subject.license); TextField("State", text: $subject.licenseState)
                TextField("Address", text: $subject.address, axis: .vertical); TextField("Height", text: $subject.height)
            }
            Section("Vehicle") {
                TextField("Plate", text: $subject.plate); TextField("Plate state", text: $subject.plateState)
                TextField("Year", text: $subject.year); TextField("Make", text: $subject.make); TextField("Model", text: $subject.model)
                TextField("Color", text: $subject.color); TextField("VIN", text: $subject.vin)
            }
        }
        .navigationTitle("Driver & vehicle")
        .sheet(isPresented: $scanning) {
            BarcodeScannerView { raw in
                if raw.count == 17, !raw.contains("\n") { subject.vin = raw } else { AAMVA.apply(raw, to: &subject) }
                scanning = false; Haptics.success()
            }.ignoresSafeArea()
        }
    }
}

struct PBTView: View {
    @Binding var sfst: SFSTRecord
    var body: some View {
        Form {
            TextField("Device", text: $sfst.pbtDevice); TextField("Serial", text: $sfst.pbtSerial)
            DatePicker("Time", selection: Binding(get: { sfst.pbtTime ?? .now }, set: { sfst.pbtTime = $0 }))
            Toggle("Refused", isOn: $sfst.pbtRefused)
            if !sfst.pbtRefused { NumberField(label: "Result (g/210L)", value: $sfst.pbtResult) }
            Section { Text("ARIDE note: a low BrAC with significant impairment indicates possible drug involvement — consider a DRE call-out.").font(.footnote).foregroundStyle(.secondary) }
        }.navigationTitle("PBT")
    }
}
