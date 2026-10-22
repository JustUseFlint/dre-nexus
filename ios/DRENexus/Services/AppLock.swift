import LocalAuthentication
import SwiftUI

@MainActor
final class AppLock: ObservableObject {
    @Published var unlocked = false
    @AppStorage("lockEnabled") var enabled = true
    func unlock() {
        guard enabled else { unlocked = true; return }
        let ctx = LAContext()
        var err: NSError?
        let policy: LAPolicy = ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &err) ? .deviceOwnerAuthenticationWithBiometrics : .deviceOwnerAuthentication
        ctx.evaluatePolicy(policy, localizedReason: "Unlock case data") { ok, _ in
            Task { @MainActor in withAnimation(DN.spring) { self.unlocked = ok } }
        }
    }
    func lock() { if enabled { unlocked = false } }
}

struct LockScreen: View {
    @ObservedObject var lock: AppLock
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.shield.fill").font(.system(size: 56)).foregroundStyle(DN.accent).symbolEffect(.bounce, value: lock.unlocked)
            Text("DRE Nexus").font(.largeTitle.bold())
            Text("Case data is encrypted on this device.").foregroundStyle(.secondary)
            Button { lock.unlock() } label: { Label("Unlock with Face ID", systemImage: "faceid").frame(minWidth: 220, minHeight: 50) }
                .buttonStyle(.glassProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .onAppear { lock.unlock() }
    }
}
