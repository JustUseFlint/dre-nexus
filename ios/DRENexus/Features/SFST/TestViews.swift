import SwiftUI

// MARK: Reusable test components. Each binds to a test struct so SFST and DRE Step 4/5 share one implementation.

struct HGNTestView: View {
    @Binding var test: HGNTest
    var showAngles = false
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            FloatingCounter(count: test.totalClues, total: 6, threshold: 4).padding(.horizontal, -16)
            SectionTitle(text: "Pre-checks")
            ContentCard {
                Picker("Eyewear", selection: $test.eyewear) { ForEach(["None", "Removed glasses", "Contacts"], id: \.self) { Text($0) } }.pickerStyle(.segmented)
                triState("Equal pupil size", $test.equalPupils)
                triState("Equal tracking", $test.equalTracking)
                PresenceSegment(title: "Resting nystagmus", value: $test.restingNystagmus)
                LabeledField(label: "Medical conditions / injuries", text: $test.medicalNotes)
            }
            SectionTitle(text: "Clues")
            eye("Left eye", $test.left)
            eye("Right eye", $test.right)
            SectionTitle(text: "Vertical gaze nystagmus")
            ContentCard { PresenceSegment(title: "VGN", value: $test.vgn) }
            SectionTitle(text: "Additional observations")
            ContentCard {
                ClueToggle(title: "Inability to follow the stimulus", isOn: $test.inabilityToFollow)
                ClueToggle(title: "Head movement / jerks", isOn: $test.headMovement)
                ClueToggle(title: "Eyelid tremors", isOn: $test.eyelidTremors)
                LabeledField(label: "Notes", text: $test.notes, dictation: true)
            }
        }
    }
    func eye(_ t: String, _ e: Binding<EyeClues>) -> some View {
        ContentCard {
            Text(t).font(.headline)
            ClueToggle(title: "Lack of smooth pursuit", isOn: e.lackSmoothPursuit)
            ClueToggle(title: "Distinct & sustained nystagmus at maximum deviation", isOn: e.distinctSustainedMaxDeviation)
            ClueToggle(title: "Onset of nystagmus prior to 45°", isOn: e.onsetPrior45)
            if showAngles { NumberField(label: "Angle of onset", value: e.onsetAngle, unit: "°") }
        }
    }
    func triState(_ t: String, _ b: Binding<Bool?>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(t).font(.footnote).foregroundStyle(.secondary)
            Picker(t, selection: b) { Text("–").tag(Bool?.none); Text("Yes").tag(Bool?.some(true)); Text("No").tag(Bool?.some(false)) }.pickerStyle(.segmented)
        }
    }
}

struct WATTestView: View {
    @Binding var test: WATTest
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if test.cannotDoTest { Label("Cannot do the test (documented)", systemImage: "xmark.octagon.fill").foregroundStyle(DN.bad).font(.headline) }
            else { FloatingCounter(count: test.totalClues, total: 8, threshold: 2).padding(.horizontal, -16) }
            ContentCard { WalkTurnDiagram(pass1: test.missedHeelToePass1.union(test.stepsOffPass1), pass2: test.missedHeelToePass2.union(test.stepsOffPass2), improperTurn: test.improperTurn) }
            SectionTitle(text: "Instruction stage")
            ContentCard {
                ClueToggle(title: "Cannot keep balance during instructions", subtitle: "Clue 1", isOn: $test.cannotKeepBalance)
                ClueToggle(title: "Starts too soon", subtitle: "Clue 2", isOn: $test.startsTooSoon)
            }
            SectionTitle(text: "Walking stage · pass 1")
            pass($test.stopsPass1, $test.missedHeelToePass1, $test.stepsOffPass1, $test.armsPass1, $test.wrongStepsPass1, $test.stepsTakenPass1)
            SectionTitle(text: "Walking stage · pass 2")
            pass($test.stopsPass2, $test.missedHeelToePass2, $test.stepsOffPass2, $test.armsPass2, $test.wrongStepsPass2, $test.stepsTakenPass2)
            SectionTitle(text: "Turn")
            ContentCard { ClueToggle(title: "Improper turn", subtitle: "Clue 7", isOn: $test.improperTurn); LabeledField(label: "Describe turn", text: $test.turnDescription) }
            SectionTitle(text: "Status & conditions")
            ContentCard {
                ClueToggle(title: "Cannot do the test", subtitle: "Off line 3+ times, danger of falling, or refuses", isOn: $test.cannotDoTest)
                LabeledField(label: "Reason", text: $test.cannotReason)
                LabeledField(label: "Surface", text: $test.surface, prompt: "Dry, level pavement")
                LabeledField(label: "Footwear", text: $test.footwear)
                HStack { IntField(label: "Age", value: $test.age); IntField(label: "Weight", value: $test.weight, unit: "lb") }
                LabeledField(label: "Injuries / limitations", text: $test.injuries)
                ChipSet(options: ["Counted wrong", "Did not watch feet", "Swayed", "Raised arms during instructions", "Stumbled", "Fell"], selection: $test.extras)
                LabeledField(label: "Notes", text: $test.notes, dictation: true)
            }
        }
    }
    func pass(_ stops: Binding<Bool>, _ ht: Binding<Set<Int>>, _ off: Binding<Set<Int>>, _ arms: Binding<Bool>, _ wrong: Binding<Bool>, _ taken: Binding<Int?>) -> some View {
        ContentCard {
            ClueToggle(title: "Stops while walking", subtitle: "Clue 3", isOn: stops)
            Stepper9(label: "Misses heel-to-toe · Clue 4 · tap step #", selection: ht)
            Stepper9(label: "Steps off the line · Clue 5 · tap step #", selection: off)
            ClueToggle(title: "Uses arms to balance (6+ in)", subtitle: "Clue 6", isOn: arms)
            ClueToggle(title: "Wrong number of steps", subtitle: "Clue 8", isOn: wrong)
            IntField(label: "Steps taken", value: taken)
        }
    }
}

