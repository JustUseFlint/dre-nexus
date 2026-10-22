import PhotosUI
import UniformTypeIdentifiers
import SwiftData
import SwiftUI

struct CaseRow: View {
    let item: Investigation
    var body: some View {
        let p = item.payload
        HStack(spacing: 12) {
            Image(systemName: "folder.fill").font(.title3).foregroundStyle(DN.accent).frame(width: 44, height: 44).background(DN.accent.opacity(0.14), in: .rect(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title).font(.headline).foregroundStyle(.primary).lineLimit(1)
                Text("\(item.number) · \(item.updated.formatted(date: .abbreviated, time: .shortened)) · DRE \(p.dre.steps.values.filter { $0.completedAt != nil }.count)/12").font(.footnote).foregroundStyle(.secondary)
            }
            Spacer()
            Text(item.status.rawValue).font(.caption.weight(.semibold)).padding(.horizontal, 8).padding(.vertical, 4).background(.quaternary, in: .capsule)
        }
        .padding(14).background(DN.card, in: .rect(cornerRadius: 20, style: .continuous))
    }
}

struct CasesView: View {
    @Query(sort: \Investigation.updated, order: .reverse) private var cases: [Investigation]
    @Environment(\.modelContext) private var ctx
    @State private var query = ""
    @State private var status: CaseStatus? = nil
    @State private var opened: Investigation?
    var filtered: [Investigation] {
        cases.filter { c in (status == nil || c.status == status) && (query.isEmpty || "\(c.title) \(c.number) \(c.payload.subject.last) \(c.payload.subject.plate)".localizedCaseInsensitiveContains(query)) }
    }
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                Picker("Status", selection: $status) { Text("All").tag(CaseStatus?.none); ForEach(CaseStatus.allCases) { Text($0.rawValue).tag(CaseStatus?.some($0)) } }.pickerStyle(.segmented)
                ForEach(filtered) { c in
                    NavigationLink { CaseDetailView(item: c) } label: { CaseRow(item: c) }.buttonStyle(PressScale())
                        .contextMenu { Button("Delete", systemImage: "trash", role: .destructive) { ctx.delete(c) } }
                }
                if filtered.isEmpty { ContentUnavailableView("No cases", systemImage: "folder", description: Text("Start a new investigation.")) }
            }
            .padding()
        }
        .searchable(text: $query, prompt: "Name, case #, plate")
        .navigationTitle("Cases")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("New", systemImage: "plus") {
                    let n = Investigation(number: String(format: "DN-%d-%03d", Calendar.current.component(.year, from: .now), cases.count + 1), title: "New investigation")
                    ctx.insert(n); opened = n; Haptics.success()
                }
            }
        }
        .navigationDestination(item: $opened) { CaseDetailView(item: $0) }
    }
}

struct CaseDetailView: View {
    let item: Investigation
    @State private var session: CaseSession
    @State private var showMatrix = false
    @State private var shareURL: URL?
    @AppStorage("role") private var role = Role.dre.rawValue
    @Namespace private var glassNS
    init(item: Investigation) { self.item = item; _session = State(initialValue: CaseSession(item)) }
    var body: some View {
        @Bindable var s = session
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(item.number).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                TextField("Case title", text: Binding(get: { item.title }, set: { item.title = $0 })).font(.title.bold())
                Picker("Status", selection: Binding(get: { item.status }, set: { item.status = $0 })) { ForEach(CaseStatus.allCases) { Text($0.rawValue).tag($0) } }.pickerStyle(.segmented)
                HStack(spacing: 12) {
                    NavigationLink { SFSTHubView(session: session) } label: { progressCard("SFST / ARIDE", "HGN \(s.payload.sfst.hgn.totalClues)/6 · WAT \(s.payload.sfst.wat.totalClues)/8 · OLS \(s.payload.sfst.ols.totalClues)/4", "figure.walk") }
                    NavigationLink { if role == Role.dre.rawValue { DREWizardView(session: session) } else { ContentUnavailableView("DRE role required", systemImage: "lock.fill", description: Text("Switch role in Settings.")) } } label: {
                        progressCard("DRE 12-step", "\(s.payload.dre.steps.values.filter { $0.completedAt != nil }.count)/12 steps", "eye")
                    }
                }
                .buttonStyle(PressScale()).materialize()
                ContentCard {
                    NavigationLink { FacesheetView(session: session) } label: { Label("Facesheet & report", systemImage: "doc.richtext") }
                    Divider()
                    Button { shareURL = try? PDFExporter.export(item: item, payload: s.payload) } label: { Label("Export court-ready PDF", systemImage: "square.and.arrow.up") }
                    Divider()
                    Button { shareURL = try? JSONExport.write(item: item, payload: s.payload) } label: { Label("Export JSON", systemImage: "curlybraces") }
                }
                SectionTitle(text: "Incident")
                ContentCard {
                    LabeledField(label: "Location", text: $s.payload.location, prompt: "Road, mile marker, city")
                    LabeledField(label: "Reason for contact", text: $s.payload.reason)
                    DatePicker("Time of stop", selection: Binding(get: { s.payload.stopTime ?? .now }, set: { s.payload.stopTime = $0 }))
                }
                SectionTitle(text: "Photos & video")
                MediaStrip(item: item, section: "case")
                SectionTitle(text: "Timestamped notes")
                NotesCard(notes: $s.payload.notes, section: "case")
            }
            .padding()
            .padding(.bottom, 80)
        }
        .scrollEdgeEffectStyle(.soft, for: .top)
        .navigationTitle(item.title).navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottomTrailing) { MatrixFAB(showMatrix: $showMatrix, ns: glassNS) }
        .sheet(isPresented: $showMatrix) { LiveMatrixSheet(payload: s.payload) }
        .sheet(item: $shareURL) { url in ShareSheet(items: [url]) }
    }
    func progressCard(_ t: String, _ sub: String, _ icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon).font(.title2).foregroundStyle(DN.accent)
            Text(t).font(.headline).foregroundStyle(.primary)
            Text(sub).font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.leading)
        }
        .padding(14).frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading)
        .background(DN.card, in: .rect(cornerRadius: 20))
    }
}

