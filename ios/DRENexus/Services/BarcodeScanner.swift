import SwiftUI
import VisionKit

/// Live PDF417 (license) / Code 39 (VIN) scanner using VisionKit's DataScannerViewController.
struct BarcodeScannerView: UIViewControllerRepresentable {
    var onScan: (String) -> Void
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let vc = DataScannerViewController(recognizedDataTypes: [.barcode(symbologies: [.pdf417, .code39, .code128, .qr])],
                                           qualityLevel: .accurate, recognizesMultipleItems: false,
                                           isHighFrameRateTrackingEnabled: false, isHighlightingEnabled: true)
        vc.delegate = context.coordinator
        try? vc.startScanning()
        return vc
    }
    func updateUIViewController(_ vc: DataScannerViewController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(onScan: onScan) }
    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onScan: (String) -> Void
        init(onScan: @escaping (String) -> Void) { self.onScan = onScan }
        func dataScanner(_ s: DataScannerViewController, didAdd items: [RecognizedItem], allItems: [RecognizedItem]) {
            for item in items { if case .barcode(let b) = item, let v = b.payloadStringValue { s.stopScanning(); onScan(v); return } }
        }
    }
    static var isAvailable: Bool { DataScannerViewController.isSupported && DataScannerViewController.isAvailable }
}

/// Parses AAMVA DL/ID card data elements into the case subject.
enum AAMVA {
    static func apply(_ raw: String, to s: inout Subject) {
        func field(_ code: String) -> String? {
            for line in raw.components(separatedBy: CharacterSet.newlines) {
                if let r = line.range(of: code), r.lowerBound == line.startIndex || line.hasPrefix("DL" + code) {
                    return String(line[r.upperBound...]).trimmingCharacters(in: .whitespaces)
                }
            }
            return nil
        }
        if let v = field("DCS") { s.last = v.capitalized }
        if let v = field("DAC") { s.first = v.capitalized }
        if let v = field("DAQ") { s.license = v }
        if let v = field("DAJ") { s.licenseState = v }
        if let v = field("DAG") { s.address = [v, field("DAI"), field("DAJ"), field("DAK").map { String($0.prefix(5)) }].compactMap { $0 }.joined(separator: ", ") }
        if let v = field("DBB"), v.count == 8 {
            let f = DateFormatter(); f.dateFormat = Int(v.prefix(4)).map { $0 > 1900 } == true ? "yyyyMMdd" : "MMddyyyy"
            s.dob = f.date(from: v)
        }
    }
}
