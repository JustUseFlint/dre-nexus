import SwiftData
import SwiftUI

@main
struct DRENexusApp: App {
    @StateObject private var lock = AppLock()
    @Environment(\.scenePhase) private var phase
    let container: ModelContainer = {
        let url = URL.applicationSupportDirectory.appending(path: "DRENexus.store")
        let config = ModelConfiguration(url: url, allowsSave: true)
        let c = try! ModelContainer(for: Investigation.self, MediaItem.self, configurations: config)
        // Store files inherit NSFileProtectionComplete from the entitlement; set explicitly as defense in depth.
        try? FileManager.default.setAttributes([.protectionKey: FileProtectionType.complete], ofItemAtPath: url.path())
        return c
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView()
                if !lock.unlocked && lock.enabled { LockScreen(lock: lock).transition(.opacity.combined(with: .scale(scale: 1.04))) }
            }
            .preferredColorScheme(.dark)
            .onChange(of: phase) { _, p in if p == .background { lock.lock() } }
        }
        .modelContainer(container)
    }
}

enum Role: String, CaseIterable, Identifiable { case officer = "Officer", dre = "DRE"; var id: String { rawValue } }

@Observable
final class CaseSession {
    let item: Investigation
    var payload: CasePayload { didSet { item.payload = payload } }
    init(_ item: Investigation) { self.item = item; self.payload = item.payload }
}
