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
    
    @Binding var campaignChoiceID: UUID?
    @State private var allCampaigns: [Campaign] = []
    @State private var selectedCampaign: Campaign? = nil
    @State private var isGameOver: Bool = false
    
    private let numShelves = 4
    private let numPerShelf = 3
    private let targetSize: Double = 60
    
    enum TargetType: CaseIterable {
        case myke
        case stephen
        case thirdBadOneIHaventPickedYet
        
        static func mostlyRandom() -> TargetType {
            let choice = Int.random(in: 0...10)
            if choice < 2 {
                return .thirdBadOneIHaventPickedYet
            }
            
            let choice2 = Int.random(in: 0...1)
            return choice2 == 0 ? .myke : .stephen
        }
        
        var backgroundColor: Color {
            switch self {
            case .myke:
                return .red
            case .stephen:
                return .blue
            default:
                return .black
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
            if targetType == .myke || targetType == .stephen {
                self.selectedCampaign = self.allCampaigns.randomElement()
            } else {
                self.isGameOver = true
            }
        }, label: {
            Circle()
                .foregroundStyle(targetType.backgroundColor)
                .frame(height: self.targetSize)
        })
        .shadow(radius: 10)
    }
    
    @ViewBuilder
    func shelfView(shelfIndex: Int) -> some View {
        VStack {
            HStack {
                Spacer()
                ForEach(0..<self.numPerShelf, id: \.self) { targetIndex in
                    self.targetView(shelfIndex: shelfIndex,
                                    targetIndex: targetIndex)
                    Spacer()
                }
            }
            Rectangle()
                .foregroundStyle(Color.secondarySystemBackground)
                .frame(height: 10)
        }
    }
    
    @ViewBuilder
    var gameView: some View {
        VStack {
            VStack {
                Spacer()
            ForEach(0..<self.numShelves, id: \.self) { shelfIndex in
                    self.shelfView(shelfIndex: shelfIndex)
                    Spacer()
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
                                    self.campaignChoiceID = selectedCampaign.id
                                    self.dismiss()
                                }
                        }
                        VStack {
                            Text(selectedCampaign.title)
                            Text(selectedCampaign.user.username)
                        }
                    }
                    HStack {
                        Button(action: {
                            self.campaignChoiceID = selectedCampaign.id
                            self.dismiss()
                        }, label: {
                            Text("Visit Campaign")
                        })
                        Button(action: {
                            self.selectedCampaign = nil
                        }, label: {
                            Text("Play Again")
                        })
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
        }
    }
    
    @ViewBuilder
    var gameOverView: some View {
        if self.isGameOver {
            GroupBox {
                VStack {
                    Text("Game Over!")
                    Button(action: {
                        self.selectedCampaign = nil
                        self.isGameOver = false
                    }, label: {
                        Text("Play Again")
                    })
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
        }
    }
    
    var body: some View {
        ZStack {
            self.gameView
            self.victoryView
            self.gameOverView
        }
        .padding()
        .onAppear {
            Task {
                self.allCampaigns = try await AppDatabase.shared.fetchAllCampaigns().filter { !HIDDEN_CAMPAIGN_IDS.contains($0.id) }
            }
            
            for _ in 0..<self.numShelves {
                var shelfArray: [TargetType] = []
                for _ in 0..<self.numPerShelf {
                    shelfArray.append(TargetType.mostlyRandom())
                }
                self.targetTypes.append(shelfArray)
            }
        }
    }
}

#Preview {
    RandomCampaignPickerView2026(campaignChoiceID: Binding<UUID?>.constant(nil))
}
