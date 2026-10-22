import SwiftUI
import UIKit

struct FacesheetView: View {
    let session: CaseSession
    @State private var shareURL: URL?
    var body: some View {
        let p = session.payload
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Facesheet.sections(item: session.item, p: p), id: \.0) { sec in
                    ContentCard {
                        Text(sec.0).font(.headline)
                        ForEach(sec.1, id: \.0) { kv in
                            HStack(alignment: .top) { Text(kv.0).foregroundStyle(.secondary).frame(width: 130, alignment: .leading); Text(kv.1.isEmpty ? "—" : kv.1) }.font(.callout)
                        }
                    }
                }
            }.padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Facesheet")
        .toolbar {
            ToolbarItem { Button { shareURL = try? PDFExporter.export(item: session.item, payload: p) } label: { Label("PDF", systemImage: "doc.richtext") } }
            ToolbarItem { Button { shareURL = try? JSONExport.write(item: session.item, payload: p) } label: { Label("JSON", systemImage: "curlybraces") } }
        }
        .sheet(item: $shareURL) { ShareSheet(items: [$0]) }
    }
}

enum Facesheet {
    static func f(_ d: Date?) -> String { d?.formatted(date: .abbreviated, time: .shortened) ?? "" }
    static func n(_ v: Double?) -> String { v.map { String(format: "%g", $0) } ?? "" }
    static func i(_ v: Int?) -> String { v.map(String.init) ?? "" }
    static func j(_ s: Set<String>) -> String { s.sorted().joined(separator: ", ") }
    static func sections(item: Investigation, p: CasePayload) -> [(String, [(String, String)])] {
        let d = p.dre, s = p.sfst, sub = p.subject
        let top = MatrixEngine.rank(MatrixEngine.indicators(for: p)).categories.prefix(3).map { "\($0.category.name) \(Int($0.score * 100))%" }.joined(separator: " · ")
        return [
            ("Case", [("Number", item.number), ("Title", item.title), ("Status", item.status.rawValue), ("Location", p.location), ("Stop time", f(p.stopTime)), ("Reason", p.reason)]),
            ("Subject", [("Name", "\(sub.last), \(sub.first)"), ("DOB", f(sub.dob)), ("License", "\(sub.license) \(sub.licenseState)"), ("Vehicle", "\(sub.year) \(sub.make) \(sub.model) \(sub.color)"), ("Plate", "\(sub.plate) \(sub.plateState)"), ("VIN", sub.vin)]),
            ("SFST / ARIDE", [("Cues", j(s.cues)), ("HGN", "\(s.hgn.totalClues)/6 · VGN \(s.hgn.vgn?.rawValue ?? "–")"), ("WAT", s.wat.cannotDoTest ? "Cannot do" : "\(s.wat.totalClues)/8"), ("OLS", s.ols.cannotDoTest ? "Cannot do" : "\(s.ols.totalClues)/4"), ("LOC", "L \(s.loc.left?.rawValue ?? "–") / R \(s.loc.right?.rawValue ?? "–")"), ("Romberg", s.romberg.estimatedSeconds.map { "\($0) s est." } ?? ""), ("FTN", s.ftn.attempts.map { $0.location?.rawValue ?? "–" }.joined(separator: ", ")), ("PBT", s.pbtRefused ? "Refused" : n(s.pbtResult)), ("Decision", s.decision)]),
            ("1–3 · Breath, interview, preliminary", [("Breath", d.breathRefused ? "Refused" : "\(n(d.breathResult1)) / \(n(d.breathResult2)) · \(d.instrument)"), ("Arresting officer", d.arrestingOfficer), ("Speech", j(d.speech)), ("Eyes", j(d.eyeAppearance)), ("Pulse 1", i(d.pulse1.bpm))]),
            ("4–5 · Eyes & divided attention", [("HGN", "L \(d.hgn.left.count) R \(d.hgn.right.count) · onset L \(n(d.hgn.left.onsetAngle))° R \(n(d.hgn.right.onsetAngle))°"), ("VGN", d.vgn?.rawValue ?? ""), ("LOC", "L \(d.loc.left?.rawValue ?? "–") / R \(d.loc.right?.rawValue ?? "–")"), ("Romberg", "\(i(d.romberg.estimatedSeconds)) s · sway \(n(d.romberg.swayFrontBackInches))/\(n(d.romberg.swaySideInches)) in"), ("WAT", "\(d.wat.totalClues)/8"), ("OLS L / R", "\(d.olsLeft.totalClues)/4 · \(d.olsRight.totalClues)/4"), ("FTN", d.ftn.attempts.map { $0.location?.rawValue ?? "–" }.joined(separator: ", "))]),
            ("6–9 · Clinical", [("BP", "\(i(d.systolic))/\(i(d.diastolic))"), ("Temp", n(d.temperatureF)), ("Pulse 2 / 3", "\(i(d.pulse2.bpm)) / \(i(d.pulse3.bpm))"), ("Room L/R", "\(n(d.roomLeft)) / \(n(d.roomRight))"), ("Dark L/R", "\(n(d.darkLeft)) / \(n(d.darkRight))"), ("Direct L/R", "\(n(d.directLeft)) / \(n(d.directRight))"), ("Reaction", d.reactionToLight), ("Muscle tone", d.muscleTone), ("Injection sites", d.injectionSites.map { "\($0.key): \($0.value)" }.sorted().joined(separator: ", "))]),
            ("10–12 · Statements, opinion, toxicology", [("Miranda", d.mirandaGiven == true ? "Given \(f(d.mirandaTime))" : ""), ("Admissions", d.admissions), ("Opinion", d.impaired == true ? "Impaired: \(j(d.opinionCategories))" : d.impaired == false ? "Not impaired" : ""), ("Basis", d.opinionBasis), ("Matrix suggestion", top), ("Specimen", "\(d.specimen) \(f(d.specimenTime)) · \(d.kitID)"), ("Custody", d.custody.map { "\(f($0.at)) \($0.from)→\($0.to)" }.joined(separator: "; "))]),
            ("Notes", p.notes.map { ("\($0.section) \(f($0.at))", $0.text) })
        ]
    }
}

