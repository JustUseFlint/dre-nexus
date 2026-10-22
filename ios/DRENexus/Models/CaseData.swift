import Foundation

// MARK: - Structured case payload. Mirrors the DEC Facesheet and the SFST/ARIDE report.

struct EyeClues: Codable, Hashable {
    var lackSmoothPursuit = false
    var distinctSustainedMaxDeviation = false
    var onsetPrior45 = false
    var onsetAngle: Double?
    var count: Int { [lackSmoothPursuit, distinctSustainedMaxDeviation, onsetPrior45].filter { $0 }.count }
}

enum Presence: String, Codable, CaseIterable, Identifiable { case absent, present; var id: String { rawValue } }

struct HGNTest: Codable, Hashable {
    var equalPupils: Bool?
    var equalTracking: Bool?
    var restingNystagmus: Presence?
    var eyewear: String = "None"
    var medicalNotes = ""
    var left = EyeClues()
    var right = EyeClues()
    var vgn: Presence?
    var inabilityToFollow = false
    var headMovement = false
    var eyelidTremors = false
    var notes = ""
    var done = false
    var totalClues: Int { left.count + right.count }
}

struct WATTest: Codable, Hashable {
    var cannotKeepBalance = false        // clue 1
    var startsTooSoon = false            // clue 2
    var stopsPass1 = false, stopsPass2 = false               // clue 3
    var missedHeelToePass1: Set<Int> = [], missedHeelToePass2: Set<Int> = []   // clue 4
    var stepsOffPass1: Set<Int> = [], stepsOffPass2: Set<Int> = []             // clue 5
    var armsPass1 = false, armsPass2 = false                 // clue 6
    var improperTurn = false             // clue 7
    var turnDescription = ""
    var wrongStepsPass1 = false, wrongStepsPass2 = false     // clue 8
    var stepsTakenPass1: Int?, stepsTakenPass2: Int?
    var cannotDoTest = false
    var cannotReason = ""
    var surface = "", footwear = "", injuries = ""
    var age: Int?, weight: Int?
    var extras: Set<String> = []
    var notes = ""
    var done = false
    var clues: [String: Bool] {
        ["Cannot keep balance": cannotKeepBalance, "Starts too soon": startsTooSoon,
         "Stops while walking": stopsPass1 || stopsPass2,
         "Misses heel-to-toe": !missedHeelToePass1.isEmpty || !missedHeelToePass2.isEmpty,
         "Steps off line": !stepsOffPass1.isEmpty || !stepsOffPass2.isEmpty,
         "Uses arms to balance": armsPass1 || armsPass2, "Improper turn": improperTurn,
         "Wrong number of steps": wrongStepsPass1 || wrongStepsPass2]
    }
    var totalClues: Int { clues.values.filter { $0 }.count }
}

struct OLSTest: Codable, Hashable {
    var leg: String?
    var sways = false, usesArms = false, hops = false
    var footDownCount = 0
    var countReached: Int?
    var footDownAt = ""
    var cannotDoTest = false
    var elapsed: TimeInterval = 0
    var extras: Set<String> = []
    var injuries = "", notes = ""
    var done = false
    var totalClues: Int { [sways, usesArms, hops, footDownCount > 0].filter { $0 }.count }
}

struct LOCTest: Codable, Hashable { var left: Presence?; var right: Presence?; var extras: Set<String> = []; var notes = ""; var done = false }

struct RombergTest: Codable, Hashable {
    var estimatedSeconds: Int?
    var actualElapsed: TimeInterval = 0
    var swayFrontBackInches: Double?
    var swaySideInches: Double?
    var swayDirections: Set<String> = []
    var eyelidTremors = false, bodyTremors = false, legTremors = false, muscleRigidity = false
    var openedEyes = false, didNotTiltHead = false, didNotFollowInstructions = false, lostBalance = false
    var statements = "", sounds = "", notes = ""
    var done = false
}

enum TouchLocation: String, Codable, CaseIterable, Identifiable {
    case tip = "Tip", pad = "Pad", nail = "Nail", bridge = "Bridge", upperLip = "Upper lip", leftCheek = "Left cheek", rightCheek = "Right cheek", missed = "Missed"
    var id: String { rawValue }
}

struct FTNAttempt: Codable, Hashable { var location: TouchLocation?; var flags: Set<String> = [] }

