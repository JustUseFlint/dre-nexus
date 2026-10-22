import Foundation

/// Ranks DRE categories against observed indicators using the seeded Matrix, including footnote alternates.
struct MatrixEngine {
    enum CellMatch: String { case hit, alt, miss }
    struct CategoryScore: Identifiable { let category: DrugCategory; let score: Double; let detail: [String: CellMatch]; var id: String { category.id } }
    struct SubstanceScore: Identifiable { let substance: Substance; let score: Double; let reasons: [String]; var id: String { substance.id } }

    static func rank(_ indicators: [String: String]) -> (categories: [CategoryScore], substances: [SubstanceScore]) {
        let keys = indicators.keys.filter { !(indicators[$0] ?? "").isEmpty }
        let cats: [CategoryScore] = Seed.categories.map { cat in
            var s = 0.0; var detail: [String: CellMatch] = [:]
            for k in keys {
                guard let cell = Seed.data.matrix[cat.id]?[k], let v = indicators[k] else { continue }
                if cell.v.contains(v) { s += 1; detail[k] = .hit }
                else if cell.alt?.contains(v) == true { s += 0.6; detail[k] = .alt }
                else { detail[k] = .miss }
            }
            return CategoryScore(category: cat, score: keys.isEmpty ? 0 : s / Double(keys.count), detail: detail)
        }.sorted { $0.score > $1.score }
        let subs: [SubstanceScore] = Seed.data.substances.filter { $0.cat != "NONE" }.compactMap { sub in
            guard let base = cats.first(where: { $0.category.id == sub.cat }) else { return nil }
            var score = base.score; var why: [String] = []
            for (k, text) in sub.flags {
                let want: String = k == "bp" ? (text.contains("UP") ? "up" : "down") : (["pupil": "dilated", "pulse": "up", "rtl": "slow"][k] ?? "")
                if indicators[k] == want { score += 0.08; why.append(text) }
                else if k == "bp", let v = indicators[k], v != want { score -= 0.05 }
            }
            return SubstanceScore(substance: sub, score: min(1, score), reasons: why)
        }.sorted { $0.score > $1.score }
        return (cats, subs)
    }

    /// Derives Matrix indicators from a case (DRE data first, SFST as fallback).
    static func indicators(for p: CasePayload) -> [String: String] {
        let d = p.dre, n = Seed.data.norms
        var ind: [String: String] = [:]
        let hgn = d.hgn.totalClues > 0 || d.steps[4]?.startedAt != nil ? d.hgn : p.sfst.hgn
        if hgn.done || hgn.totalClues > 0 || d.steps[4]?.startedAt != nil { ind["hgn"] = hgn.totalClues > 0 ? "present" : "none" }
        if let v = d.vgn ?? d.hgn.vgn ?? p.sfst.hgn.vgn { ind["vgn"] = v == .present ? "present" : "none" }
        let loc = (d.loc.left != nil || d.loc.right != nil) ? d.loc : p.sfst.loc
        if loc.left != nil || loc.right != nil { ind["loc"] = (loc.left == .present || loc.right == .present) ? "present" : "none" }
        func avg(_ a: [Double?]) -> Double? { let v = a.compactMap { $0 }; return v.isEmpty ? nil : v.reduce(0, +) / Double(v.count) }
        let room = avg([d.roomLeft, d.roomRight]), dark = avg([d.darkLeft, d.darkRight]), direct = avg([d.directLeft, d.directRight])
        if room != nil || dark != nil || direct != nil {
            if (room.map { $0 < n.room[0] } ?? false) || (direct.map { $0 < n.direct[0] } ?? false) { ind["pupil"] = "constricted" }
            else if (room.map { $0 > n.room[1] } ?? false) || (dark.map { $0 > n.dark[1] } ?? false) || (direct.map { $0 > n.direct[1] } ?? false) { ind["pupil"] = "dilated" }
            else { ind["pupil"] = "normal" }
        }
        if !d.reactionToLight.isEmpty { ind["rtl"] = d.reactionToLight }
        if let p = avg([d.pulse1.bpm, d.pulse2.bpm, d.pulse3.bpm].map { $0.map(Double.init) }) { ind["pulse"] = p > n.pulse[1] ? "up" : p < n.pulse[0] ? "down" : "normal" }
        if let s = d.systolic, let di = d.diastolic {
            ind["bp"] = (Double(s) > n.sys[1] || Double(di) > n.dia[1]) ? "up" : (Double(s) < n.sys[0] && Double(di) < n.dia[0]) ? "down" : "normal"
        }
        if let t = d.temperatureF { ind["temp"] = t > n.temp[1] ? "up" : t < n.temp[0] ? "down" : "normal" }
        if !d.muscleTone.isEmpty { ind["tone"] = d.muscleTone }
        return ind
    }
}