struct OLSTestView: View {
    @Binding var test: OLSTest
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if test.cannotDoTest { Label("Cannot do the test (documented)", systemImage: "xmark.octagon.fill").foregroundStyle(DN.bad).font(.headline) }
            else { FloatingCounter(count: test.totalClues, total: 4, threshold: 2).padding(.horizontal, -16) }
            ContentCard {
                Picker("Leg", selection: $test.leg) { Text("–").tag(String?.none); Text("Left").tag(String?.some("Left")); Text("Right").tag(String?.some("Right")) }.pickerStyle(.segmented)
            }
            StopwatchCard(title: "30-second timer", target: 30, elapsed: $test.elapsed)
            ContentCard {
                ClueToggle(title: "Sways while balancing", subtitle: "Clue 1", isOn: $test.sways)
                ClueToggle(title: "Uses arms to balance", subtitle: "Clue 2 · 6+ in", isOn: $test.usesArms)
                ClueToggle(title: "Hops", subtitle: "Clue 3", isOn: $test.hops)
                Stepper(value: $test.footDownCount.animation(DN.spring), in: 0...10) {
                    VStack(alignment: .leading) { Text("Puts foot down").font(.body.weight(.medium)); Text("Clue 4 · \(test.footDownCount) time(s)").font(.footnote).foregroundStyle(.secondary) }
                }.frame(minHeight: 52)
                IntField(label: "Count reached", value: $test.countReached)
                LabeledField(label: "Foot down at count(s)", text: $test.footDownAt)
                ClueToggle(title: "Cannot do the test", subtitle: "Foot down 3+ times, danger of falling, or refuses", isOn: $test.cannotDoTest)
            }
            ContentCard {
                Text("Additional observations").font(.headline)
                ChipSet(options: ["Did not look at foot", "Counted incorrectly", "Counted slowly / quickly", "Body tremors", "Leg tremors", "Eyelid tremors", "Did not point toes"], selection: $test.extras)
                LabeledField(label: "Injuries / limitations", text: $test.injuries)
                LabeledField(label: "Notes", text: $test.notes, dictation: true)
            }
        }
    }
}

struct LOCTestView: View {
    @Binding var test: LOCTest
    var body: some View {
        VStack(spacing: 12) {
            ContentCard { ConvergenceDiagram() }
            ContentCard {
                PresenceSegment(title: "Left eye", value: $test.left)
                PresenceSegment(title: "Right eye", value: $test.right)
                ChipSet(options: ["Eye drifted outward", "Eye drifted inward", "Unable to follow circle", "Head movement"], selection: $test.extras)
                LabeledField(label: "Notes", text: $test.notes, dictation: true)
            }
        }
    }
}

