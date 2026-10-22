import AVFoundation
import Speech
import SwiftUI

/// English/Spanish audio instructions via AVSpeechSynthesizer.
@MainActor
final class InstructionSpeaker: ObservableObject {
    static let shared = InstructionSpeaker()
    private let synth = AVSpeechSynthesizer()
    func speak(_ key: String, spanish: Bool) {
        guard let ins = Seed.data.instructions[key] else { return }
        synth.stopSpeaking(at: .immediate)
        let u = AVSpeechUtterance(string: spanish ? ins.es : ins.en)
        u.voice = AVSpeechSynthesisVoice(language: spanish ? "es-US" : "en-US")
        u.rate = AVSpeechUtteranceDefaultSpeechRate * 0.95
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        synth.speak(u)
    }
    func stop() { synth.stopSpeaking(at: .immediate) }
}

/// On-device dictation (Speech framework) appended into a bound text field.
@MainActor
final class Dictation: ObservableObject {
    @Published var isRecording = false
    private let engine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    func toggle(spanish: Bool, onText: @escaping (String) -> Void) {
        if isRecording { stop(); return }
        SFSpeechRecognizer.requestAuthorization { status in
            Task { @MainActor in
                guard status == .authorized else { return }
                self.start(spanish: spanish, onText: onText)
            }
        }
    }

    private func start(spanish: Bool, onText: @escaping (String) -> Void) {
        guard let rec = SFSpeechRecognizer(locale: Locale(identifier: spanish ? "es-US" : "en-US")), rec.isAvailable else { return }
        let req = SFSpeechAudioBufferRecognitionRequest()
        req.shouldReportPartialResults = false
        if rec.supportsOnDeviceRecognition { req.requiresOnDeviceRecognition = true }
        request = req
        try? AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement, options: .duckOthers)
        try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        let input = engine.inputNode
        input.installTap(onBus: 0, bufferSize: 1024, format: input.outputFormat(forBus: 0)) { buf, _ in req.append(buf) }
        engine.prepare()
        try? engine.start()
        isRecording = true
        task = rec.recognitionTask(with: req) { result, error in
            Task { @MainActor in
                if let r = result, r.isFinal { onText(r.bestTranscription.formattedString); self.stop() }
                if error != nil { self.stop() }
            }
        }
    }

    func stop() {
        engine.stop(); engine.inputNode.removeTap(onBus: 0)
        request?.endAudio(); task?.cancel(); task = nil; request = nil
        isRecording = false
    }
}

struct DictationButton: View {
    @Binding var text: String
    @StateObject private var dictation = Dictation()
    @AppStorage("spanish") private var spanish = false
    var body: some View {
        Button {
            dictation.toggle(spanish: spanish) { t in text = text.isEmpty ? t : text + " " + t }
        } label: {
            Label(dictation.isRecording ? "Stop" : "Dictate", systemImage: dictation.isRecording ? "stop.fill" : "mic.fill")
                .font(.footnote.weight(.semibold))
                .symbolEffect(.pulse, isActive: dictation.isRecording)
        }
        .buttonStyle(.glass)
        .controlSize(.small)
    }
}

struct InstructionCard: View {
    let key: String
    @AppStorage("spanish") private var spanish = false
    var body: some View {
        ContentCard {
            HStack {
                Text("Instructions").font(.headline)
                Spacer()
                Picker("Language", selection: $spanish) { Text("EN").tag(false); Text("ES").tag(true) }
                    .pickerStyle(.segmented).frame(width: 120)
            }
            if let ins = Seed.data.instructions[key] {
                Text(spanish ? ins.es : ins.en).font(.callout).foregroundStyle(.secondary)
                    .contentTransition(.opacity).animation(DN.snappy, value: spanish)
            }
            Button { InstructionSpeaker.shared.speak(key, spanish: spanish) } label: {
                Label("Play audio instructions", systemImage: "speaker.wave.2.fill").frame(maxWidth: .infinity, minHeight: 44)
            }.buttonStyle(.glass)
        }
    }
}
