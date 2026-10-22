import SwiftUI

struct DREWizardView: View {
    let session: CaseSession
    @State private var step = 1
    @State private var showMatrix = false
    @Namespace private var ns
    var body: some View {
        @Bindable var s = session
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    GlassEffectContainer(spacing: 6) {
                        HStack(spacing: 6) {
                            ForEach(Seed.data.steps) { st in
                                let done = s.payload.dre.steps[st.n]?.completedAt != nil
                                Button { withAnimation(DN.spring) { step = st.n } } label: {
                                    Text("\(st.n)").font(.headline.monospacedDigit()).frame(width: 40, height: 40)
                                        .foregroundStyle(done ? DN.ok : .primary)
                                }
                                .glassEffect(step == st.n ? .regular.tint(DN.accent.opacity(0.5)).interactive() : .regular.interactive(), in: .circle)
                                .glassEffectID(st.n, in: ns).id(st.n)
                            }
                        }.padding(.horizontal).padding(.vertical, 8)
                    }
                }
                .onChange(of: step) { _, n in withAnimation { proxy.scrollTo(n, anchor: .center) } }
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    let info = Seed.data.steps[step - 1]
                    Text("STEP \(step) OF 12").font(.caption.weight(.bold)).foregroundStyle(DN.accent)
                    Text(info.t).font(.largeTitle.bold())
                    Text(info.d).foregroundStyle(.secondary)
                    DREStepBody(step: step, dre: $s.payload.dre, payload: s.payload)
                    HStack {
                        Button("Back") { withAnimation(DN.spring) { step = max(1, step - 1) } }.buttonStyle(.glass).disabled(step == 1)
                        Spacer()
                        Button(step == 12 ? "Complete evaluation" : "Complete step") {
                            s.payload.dre.steps[step, default: DREStepState()].completedAt = .now
                            Haptics.success()
                            withAnimation(DN.spring) { step = min(12, step + 1) }
                        }.buttonStyle(.glassProminent)
                    }.padding(.top, 8)
                }
                .padding()
                .id(step)
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
            }
            .background(Color(uiColor: .systemGroupedBackground))
        }
        .navigationTitle("DRE 12-Step").navigationBarTitleDisplayMode(.inline)
        .onChange(of: step, initial: true) { _, n in if s.payload.dre.steps[n]?.startedAt == nil { s.payload.dre.steps[n, default: DREStepState()].startedAt = .now } }
        .overlay(alignment: .bottomTrailing) { MatrixFAB(showMatrix: $showMatrix, ns: ns) }
        .sheet(isPresented: $showMatrix) { LiveMatrixSheet(payload: s.payload) }
    }
}

struct DREStepBody: View {
    let step: Int
    @Binding var dre: DREEvaluation
    let payload: CasePayload
    var n: Norms { Seed.data.norms }
    var body: some View {
        switch step {
        case 1: breath
        case 2: interview
        case 3: preliminary
        case 4: eyes
        case 5: divided
        case 6: vitals
        case 7: darkRoom
        case 8: tone
        case 9: injection
        case 10: statements
        case 11: opinion
        default: toxicology
        }
    }