struct FTNTest: Codable, Hashable {
    static let order = ["L", "R", "L", "R", "R", "L"]
    var attempts: [FTNAttempt] = Array(repeating: FTNAttempt(), count: 6)
    var eyelidTremors = false, bodyTremors = false, sway = false
    var swayAmount = ""
    var didNotFollowInstructions = false, usedWrongHand = false, didNotTiltHead = false, openedEyes = false, usedPad = false
    var notes = ""
    var done = false
}

struct SFSTRecord: Codable, Hashable {
    var cues: Set<String> = []
    var cueNotes = ""
    var contactObservations: Set<String> = []
    var exit = "", odors: Set<String> = [], speech: Set<String> = [], contactNotes = ""
    var pbtDevice = "", pbtSerial = "", pbtTime: Date?, pbtResult: Double?, pbtRefused = false
    var hgn = HGNTest(), wat = WATTest(), ols = OLSTest(), loc = LOCTest(), romberg = RombergTest(), ftn = FTNTest()
    var arideSigns: Set<String> = []
    var decision = "", decisionBasis = ""
}

struct Subject: Codable, Hashable {
    var first = "", last = "", dob: Date?, sex = "", license = "", licenseState = "", address = ""
    var height = "", weight: Int?
    var plate = "", plateState = "", year = "", make = "", model = "", color = "", vin = ""
}

struct Pulse: Codable, Hashable { var bpm: Int?; var time: Date? }

struct DREStepState: Codable, Hashable { var startedAt: Date?; var completedAt: Date? }

struct DREEvaluation: Codable, Hashable {
    var steps: [Int: DREStepState] = [:]
    // 1
    var instrument = "", instrumentSerial = "", operatorName = "", breathResult1: Double?, breathResult2: Double?, breathTime1: Date?, breathTime2: Date?, breathRefused = false
    // 2
    var arrestingOfficer = "", arrestingAgency = "", arrestingBadge = "", drivingSummary = "", contactSummary = "", sfstSummary = "", statementsToOfficer = "", evidence = "", crash = false
    // 3
    var questions: [String: String] = [:]
    var speech: Set<String> = [], breathOdor: Set<String> = [], face: Set<String> = [], attitude = "", coordination = ""
    var correctiveLenses = "None", eyeAppearance: Set<String> = [], blindness = false
    var equalTracking: Bool?, equalPupils: Bool?, restingNystagmus: Presence?, hgnCheck: Presence?
    var pulse1 = Pulse()
    // 4
    var hgn = HGNTest(), vgn: Presence?, loc = LOCTest()
    // 5
    var romberg = RombergTest(), wat = WATTest(), olsLeft = OLSTest(), olsRight = OLSTest(), ftn = FTNTest()
    // 6
    var systolic: Int?, diastolic: Int?, temperatureF: Double?, pulse2 = Pulse()
    // 7
    var roomLeft: Double?, roomRight: Double?, darkLeft: Double?, darkRight: Double?, directLeft: Double?, directRight: Double?
    var reactionToLight = "", reboundDilation: Bool?, hippus: Bool?, nasal: Set<String> = [], oral: Set<String> = [], ingestionNotes = ""
    // 8
    var muscleTone = "", toneMap: [String: String] = [:], toneNotes = ""
    // 9
    var injectionSites: [String: String] = [:], injectionDescription = "", pulse3 = Pulse()
    // 10
    var mirandaGiven: Bool?, mirandaTime: Date?, waived: Bool?, drugsUsed = "", amount = "", whenUsed = "", whereUsed = "", route = "", admissions = ""
    var timeline: [TimelineEntry] = []
    // 11
    var impaired: Bool?, opinionCategories: Set<String> = [], opinionBasis = "", opinionTime: Date?
    // 12
    var specimen = "", specimenTime: Date?, collector = "", kitID = "", lab = "", custody: [CustodyEntry] = [], toxResults = ""
}

struct TimelineEntry: Codable, Hashable, Identifiable { var id = UUID(); var time: Date; var event: String }
struct CustodyEntry: Codable, Hashable, Identifiable { var id = UUID(); var at: Date; var from: String; var to: String; var purpose: String }
struct CaseNote: Codable, Hashable, Identifiable { var id = UUID(); var at: Date; var section: String; var text: String }

struct CasePayload: Codable, Hashable {
    var location = "", reason = "", stopTime: Date?
    var subject = Subject()
    var sfst = SFSTRecord()
    var dre = DREEvaluation()
    var notes: [CaseNote] = []
}
