//
//  RandomCampaignPickerView2026.swift
//  St Jude (iOS)
//
//  Created by Justin Hamilton on 8/27/26.
//

import SwiftUI
import Kingfisher

enum TargetType: CaseIterable {
    case myke
    case stephen
    case horse
    
    static func mostlyRandom() -> TargetType {
        let choice = Int.random(in: 0..<10)
        return choice < 5 ? .myke : .stephen
    }
    
    static func completelyRandom() -> TargetType {
        return TargetType.allCases.randomElement() ?? .myke
    }
    
    var targetImage: SwiftUI.ImageResource {
        switch self {
        case .myke:
            return .challengeCoinMyke2026Bright
        case .stephen:
            return .challengeCoinStephen2026Bright
        default:
            return .challengeCoinHorse2026
        }
    }
}

struct Target: View {
    let type: TargetType
    let size: CGFloat
    let onTap: () -> Void
    
    @State private var hapticToggle: Bool = false
    
    var body: some View {
        Button(action: {
            self.hapticToggle.toggle()
            self.onTap()
        }, label: {
            Image(self.type.targetImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: self.size)
        })
        .shadow(radius: 10)
        .sensoryFeedback(.success, trigger: self.hapticToggle)
    }
    
}

struct RandomCampaignPickerView2026: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage(UserDefaults.quickDrawModeUnlockedKey, store: UserDefaults.shared) private var quickDrawModeUnlocked: Bool = false
    
    @Binding var selectedDestination: CampaignListDestination?
    @State private var allCampaigns: [Campaign] = []
    @State private var selectedCampaign: Campaign? = nil
    @State private var isGameOver: Bool = false
    
    private let numShelves = 4
    private let numPerShelf = 3
    private let targetSize: Double = 60
    
    @State private var selectedTargets: [(Int, Int)] = []
    
    @State private var targetsVisible: Bool = false
    
    @State private var numTaps: Int = 0
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var alertButtonText: String = ""
    @State private var showAlert: Bool = false
    @State private var hapticToggle: Bool = false
    
    @State private var showQuickDrawResults: Bool = false
    @State private var quickDrawMode: Bool = false
    @State private var quickDrawTimeElapsed: TimeInterval? = nil
    @State private var quickDrawTimeStarted: Date? = nil
    @State private var showQuickDrawRules: Bool = false
    @State private var shouldUnlockQuickDraw: Bool = false
    @State private var quickDrawBestTime: Double? = UserDefaults.shared.quickDrawBestTime
    
    @State private var benAnAnimationIsInProgressStopTryingToBreakThingsOkay: Bool = false
    
    @State private var targetTypes: [[TargetType]] = []
    
    @State private var sliding: Bool = true
    @State private var slideState: Bool = false
    @State private var slideTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var randomFailureText: String = ""
    
    let titleFont = Font.custom("KilnSansSpiked", size: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize)
    
    func getRandomFailureText() -> String {
        return [
            "You hit Kathy's unicorn?! What in tarnation!",
            "That weren’t no ordinary horse, partner!",
            "You just hit the most magical critter west of the Mississippi!",
            "A unicorn?! Have you completely lost your marbles?",
            "You had one job, gunslinger.",
            "That unicorn had a horn and everything!",
            "The unicorn?! Surely you could see the dang horn!",
            "Well, congratulations. You’ve gone and hit a mythical beast.",
            "That there was a rare and valuable unicorn, ya fool!",
            "You hit the unicorn. The West will never be the same.",
            "Kathy’s noble steed deserved better.",
            "Kathy is gonna hear about this.",
            "You hit Kathy’s unicorn?! Bold move, partner.",
            "That was Kathy’s favourite unicorn. Run.",
            "Kathy’s gonna be mighty sore about this.",
            "You just hit Kathy’s trusty steed. I’d start riding.",
            "Kathy’s horse? You’ve yee’d your last haw.",
            "Well, partner… Kathy’s coming for you.",
            "The steed belonged to Kathy. You might wanna leave town.",
            "You missed the bandits and hit the unicorn. Impressive.",
        ].randomElement()!
    }
    
    func targetType(for shelfIndex: Int, and targetIndex: Int) -> TargetType {
        let defaultTarget: TargetType = .myke
        
        guard shelfIndex < self.targetTypes.count else {
            return defaultTarget
        }
        
        let shelfArray = self.targetTypes[shelfIndex]
        
        guard targetIndex < shelfArray.count else {
            return defaultTarget
        }
        
        return shelfArray[targetIndex]
    }
    
    func isTargetSelected(shelfIndex: Int, targetIndex: Int) -> Bool {
        let item = (shelfIndex, targetIndex)
        return self.selectedTargets.contains {
            return $0 == (item)
        }
    }
    
    @ViewBuilder
    func targetView(shelfIndex: Int, targetIndex: Int) -> some View {
        let targetType = self.targetType(for: shelfIndex, and: targetIndex)
        
        Target(type: targetType, size: self.targetSize) {
            SoundEffectHelper.shared.play(.shotRandom, allowOverlap: true)
            hapticToggle.toggle()
            withAnimation {
                self.selectedTargets.append((shelfIndex, targetIndex))
            }
            
            if self.quickDrawMode {
                self.processQuickDrawTap()
                if targetType == .horse {
                    self.endQuickDrawGame(lost: true)
                }
            } else {
                self.sliding = false
                self.benAnAnimationIsInProgressStopTryingToBreakThingsOkay = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        if targetType == .myke || targetType == .stephen {
                            self.selectedCampaign = self.allCampaigns.randomElement()
                            SoundEffectHelper.shared.play(.winner)
                        } else {
                            self.isGameOver = true
                            SoundEffectHelper.shared.play(.gameover)
                        }
                    }
                    self.benAnAnimationIsInProgressStopTryingToBreakThingsOkay = false
                }
            }
        }
        .disabled(self.isGameOver || self.selectedCampaign != nil || self.showQuickDrawResults || self.showQuickDrawRules || self.benAnAnimationIsInProgressStopTryingToBreakThingsOkay)
        .opacity(self.targetsVisible && !isTargetSelected(shelfIndex: shelfIndex, targetIndex: targetIndex) ? 1.0 : 0.0)
        .scaleEffect(x: 1, y: self.targetsVisible && !isTargetSelected(shelfIndex: shelfIndex, targetIndex: targetIndex) ? 1.0 : 0.0)
        .offset(y: self.targetsVisible && !isTargetSelected(shelfIndex: shelfIndex, targetIndex: targetIndex) ? 0 : 20)
    }
    
    @ViewBuilder
    func shelfView(shelfIndex: Int) -> some View {
        VStack {
            HStack {
                if (!shelfIndex.isMultiple(of: 2) && !slideState) || (shelfIndex.isMultiple(of: 2) && slideState) {
                    Spacer()
                }
                ForEach(0..<self.numPerShelf, id: \.self) { targetIndex in
                    self.targetView(shelfIndex: shelfIndex,
                                    targetIndex: targetIndex)
                    .offset(y: -5)
                    if targetIndex + 1 != numPerShelf || (shelfIndex.isMultiple(of: 2) && !slideState) || (!shelfIndex.isMultiple(of: 2) && slideState) {
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical)
            .sensoryFeedback(.success, trigger: self.hapticToggle)
            .background {
                HStack(spacing: 0) {
                    Image(.randomcampaignpicker2026Shelfleft)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    Image(.randomcampaignpicker2026Shelfcenter)
                        .resizable()
                    Image(.randomcampaignpicker2026Shelfright)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
        }
    }
    
    @ViewBuilder
    var gameView: some View {
        VStack(alignment: .center) {
            Spacer()
            if self.quickDrawMode {
                self.quickDrawHeader
            } else {
                Image(.randomcampaignpicker2026Sign)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(x: 0.8, y: 0.8)
                    .shadow(radius: 10)
                    .padding()
                    .onTapGesture {
                        self.tapSign()
                    }
            }
            Spacer()
            VStack(spacing: 0) {
                Image(.randomcampaignpicker2026Awning)
                    .resizable()
                    .frame(height: self.targetSize * 2)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, -30)
                    .zIndex(2)
                VStack(spacing: 0) {
                    ForEach(0..<self.numShelves, id: \.self) { shelfIndex in
                        self.shelfView(shelfIndex: shelfIndex)
                    }
                }
                .background {
                    GeometryReader { geometry in
                        let borderWidth: Double = 2
                        Rectangle()
                            .foregroundStyle(.black)
                            .frame(width: geometry.size.width + (borderWidth * 2),
                                   height: geometry.size.height + (borderWidth * 2))
                            .offset(x: -borderWidth, y: -borderWidth)
                    }
                }
                .padding(.horizontal)
                .zIndex(1)
            }
            .frame(maxWidth: 400)
            Spacer()
            
            HStack {
                Button(action: {
                    self.dismiss()
                }, label: {
                    Text("Exit")
                        .fullWidth(alignment: .center)
                        .bold()
                })
                .themedButton(type: .primary, id: "randomCampaignPicker2026ExitButton")
                if self.quickDrawModeUnlocked {
                    Button(action: {
                        withAnimation {
                            self.quickDrawMode.toggle()
                            self.reset()
                            if self.quickDrawMode {
                                self.showQuickDrawRules = true
                            }
                        }
                    }, label: {
                        Text(self.quickDrawMode ? "Normal Mode" : "QuickDraw Mode")
                            .fullWidth(alignment: .center)
                            .bold()
                    })
                    .themedButton(type: .secondary, textColor: .primary, id: "randomCampaignPicker2026QuickDrawButton")
                    .disabled(self.isGameOver || self.selectedCampaign != nil || self.showQuickDrawRules || self.showQuickDrawResults)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .onReceive(slideTimer) { _ in
            if sliding {
                withAnimation(.easeInOut(duration: 1)) {
                    slideState.toggle()
                }
            }
        }
    }
    
    @ViewBuilder
    var victoryView: some View {
        if let selectedCampaign = self.selectedCampaign {
            GroupBox {
                VStack {
                    Text("Winner!")
                        .font(self.titleFont)
                        .bold()
                    GroupBox {
                        HStack {
                            if let url = URL(string: selectedCampaign.avatar?.src ?? "") {
                                KFImage.url(url)
                                    .resizable()
                                    .placeholder {
                                        ProgressView()
                                    }
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 50)
                                    .cornerRadius(5)
                                    .onTapGesture {
                                        self.selectedDestination = .campaign(selectedCampaign, true)
                                        self.dismiss()
                                    }
                            }
                            VStack(alignment: .leading) {
                                Text(selectedCampaign.title)
                                    .lineLimit(3)
                                Text(selectedCampaign.user.username)
                                    .foregroundStyle(.secondary)
                            }
                            .fullWidth(alignment: .leading)
                        }
                    }
                    .themedGroupBox(type: .primary, id: "randomCampaignPicker2026WinnerInfoBox")
                    .padding(.bottom)
                    
                    Button(action: {
                        self.selectedDestination = .campaign(selectedCampaign, true)
                        self.dismiss()
                    }, label: {
                        Text("Visit Campaign")
                            .bold()
                            .fullWidth(alignment: .center)
                    })
                    .themedButton(type: .primary, id: "randomCampaignPicker2026GoToCampaignButton")
                    Button(action: {
                        self.reset()
                    }, label: {
                        Text("Play Again")
                            .fullWidth(alignment: .center)
                    })
                    .themedButton(type: .secondary, textColor: .primary, id: "randomCampaignPicker2026ResetButton")
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .themedGroupBox(type: .primary, id: "randomCampaignPicker2026WinnerBox")
        }
    }
    
    @ViewBuilder
    var gameOverView: some View {
        if self.isGameOver {
            GroupBox {
                VStack {
                    Text("Game Over!")
                        .font(self.titleFont)
                        .bold()
                    
                    Text(randomFailureText)
                        .fullWidth(alignment: .center)
                    
                    Image(.kathyAndHorse2026)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 120)
                        .padding(.vertical)
                    
                    Button(action: {
                        self.reset()
                    }, label: {
                        Text("Play Again")
                            .bold()
                    })
                    .themedButton(type: .primary, id: "randomCampaignPicker2026ResetButton")
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .themedGroupBox(type: .primary, id: "randomCampaignPicker2026GameOverBox")
        }
    }
    
    func generateNewTargets() {
        self.targetTypes = []
        
        let total = self.numShelves * self.numPerShelf
        
        var targetArray: [TargetType] = []
        for _ in 0..<(total.quotientAndRemainder(dividingBy: 2).quotient) {
            targetArray.append(.myke)
            targetArray.append(.stephen)
        }
        
        if targetArray.count == total {
            targetArray.remove(at: targetArray.indices.randomElement()!)
        }
        targetArray.append(.horse)
        targetArray = targetArray.shuffled()
        
        for _ in 0..<self.numShelves {
            var shelfArray: [TargetType] = []
            for _ in 0..<self.numPerShelf {
                shelfArray.append(targetArray.popLast() ?? .horse)
            }
            self.targetTypes.append(shelfArray)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                self.targetsVisible = true
            }
        }
    }
    
    func reset() {
        self.benAnAnimationIsInProgressStopTryingToBreakThingsOkay = true
        SoundEffectHelper.shared.stop()
        self.sliding = true
        self.quickDrawTimeStarted = nil
        withAnimation {
            self.slideState.toggle()
            self.selectedTargets = []
            self.selectedCampaign = nil
            self.isGameOver = false
            self.targetsVisible = false
            self.showQuickDrawResults = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.75) {
                SoundEffectHelper.shared.play(.begin)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.generateNewTargets()
            withAnimation {
                self.targetsVisible = true
                self.selectedCampaign = nil
                self.quickDrawTimeElapsed = nil
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.benAnAnimationIsInProgressStopTryingToBreakThingsOkay = false
        }
    }
    
    var body: some View {
        ZStack {
            self.gameView
            Group {
                self.victoryView
                self.gameOverView
                self.quickDrawResultsView
                self.quickDrawRulesView
            }
            .padding()
        }
        .interactiveDismissDisabled()
        .ignoresSafeArea()
        .background {
            GeometryReader { geometry in
                Image.tiledImageAtScale(.woodBackground2026, scale: Theme.current.imageScale)
                    .frame(height: geometry.size.height + 500)
                    .offset(y: -250)
            }
        }
        .onChange(of: isGameOver, initial: true) {
            self.randomFailureText = getRandomFailureText()
        }
        .onAppear {
            Task {
                self.allCampaigns = try await AppDatabase.shared.fetchAllCampaigns().filter { !HIDDEN_CAMPAIGN_IDS.contains($0.id) }
                self.reset()
            }
        }
        .alert(self.alertTitle, isPresented: self.$showAlert, actions: {
            Button(action: {
                self.showAlert = false
                self.alertTitle = ""
                self.alertMessage = ""
                self.alertButtonText = ""
                if self.shouldUnlockQuickDraw {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        withAnimation {
                            self.quickDrawModeUnlocked = true
                            self.quickDrawMode = true
                            self.showQuickDrawRules = true
                        }
                    }
                }
            }, label: {
                Text(self.alertButtonText)
            })
        }, message: {
            Text(self.alertMessage)
        })
    }
}

// MARK: - Quick Draw Mode

extension RandomCampaignPickerView2026 {
    func areThereAnyNonWeirdFishTargetsLeft() -> Bool {
        let allItems: [TargetType] = self.targetTypes.reduce(into: [TargetType](), { partial, current in
            for type in current {
                partial.append(type)
            }
        })
        
        let allNonWeirdFishItems = allItems.filter({$0 != .horse})
        
        let allSelectedNonWeirdFishTypes = self.selectedTargets.map { (shelf, target) in self.targetType(for: shelf, and: target) }.filter { $0 != .horse }
        
        return allSelectedNonWeirdFishTypes.count == allNonWeirdFishItems.count
    }
    
    func processQuickDrawTap() {
        
        if self.quickDrawTimeStarted == nil {
            self.quickDrawTimeStarted = Date()
        }
        
        if self.areThereAnyNonWeirdFishTargetsLeft() {
            self.endQuickDrawGame(lost: false)
        }
    }
    
    func endQuickDrawGame(lost: Bool) {
        self.sliding = false
        self.benAnAnimationIsInProgressStopTryingToBreakThingsOkay = true
        self.quickDrawTimeElapsed = Date().timeIntervalSince(self.quickDrawTimeStarted ?? Date())
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            withAnimation {
                if lost {
                    self.isGameOver = true
                    SoundEffectHelper.shared.play(.gameover)
                } else {
                    if let quickDrawTimeElapsed = self.quickDrawTimeElapsed, self.quickDrawBestTime == nil || quickDrawTimeElapsed < self.quickDrawBestTime! {
                        self.quickDrawBestTime = quickDrawTimeElapsed
                        UserDefaults.shared.quickDrawBestTime = quickDrawTimeElapsed
                    }
                    self.showQuickDrawResults = true
                    SoundEffectHelper.shared.play(.winner)
                }
            }
            self.benAnAnimationIsInProgressStopTryingToBreakThingsOkay = true
        }
    }
    
    var randomCowboyism: String {
        return [
            "Rootin' Tootin'!",
            "Nice Shootin'!",
            "Yeehaw!",
            "Sharp Shootin'!"
        ].randomElement() ?? "Yeehaw!"
    }
    
    @ViewBuilder
    var quickDrawRulesView: some View {
        if self.showQuickDrawRules {
            GroupBox {
                VStack(spacing: 5) {
                    Text("QuickDraw Mode!")
                        .font(self.titleFont)
                        .bold()
                    Text("Shoot the targets as quickly as you can! Make sure to avoid Kathy's steed!")
                        .multilineTextAlignment(.center)
                    Button(action: {
                        self.showQuickDrawRules = false
                    }, label: {
                        Text("Let's go!")
                    })
                    .themedButton(type: .primary, id: "randomCampaignPicker2026QuickDrawStartButton")
                    .padding(.top)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .themedGroupBox(type: .primary, id: "randomCampaignPicker2026QuickDrawRulesBox")
        }
    }
    
    @ViewBuilder
    var quickDrawResultsView: some View {
        if self.showQuickDrawResults, let quickDrawTimeElapsed = self.quickDrawTimeElapsed {
            GroupBox {
                VStack(spacing: 5) {
                    Text(self.randomCowboyism)
                        .font(self.titleFont)
                        .bold()
                        .padding(.bottom)
                    if quickDrawBestTime == quickDrawTimeElapsed {
                        Text("You done hit a high score!")
                            .padding(.bottom)
                    }
                    HStack {
                        Spacer()
                        GroupBox {
                            VStack {
                                Text("\(quickDrawTimeElapsed, specifier: "%.2f")")
                                    .font(.largeTitle)
                                    .bold()
                                Text("seconds")
                            }
                        }
                        .themedGroupBox(type: .primary)
                        Spacer()
                        Button(action: {
                            self.reset()
                        }, label: {
                            Text("Play Again")
                                .bold()
                        })
                        .themedButton(type: .primary, id: "randomCampaignPicker2026ResetButton")
                        Spacer()
                    }
                    if let quickDrawBestTime = self.quickDrawBestTime {
                        Text("Best: \(quickDrawBestTime, specifier: "%.2f") seconds")
                            .font(.footnote)
                            .padding(.top)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .themedGroupBox(type: .primary, id: "randomCampaignPicker2026QuickDrawResultsBox")
        }
    }
    
    var formattedTimeForHeader: String {
        guard let quickDrawTimeElapsed = self.quickDrawTimeElapsed else { return "00.00" }
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumIntegerDigits = 2
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter.string(from: NSNumber(value: quickDrawTimeElapsed)) ?? "00.00"
    }
    
    @ViewBuilder
    var quickDrawHeader: some View {
            GroupBox {
                VStack {
                    Text("QuickDraw Mode!")
                        .font(self.titleFont)
                        .bold()
                    if #available(iOS 18, *) {
                        if let quickDrawTimeStarted = self.quickDrawTimeStarted, quickDrawTimeElapsed == nil {
                            Text(.currentDate, format: .stopwatch(startingAt: quickDrawTimeStarted))
                        } else {
                            Text("00:\(formattedTimeForHeader)")
                        }
                    }
                }
            }
            .themedGroupBox(type: .primary, id: "randomCampaignPicker2026QuickDrawTitle")
    }
    
    // MARK: - Dialog
    
    func tapSign() {
        self.numTaps += 1
        self.shouldUnlockQuickDraw = false
        
        if self.quickDrawModeUnlocked {
            self.alertTitle = "That's all"
            self.alertMessage = "There's nothing else here. I swear"
            self.alertButtonText = "ok bye"
        } else {
            if self.numTaps == 1 {
                self.alertTitle = "Not like that"
                self.alertMessage = "Don't tap the sign to win, tap the targets!"
                self.alertButtonText = "ok sorry"
            } else if self.numTaps == 2 {
                self.alertTitle = "C'mon"
                self.alertMessage = "What did I just say??"
                self.alertButtonText = "my bad big dawg"
            } else if self.numTaps == 3 {
                self.alertTitle = "What are you expecting"
                self.alertMessage = "Are you looking for some secret easter egg here?"
                self.alertButtonText = "maybe"
            } else if self.numTaps == 4 {
                self.alertTitle = "Well there's nothing here"
                self.alertMessage = "Too bad. Maybe you should just play the game we spent so much time on"
                self.alertButtonText = "are you sure?"
            } else if self.numTaps == 5 {
                self.alertTitle = "The game is RIGHT there"
                self.alertMessage = "We spent a lot of time on this game, why don't you give it a try?"
                self.alertButtonText = "i'm good"
            } else if self.numTaps == 6 {
                self.alertTitle = "You're wasting your time"
                self.alertMessage = "I'm not going to give you anything because you keep tapping the sign"
                self.alertButtonText = "what if i do it again"
            } else if self.numTaps == 7 {
                self.alertTitle = "Fine."
                self.alertMessage = "What do you want me to do here?"
                self.alertButtonText = "game pls :)"
            } else if self.numTaps == 8 {
                self.alertTitle = "Seriously?"
                self.alertMessage = "We give you one game and yet you want ANOTHER game?"
                self.alertButtonText = "yes pls"
            } else if self.numTaps == 9 {
                self.alertTitle = "Alright whatever."
                self.alertMessage = "I'm not making a new UI though. You're using this one"
                self.alertButtonText = "ok i guess"
            } else if self.numTaps == 10 {
                self.alertTitle = "Have fun"
                self.alertMessage = "Here's the secret game. Congrats"
                self.alertButtonText = "tyyyyyy"
                self.shouldUnlockQuickDraw = true
            } else {
                self.alertTitle = "That's all"
                self.alertMessage = "There's nothing else here. I swear"
                self.alertButtonText = "ok bye"
            }
        }
        
        self.showAlert = true
    }
}

#Preview {
    RandomCampaignPickerView2026(selectedDestination: Binding<CampaignListDestination?>.constant(nil))
}
