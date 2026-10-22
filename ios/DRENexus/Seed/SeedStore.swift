import Foundation
import SwiftUI

/// Decoded, read-only reference data bundled as seed.json (generated from the shared seed in /web/data.js).
struct DrugCategory: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let short: String
    let color: String
    let desc: String
    var tint: Color { Color(hex: color) }
}

struct MatrixCell: Codable, Hashable {
    let t: String
    let v: [String]
    let alt: [String]?
    let fn: String?
}

struct MatrixRow: Codable, Hashable { let k: String; let label: String }

struct Substance: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let official: String
    let street: [String]
    let cat: String
    let sched: String
    let rx: String
    let use: String
    let dose: String
    let onset: String
    let duration: String
    let routes: String
    let abuse: Int
    let history: String
    let price: String
    let flags: [String: String]
    let type: String
}

struct CaseLaw: Codable, Identifiable, Hashable {
    var id: String { n }
    let n: String
    let c: String
    let ct: String
    let t: String
    let tags: [String]
    let s: String
}

struct CueGroup: Codable, Hashable { let g: String; let items: [String] }
struct Instruction: Codable, Hashable { let en: String; let es: String }
struct DREStepInfo: Codable, Hashable, Identifiable { var id: Int { n }; let n: Int; let k: String; let t: String; let d: String }
struct TrendSeries: Codable, Hashable { let seizures: [Int]; let arrests: [Int] }

struct Norms: Codable, Hashable {
    let pulse: [Double]; let sys: [Double]; let dia: [Double]; let temp: [Double]
    let room: [Double]; let dark: [Double]; let direct: [Double]
}

struct SeedData: Codable {
    let categories: [DrugCategory]
    let matrixRows: [MatrixRow]
    let matrix: [String: [String: MatrixCell]]
    let footnotes: [String: String]
    let general: [String: [String]]
    let onset: [String: String]
    let admin: [String: String]
    let overdose: [String: String]
    let substances: [Substance]
    let caseLaw: [CaseLaw]
    let cues: [CueGroup]
    let postStop: [String]
    let instructions: [String: Instruction]
    let steps: [DREStepInfo]
    let norms: Norms
    let trendsNote: String
    let years: [Int]
    let trends: [String: TrendSeries]
}

enum Seed {
    static let data: SeedData = {
        guard let url = Bundle.main.url(forResource: "seed", withExtension: "json"),
              let raw = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(SeedData.self, from: raw) else {
            fatalError("seed.json missing or invalid")
        }
        return decoded
    }()

    static var categories: [DrugCategory] { data.categories }
    static func category(_ id: String) -> DrugCategory {
        data.categories.first { $0.id == id }
            ?? DrugCategory(id: "NONE", name: "Not a DRE category", short: "Reference", color: "#8E8E93", desc: "Not impairing at normal doses.")
    }
}

extension Color {
    init(hex: String) {
        let s = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var v: UInt64 = 0
        Scanner(string: s).scanHexInt64(&v)
        self.init(red: Double((v >> 16) & 0xFF) / 255, green: Double((v >> 8) & 0xFF) / 255, blue: Double(v & 0xFF) / 255)
    }
}
