//
//  RandomCampaignPickerView2026.swift
//  St Jude (iOS)
//
//  Created by Justin Hamilton on 8/27/26.
//

import SwiftUI
import Kingfisher

struct RandomCampaignPickerView2026: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var selectedDestination: CampaignListDestination?
    @State private var allCampaigns: [Campaign] = []
    @State private var selectedCampaign: Campaign? = nil
    @State private var isGameOver: Bool = false
    
    private let numShelves = 4
    private let numPerShelf = 3
    private let targetSize: Double = 60
    
    @State private var selectedTarget: (Int, Int)? = nil
    
    @State private var targetsVisible: Bool = false
    
    enum TargetType: CaseIterable {
        case myke
        case stephen
        case weirdfish
        
        static func mostlyRandom() -> TargetType {
            let choice = Int.random(in: 0..<10)
            return choice < 5 ? .myke : .stephen
        }
        
        var targetImage: SwiftUI.ImageResource {
            switch self {
            case .myke:
                return .challengeCoinMyke2026Bright
            case .stephen:
                return .challengeCoinStephen2026Bright
            default:
                return .challengeCoinWeirdFish2026
            }
        }
    }
    
    @State private var targetTypes: [[TargetType]] = []
    
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
    
    @ViewBuilder
    func targetView(shelfIndex: Int, targetIndex: Int) -> some View {
        let targetType = self.targetType(for: shelfIndex, and: targetIndex)
        
        Button(action: {
            SoundEffectHelper.shared.play(.shotRandom)
            withAnimation {
                self.selectedTarget = (shelfIndex, targetIndex)
                self.targetsVisible = false
            }
                
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
            }
        }, label: {
            Image(targetType.targetImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: self.targetSize)
        })
        .shadow(radius: 10)
        .disabled(self.isGameOver || self.selectedCampaign != nil)
        .opacity(self.targetsVisible || (self.selectedTarget ?? (-1, -1)) == (shelfIndex, targetIndex) ? 1.0 : 0.0)
        .scaleEffect(y: self.targetsVisible || (self.selectedTarget ?? (-1, -1)) == (shelfIndex, targetIndex) ? 1.0 : 0.0)
        .offset(y: self.targetsVisible || (self.selectedTarget ?? (-1, -1)) == (shelfIndex, targetIndex) ? 0 : 20)
    }
    
    @ViewBuilder
    func shelfView(shelfIndex: Int) -> some View {
        VStack {
            HStack {
                Spacer()
                ForEach(0..<self.numPerShelf, id: \.self) { targetIndex in
                    self.targetView(shelfIndex: shelfIndex,
                                    targetIndex: targetIndex)
                    .offset(y: -5)
                    Spacer()
                }
            }
            .padding(.vertical)
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
        VStack {
            Spacer()
            Image(.randomcampaignpicker2026Sign)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(x: 0.8, y: 0.8)
                .shadow(radius: 10)
                .padding()
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
            Spacer()
            
            Button(action: {
                self.dismiss()
            }, label: {
                Text("Exit")
                    .fullWidth(alignment: .center)
            })
            .themedButton(type: .primary, id: "randomCampaignPicker2026ExitButton")
            .padding(.horizontal)
            .padding(.bottom)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    var victoryView: some View {
        if let selectedCampaign = self.selectedCampaign {
            GroupBox {
                VStack {
                    Text("Winner!")
                        .font(.title)
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
                        .font(.title)
                        .bold()
                    Button(action: {
                        self.reset()
                    }, label: {
                        Text("Play Again")
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
        
        for _ in 0..<self.numShelves {
            var shelfArray: [TargetType] = []
            for _ in 0..<self.numPerShelf {
                shelfArray.append(TargetType.mostlyRandom())
            }
            self.targetTypes.append(shelfArray)
        }
        
        // insert a weird fish
        let shelfIndex = Int.random(in: 0..<self.targetTypes.count)
        let shelfArrLength = self.targetTypes[shelfIndex].count
        self.targetTypes[shelfIndex][Int.random(in: 0..<shelfArrLength)] = .weirdfish
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                self.targetsVisible = true
            }
        }
    }
    
    func reset() {
        SoundEffectHelper.shared.stop()
        withAnimation {
            self.selectedTarget = nil
            self.selectedCampaign = nil
            self.isGameOver = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.75) {
                SoundEffectHelper.shared.play(.begin)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.generateNewTargets()
            withAnimation {
                self.targetsVisible = true
                self.selectedCampaign = nil
            }
        }
    }
    
    var body: some View {
        ZStack {
            self.gameView
            Group {
                self.victoryView
                self.gameOverView
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
        .onAppear {
            Task {
                self.allCampaigns = try await AppDatabase.shared.fetchAllCampaigns().filter { !HIDDEN_CAMPAIGN_IDS.contains($0.id) }
                self.reset()
            }
        }
    }
}

#Preview {
    RandomCampaignPickerView2026(selectedDestination: Binding<CampaignListDestination?>.constant(nil))
}
