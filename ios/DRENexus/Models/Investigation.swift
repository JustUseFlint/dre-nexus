import Foundation
import SwiftData

enum CaseStatus: String, Codable, CaseIterable, Identifiable {
    case open = "Open", review = "In review", closed = "Closed"
    var id: String { rawValue }
}

@Model
final class Investigation {
    @Attribute(.unique) var id: UUID
    var number: String
    var title: String
    var created: Date
    var updated: Date
    var statusRaw: String
    /// Structured case content, JSON-encoded so the Facesheet structure can evolve without migrations.
    var payloadData: Data
    @Relationship(deleteRule: .cascade) var media: [MediaItem] = []

    init(number: String, title: String) {
        self.id = UUID()
        self.number = number
        self.title = title
        self.created = .now
        self.updated = .now
        self.statusRaw = CaseStatus.open.rawValue
        self.payloadData = (try? JSONEncoder().encode(CasePayload())) ?? Data()
    }

    var status: CaseStatus {
        get { CaseStatus(rawValue: statusRaw) ?? .open }
        set { statusRaw = newValue.rawValue }
    }

    var payload: CasePayload {
        get { (try? JSONDecoder().decode(CasePayload.self, from: payloadData)) ?? CasePayload() }
        set { payloadData = (try? JSONEncoder().encode(newValue)) ?? payloadData; updated = .now }
    }
}

@Model
final class MediaItem {
    var id: UUID
    var created: Date
    var section: String
    var caption: String
    var isVideo: Bool
    @Attribute(.externalStorage) var data: Data
    @Attribute(.externalStorage) var annotatedData: Data?

    init(section: String, data: Data, isVideo: Bool = false) {
        self.id = UUID(); self.created = .now; self.section = section; self.caption = ""; self.isVideo = isVideo; self.data = data
    }
}