struct RombergTestView: View {
    @Binding var test: RombergTest
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ContentCard { RombergDiagram() }
            StopwatchCard(title: "Actual time · say \"stop\" when subject opens eyes", target: 30, elapsed: $test.actualElapsed) { t in test.estimatedSeconds = Int(t.rounded()) }
            ContentCard {
                HStack {
                    VStack(alignment: .leading) { Text("ESTIMATE OF 30 s").font(.caption.weight(.semibold)).foregroundStyle(.secondary); Text(test.estimatedSeconds.map { "\($0) s" } ?? "–").font(.title.bold()) }
                    Spacer()
                    if let e = test.estimatedSeconds { Text(e < 25 || e > 35 ? "Outside 25–35 s" : "Within 25–35 s").foregroundStyle(e < 25 || e > 35 ? DN.bad : DN.ok).font(.subheadline.weight(.semibold)) }
                }
                IntField(label: "Subject's estimate", value: $test.estimatedSeconds, unit: "s")
                HStack { NumberField(label: "Sway front/back", value: $test.swayFrontBackInches, unit: "in"); NumberField(label: "Sway side", value: $test.swaySideInches, unit: "in") }
                ChipSet(options: ["Front", "Back", "Left", "Right", "Circular"], selection: $test.swayDirections)
            }
            ContentCard {
                ClueToggle(title: "Eyelid tremors", isOn: $test.eyelidTremors)
                ClueToggle(title: "Body tremors", isOn: $test.bodyTremors)
                ClueToggle(title: "Leg tremors", isOn: $test.legTremors)
                ClueToggle(title: "Muscle rigidity", isOn: $test.muscleRigidity)
                ClueToggle(title: "Opened eyes before finishing", isOn: $test.openedEyes)
                ClueToggle(title: "Did not tilt head back", isOn: $test.didNotTiltHead)
                ClueToggle(title: "Did not follow instructions", isOn: $test.didNotFollowInstructions)
                ClueToggle(title: "Lost balance / stepped", isOn: $test.lostBalance)
                LabeledField(label: "Statements made", text: $test.statements)
                LabeledField(label: "Sounds / noises", text: $test.sounds)
                LabeledField(label: "Notes", text: $test.notes, dictation: true)
            }
        }
    }
}

struct FTNTestView: View {
    @Binding var test: FTNTest
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ContentCard { FingerNoseDiagram(attempts: test.attempts); Text("Order: L R L R R L · green = tip of finger to tip of nose").font(.caption).foregroundStyle(.secondary).frame(maxWidth: .infinity) }
            ForEach(0..<6, id: \.self) { i in
                ContentCard {
                    HStack { Text("Attempt \(i + 1)").font(.headline); Spacer(); Text(FTNTest.order[i] == "L" ? "Left hand" : "Right hand").font(.caption.weight(.semibold)).padding(.horizontal, 10).padding(.vertical, 5).background(.quaternary, in: .capsule) }
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4), spacing: 6) {
                        ForEach(TouchLocation.allCases) { loc in
                            let on = test.attempts[i].location == loc
                            Button { withAnimation(DN.spring) { test.attempts[i].location = on ? nil : loc } } label: {
                                Text(loc.rawValue).font(.caption.weight(.semibold)).frame(maxWidth: .infinity, minHeight: 44)
                                    .background(on ? (loc == .tip ? DN.ok : DN.bad).opacity(0.25) : Color(uiColor: .tertiarySystemFill), in: .rect(cornerRadius: 10))
                            }.buttonStyle(PressScale())
                        }
                    }
                    ChipSet(options: ["Wrong hand", "Searched for nose", "Did not return arm", "Opened eyes", "Hesitated"], selection: $test.attempts[i].flags)
                }
            }
            ContentCard {
                Text("Additional observations").font(.headline)
                ClueToggle(title: "Eyelid tremors", isOn: $test.eyelidTremors)
                ClueToggle(title: "Body tremors", isOn: $test.bodyTremors)
                ClueToggle(title: "Sway", isOn: $test.sway)
                LabeledField(label: "Sway amount / direction", text: $test.swayAmount)
                ClueToggle(title: "Did not follow instructions", isOn: $test.didNotFollowInstructions)
                ClueToggle(title: "Used the wrong hand", isOn: $test.usedWrongHand)
                ClueToggle(title: "Did not tilt head back", isOn: $test.didNotTiltHead)
                ClueToggle(title: "Opened eyes", isOn: $test.openedEyes)
                ClueToggle(title: "Used pad instead of tip", isOn: $test.usedPad)
                LabeledField(label: "Notes", text: $test.notes, dictation: true)
            }
        }
    }
}