extension URL: @retroactive Identifiable { public var id: String { absoluteString } }

/// Floating Liquid Glass Matrix button that morphs into its sheet's trigger.
struct MatrixFAB: View {
    @Binding var showMatrix: Bool
    let ns: Namespace.ID
    var body: some View {
        GlassEffectContainer {
            Button { showMatrix = true; Haptics.tap() } label: { Label("Matrix", systemImage: "tablecells").font(.headline).padding(.horizontal, 6).frame(minHeight: 50) }
                .buttonStyle(.glass)
                .glassEffectID("matrix", in: ns)
        }
        .padding(.trailing, 18).padding(.bottom, 12)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController { UIActivityViewController(activityItems: items, applicationActivities: nil) }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}

struct NotesCard: View {
    @Binding var notes: [CaseNote]
    let section: String
    @State private var draft = ""
    var body: some View {
        ContentCard {
            ForEach(notes.filter { section == "case" || $0.section == section }.sorted { $0.at < $1.at }) { n in
                VStack(alignment: .leading, spacing: 2) { Text(n.at.formatted(date: .omitted, time: .shortened)).font(.caption.monospacedDigit()).foregroundStyle(.secondary); Text(n.text) }
                    .padding(.leading, 10).overlay(alignment: .leading) { Capsule().fill(DN.accent).frame(width: 3) }
                    .transition(.blurReplace)
            }
            HStack {
                TextField("Add a note…", text: $draft, axis: .vertical).padding(12).background(Color(uiColor: .tertiarySystemFill), in: .rect(cornerRadius: 12))
                DictationButton(text: $draft)
                Button("Add") { guard !draft.isEmpty else { return }; withAnimation(DN.spring) { notes.append(CaseNote(at: .now, section: section, text: draft)) }; draft = ""; Haptics.tap() }
                    .buttonStyle(.glassProminent)
            }
        }
    }
}

struct MediaStrip: View {
    let item: Investigation
    let section: String
    @Environment(\.modelContext) private var ctx
    @State private var picks: [PhotosPickerItem] = []
    @State private var showCamera = false
    @State private var marking: MediaItem?
    var media: [MediaItem] { item.media.filter { section == "case" || $0.section == section }.sorted { $0.created < $1.created } }
    var body: some View {
        ContentCard {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 3), spacing: 6) {
                ForEach(media) { m in
                    if let img = UIImage(data: m.annotatedData ?? m.data) {
                        Image(uiImage: img).resizable().scaledToFill().frame(height: 100).clipShape(.rect(cornerRadius: 12))
                            .onTapGesture { marking = m }
                    } else { Label("Video", systemImage: "video.fill").frame(height: 100) }
                }
            }
            HStack {
                Button("Camera", systemImage: "camera.fill") { showCamera = true }.buttonStyle(.glass)
                PhotosPicker(selection: $picks, matching: .any(of: [.images, .videos])) { Label("Library", systemImage: "photo.on.rectangle") }.buttonStyle(.glass)
            }
        }
        .onChange(of: picks) { _, new in
            Task { for p in new { if let d = try? await p.loadTransferable(type: Data.self) { let m = MediaItem(section: section, data: d, isVideo: p.supportedContentTypes.contains(.movie)); item.media.append(m) } }; picks = [] }
        }
        .fullScreenCover(isPresented: $showCamera) { CameraPicker { d in item.media.append(MediaItem(section: section, data: d)) } }
        .fullScreenCover(item: $marking) { m in if let img = UIImage(data: m.data) { PhotoMarkupView(image: img) { m.annotatedData = $0 } } }
    }
}

struct CameraPicker: UIViewControllerRepresentable {
    var onCapture: (Data) -> Void
    @Environment(\.dismiss) private var dismiss
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let p = UIImagePickerController(); p.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        p.mediaTypes = ["public.image", "public.movie"]; p.delegate = context.coordinator; return p
    }
    func updateUIViewController(_ vc: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coord { Coord(self) }
    final class Coord: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        init(_ p: CameraPicker) { parent = p }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let img = info[.originalImage] as? UIImage, let d = img.jpegData(compressionQuality: 0.85) { parent.onCapture(d) }
            else if let url = info[.mediaURL] as? URL, let d = try? Data(contentsOf: url) { parent.onCapture(d) }
            parent.dismiss()
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { parent.dismiss() }
    }
}