    var breath: some View {
        ContentCard {
            LabeledField(label: "Instrument", text: $dre.instrument); LabeledField(label: "Serial #", text: $dre.instrumentSerial); LabeledField(label: "Operator", text: $dre.operatorName)
            Toggle("Refused", isOn: $dre.breathRefused)
            HStack { NumberField(label: "Result 1", value: $dre.breathResult1); NumberField(label: "Result 2", value: $dre.breathResult2) }
            DatePicker("Time", selection: Binding(get: { dre.breathTime1 ?? .now }, set: { dre.breathTime1 = $0 }))
            if let r = dre.breathResult1, r < 0.08 { Label("BrAC not consistent with observed impairment? Proceed with evaluation.", systemImage: "info.circle").font(.footnote).foregroundStyle(DN.warn) }
        }
    }
    var interview: some View {
        ContentCard {
            LabeledField(label: "Arresting officer", text: $dre.arrestingOfficer); LabeledField(label: "Agency", text: $dre.arrestingAgency); LabeledField(label: "Badge", text: $dre.arrestingBadge)
            Toggle("Crash involved", isOn: $dre.crash)
            LabeledField(label: "Driving behavior", text: $dre.drivingSummary, dictation: true)
            LabeledField(label: "Contact observations", text: $dre.contactSummary, dictation: true)
            LabeledField(label: "SFST results (arresting officer)", text: $dre.sfstSummary, prompt: "HGN \(payload.sfst.hgn.totalClues)/6 · WAT \(payload.sfst.wat.totalClues)/8 · OLS \(payload.sfst.ols.totalClues)/4", dictation: true)
            LabeledField(label: "Statements", text: $dre.statementsToOfficer, dictation: true)
            LabeledField(label: "Evidence found", text: $dre.evidence)
        }
    }
    var preliminary: some View {
        VStack(spacing: 12) {
            ContentCard {
                Text("Medical questions").font(.headline)
                ForEach(["Are you sick or injured?", "Do you have diabetes or epilepsy?", "Do you take insulin?", "Are you under a doctor's or dentist's care?", "Are you taking any medication or drugs?", "Do you have any physical defects?", "When did you last eat / sleep?"], id: \.self) { q in
                    LabeledField(label: q, text: Binding(get: { dre.questions[q] ?? "" }, set: { dre.questions[q] = $0 }))
                }
            }
            ContentCard {
                Text("Appearance").font(.headline)
                ChipSet(options: ["Normal", "Slurred", "Thick", "Rapid", "Slow"], selection: $dre.speech)
                ChipSet(options: ["None", "Alcoholic beverage", "Cannabis", "Chemical"], selection: $dre.breathOdor)
                ChipSet(options: ["Normal", "Flushed", "Pale", "Sweating"], selection: $dre.face)
                ChipSet(options: ["Normal", "Bloodshot", "Watery", "Droopy lids", "Glassy"], selection: $dre.eyeAppearance)
                LabeledField(label: "Attitude", text: $dre.attitude); LabeledField(label: "Coordination", text: $dre.coordination)
                Picker("Corrective lenses", selection: $dre.correctiveLenses) { ForEach(["None", "Glasses", "Contacts – hard", "Contacts – soft"], id: \.self) { Text($0) } }
                Toggle("Blindness", isOn: $dre.blindness)
                PresenceSegment(title: "Resting nystagmus", value: $dre.restingNystagmus)
                PresenceSegment(title: "HGN check", value: $dre.hgnCheck)
            }
            pulse("Pulse 1", $dre.pulse1)
        }
    }
    var eyes: some View {
        VStack(alignment: .leading, spacing: 12) {
            InstructionCard(key: "hgn")
            HGNTestView(test: $dre.hgn, showAngles: true)
            SectionTitle(text: "Vertical Gaze Nystagmus")
            ContentCard { PresenceSegment(title: "VGN", value: $dre.vgn) }
            InstructionCard(key: "loc")
            LOCTestView(test: $dre.loc)
        }
    }
    var divided: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(text: "Modified Romberg"); InstructionCard(key: "rom"); RombergTestView(test: $dre.romberg)
            SectionTitle(text: "Walk and Turn"); InstructionCard(key: "wat"); WATTestView(test: $dre.wat)
            SectionTitle(text: "One Leg Stand · left"); InstructionCard(key: "ols"); OLSTestView(test: $dre.olsLeft)
            SectionTitle(text: "One Leg Stand · right"); OLSTestView(test: $dre.olsRight)
            SectionTitle(text: "Finger to Nose"); InstructionCard(key: "ftn"); FTNTestView(test: $dre.ftn)
        }
    }
    var vitals: some View {
        VStack(spacing: 12) {
            ContentCard {
                HStack { IntField(label: "Systolic", value: $dre.systolic, unit: "mmHg"); IntField(label: "Diastolic", value: $dre.diastolic, unit: "mmHg") }
                NumberField(label: "Temperature", value: $dre.temperatureF, unit: "°F")
                norm("BP normal \(Int(n.sys[0]))–\(Int(n.sys[1])) / \(Int(n.dia[0]))–\(Int(n.dia[1]))")
                norm("Temp normal \(n.temp[0])–\(n.temp[1]) °F")
            }
            pulse("Pulse 2", $dre.pulse2)
        }
    }
    var darkRoom: some View {
        VStack(spacing: 12) {
            ContentCard {
                PupilGauge(label: "Room light · left", normal: n.room[0]...n.room[1], value: $dre.roomLeft)
                PupilGauge(label: "Room light · right", normal: n.room[0]...n.room[1], value: $dre.roomRight)
                PupilGauge(label: "Near total darkness · left", normal: n.dark[0]...n.dark[1], value: $dre.darkLeft)
                PupilGauge(label: "Near total darkness · right", normal: n.dark[0]...n.dark[1], value: $dre.darkRight)
                PupilGauge(label: "Direct light · left", normal: n.direct[0]...n.direct[1], value: $dre.directLeft)
                PupilGauge(label: "Direct light · right", normal: n.direct[0]...n.direct[1], value: $dre.directRight)
            }
            ContentCard {
                Picker("Reaction to light", selection: $dre.reactionToLight) { ForEach(["", "Normal", "Slow", "Little to none visible"], id: \.self) { Text($0.isEmpty ? "–" : $0) } }
                Toggle("Rebound dilation", isOn: Binding(get: { dre.reboundDilation ?? false }, set: { dre.reboundDilation = $0 }))
                Toggle("Hippus", isOn: Binding(get: { dre.hippus ?? false }, set: { dre.hippus = $0 }))
                Text("Nasal area").font(.headline); ChipSet(options: ["Normal", "Redness", "Residue", "Runny", "Septum damage"], selection: $dre.nasal)
                Text("Oral cavity").font(.headline); ChipSet(options: ["Normal", "Raised taste buds", "Green coating", "Burns", "Debris", "Odor"], selection: $dre.oral)
                LabeledField(label: "Ingestion notes", text: $dre.ingestionNotes)
            }
        }
    }
    var tone: some View {
        ContentCard {
            Picker("Overall tone", selection: $dre.muscleTone) { ForEach(["", "Normal", "Flaccid", "Rigid"], id: \.self) { Text($0.isEmpty ? "–" : $0) } }.pickerStyle(.segmented)
            Text("Tap regions to cycle normal → flaccid → rigid").font(.footnote).foregroundStyle(.secondary)
            BodyMap(mode: .tone, marks: $dre.toneMap)
            LabeledField(label: "Notes", text: $dre.toneNotes, dictation: true)
        }
    }
    var injection: some View {
        VStack(spacing: 12) {
            ContentCard {
                Text("Tap to mark fresh → old sites").font(.footnote).foregroundStyle(.secondary)
                BodyMap(mode: .injection, marks: $dre.injectionSites)
                LabeledField(label: "Description", text: $dre.injectionDescription, dictation: true)
            }
            pulse("Pulse 3", $dre.pulse3)
        }
    }
    var statements: some View {
        VStack(spacing: 12) {
            ContentCard {
                Toggle("Miranda given", isOn: Binding(get: { dre.mirandaGiven ?? false }, set: { dre.mirandaGiven = $0; dre.mirandaTime = .now }))
                Toggle("Waived", isOn: Binding(get: { dre.waived ?? false }, set: { dre.waived = $0 }))
                LabeledField(label: "What drugs used?", text: $dre.drugsUsed); LabeledField(label: "How much?", text: $dre.amount)
                LabeledField(label: "When?", text: $dre.whenUsed); LabeledField(label: "Where?", text: $dre.whereUsed); LabeledField(label: "Route", text: $dre.route)
                LabeledField(label: "Admissions", text: $dre.admissions, dictation: true)
            }
            ContentCard {
                Text("Timeline").font(.headline)
                ForEach($dre.timeline) { $e in HStack { DatePicker("", selection: $e.time, displayedComponents: .hourAndMinute).labelsHidden(); TextField("Event", text: $e.event) } }
                Button { dre.timeline.append(TimelineEntry(time: .now, event: "")) } label: { Label("Add event", systemImage: "plus") }.buttonStyle(.glass)
            }
        }
    }
    var opinion: some View {
        let r = MatrixEngine.rank(MatrixEngine.indicators(for: payload))
        return VStack(alignment: .leading, spacing: 12) {
            ContentCard {
                Text("Matrix suggestion").font(.headline)
                ForEach(r.categories.prefix(3)) { c in HStack { Text(c.category.name); Spacer(); Text(c.score, format: .percent.precision(.fractionLength(0))).monospacedDigit().foregroundStyle(c.category.tint) } }
                Text("Suggestion only. The opinion is the evaluator's, based on the totality of the evaluation.").font(.caption).foregroundStyle(.secondary)
            }
            ContentCard {
                Picker("Impaired", selection: $dre.impaired) { Text("–").tag(Bool?.none); Text("Impaired").tag(Bool?.some(true)); Text("Not impaired").tag(Bool?.some(false)) }.pickerStyle(.segmented)
                ChipSet(options: Seed.categories.map(\.name) + ["Medical rule-out", "Alcohol only"], selection: $dre.opinionCategories)
                LabeledField(label: "Basis for opinion", text: $dre.opinionBasis, dictation: true)
                DatePicker("Time of opinion", selection: Binding(get: { dre.opinionTime ?? .now }, set: { dre.opinionTime = $0 }))
            }
        }
    }
    var toxicology: some View {
        VStack(spacing: 12) {
            ContentCard {
                Picker("Specimen", selection: $dre.specimen) { ForEach(["", "Blood", "Urine", "Oral fluid", "Refused"], id: \.self) { Text($0.isEmpty ? "–" : $0) } }.pickerStyle(.segmented)
                DatePicker("Collected", selection: Binding(get: { dre.specimenTime ?? .now }, set: { dre.specimenTime = $0 }))
                LabeledField(label: "Collector", text: $dre.collector); LabeledField(label: "Kit / seal #", text: $dre.kitID); LabeledField(label: "Laboratory", text: $dre.lab)
            }
            ContentCard {
                Text("Chain of custody").font(.headline)
                ForEach($dre.custody) { $c in
                    VStack(alignment: .leading) {
                        DatePicker("At", selection: $c.at)
                        HStack { TextField("From", text: $c.from); TextField("To", text: $c.to) }
                        TextField("Purpose", text: $c.purpose)
                    }
                    Divider()
                }
                Button { dre.custody.append(CustodyEntry(at: .now, from: "", to: "", purpose: "")) } label: { Label("Add transfer", systemImage: "plus") }.buttonStyle(.glass)
                LabeledField(label: "Toxicology results", text: $dre.toxResults)
            }
        }
    }

    func pulse(_ t: String, _ p: Binding<Pulse>) -> some View {
        ContentCard {
            Text(t).font(.headline)
            HStack { IntField(label: "BPM", value: p.bpm); DatePicker("", selection: Binding(get: { p.wrappedValue.time ?? .now }, set: { p.wrappedValue.time = $0 }), displayedComponents: .hourAndMinute).labelsHidden() }
            norm("Normal \(Int(n.pulse[0]))–\(Int(n.pulse[1])) bpm")
        }
    }
    func norm(_ t: String) -> some View { Text(t).font(.caption).foregroundStyle(.secondary) }
}