enum PDFExporter {
    static func export(item: Investigation, payload p: CasePayload) throws -> URL {
        let page = CGRect(x: 0, y: 0, width: 612, height: 792), margin: CGFloat = 40
        let url = URL.temporaryDirectory.appending(path: "\(item.number)-Facesheet.pdf")
        let fmt = UIGraphicsPDFRendererFormat()
        fmt.documentInfo = [kCGPDFContextTitle as String: "DRE Nexus Facesheet \(item.number)", kCGPDFContextCreator as String: "DRE Nexus"]
        let r = UIGraphicsPDFRenderer(bounds: page, format: fmt)
        try r.writePDF(to: url) { ctx in
            var y: CGFloat = 0
            func newPage() {
                ctx.beginPage(); y = margin
                ("DRE NEXUS · DRUG INFLUENCE EVALUATION FACESHEET  ·  \(item.number)" as NSString).draw(at: CGPoint(x: margin, y: 18), withAttributes: [.font: UIFont.systemFont(ofSize: 8, weight: .semibold), .foregroundColor: UIColor.gray])
                y = margin + 6
            }
            func draw(_ s: String, font: UIFont, color: UIColor = .black, indent: CGFloat = 0, width: CGFloat? = nil) -> CGFloat {
                let w = width ?? (page.width - margin * 2 - indent)
                let a: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
                let h = (s as NSString).boundingRect(with: CGSize(width: w, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: a, context: nil).height
                return ceil(h)
            }
            newPage()
            ("Facesheet" as NSString).draw(at: CGPoint(x: margin, y: y), withAttributes: [.font: UIFont.systemFont(ofSize: 22, weight: .bold)]); y += 34
            for (title, rows) in Facesheet.sections(item: item, p: p) {
                if y > page.height - 100 { newPage() }
                UIColor(red: 0.3, green: 0.55, blue: 1, alpha: 0.12).setFill()
                UIBezierPath(roundedRect: CGRect(x: margin, y: y, width: page.width - margin * 2, height: 20), cornerRadius: 4).fill()
                (title.uppercased() as NSString).draw(at: CGPoint(x: margin + 6, y: y + 4), withAttributes: [.font: UIFont.systemFont(ofSize: 9, weight: .bold)]); y += 26
                for (k, v) in rows {
                    let vf = UIFont.systemFont(ofSize: 9.5), vw = page.width - margin * 2 - 140
                    let h = max(14, draw(v, font: vf, width: vw) + 4)
                    if y + h > page.height - margin { newPage() }
                    (k as NSString).draw(in: CGRect(x: margin + 6, y: y, width: 128, height: h), withAttributes: [.font: UIFont.systemFont(ofSize: 9, weight: .semibold), .foregroundColor: UIColor.darkGray])
                    ((v.isEmpty ? "—" : v) as NSString).draw(in: CGRect(x: margin + 140, y: y, width: vw, height: h), withAttributes: [.font: vf])
                    y += h
                }
                y += 10
            }
            for m in item.media where !m.isVideo {
                guard let img = UIImage(data: m.annotatedData ?? m.data) else { continue }
                newPage()
                ("Photo · \(m.section) · \(m.created.formatted())" as NSString).draw(at: CGPoint(x: margin, y: y), withAttributes: [.font: UIFont.systemFont(ofSize: 10, weight: .semibold)])
                let maxR = CGRect(x: margin, y: y + 20, width: page.width - margin * 2, height: page.height - y - 20 - margin)
                let sc = min(maxR.width / img.size.width, maxR.height / img.size.height)
                img.draw(in: CGRect(x: maxR.minX, y: maxR.minY, width: img.size.width * sc, height: img.size.height * sc))
            }
            newPage()
            ("Certification: I certify that the foregoing is a true and accurate record of my observations.\n\nEvaluator: ____________________________   Date: ____________" as NSString)
                .draw(in: CGRect(x: margin, y: y, width: page.width - margin * 2, height: 120), withAttributes: [.font: UIFont.systemFont(ofSize: 11)])
        }
        try FileManager.default.setAttributes([.protectionKey: FileProtectionType.complete], ofItemAtPath: url.path())
        return url
    }
}

enum JSONExport {
    struct Envelope: Codable { let app: String; let version: Int; let exported: Date; let number: String; let title: String; let status: String; let payload: CasePayload }
    static func write(item: Investigation, payload: CasePayload) throws -> URL {
        let e = JSONEncoder(); e.outputFormatting = [.prettyPrinted, .sortedKeys]; e.dateEncodingStrategy = .iso8601
        let data = try e.encode(Envelope(app: "DRE Nexus", version: 1, exported: .now, number: item.number, title: item.title, status: item.status.rawValue, payload: payload))
        let url = URL.temporaryDirectory.appending(path: "\(item.number).json")
        try data.write(to: url, options: [.atomic, .completeFileProtection])
        return url
    }
}
