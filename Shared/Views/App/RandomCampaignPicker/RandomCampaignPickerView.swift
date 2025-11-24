//
//  RandomCampaignPickerView.swift
//  St Jude
//
//  Created by Justin Hamilton on 9/17/23.
//

import SwiftUI
import Kingfisher
import AVKit

struct RandomCampaignPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var campaignChoiceID: UUID?
    @State private var allCampaigns: [Campaign] = []
    @State private var chosenCampaign: Campaign?
    
    @State private var animationDuration: Double = 2.25
    
    @State private var wheelRotation: Angle = .degrees(0)
    
    @State private var indexToFlip: Int = 0
    @State private var animationFinished: Bool = false
    @State private var isResetting: Bool = false
        
#if !os(macOS)
    let bounceHaptics = UIImpactFeedbackGenerator(style: .light)
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
#endif
    
    @State private var wheelRadius: Double = 300
    @State private var wedgeCount = 18
    
    var wheelCircumference: Double {
        return 2 * Double.pi * wheelRadius
    }
    
    var sectionWidth: Double {
        return wheelCircumference / Double(wedgeCount)
    }
    
    func spinAgain() {
        withAnimation(.easeInOut(duration: 1.0).speed(1.5)) {
            animationFinished = false
            isResetting = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0, execute: {
            isResetting = false
            chosenCampaign = getRandomCampaign()
            playAnimation()
            SoundEffectHelper.shared.play(.drumroll)
        })
    }
    
    @ViewBuilder
    var wheelView: some View {
        WheelLayout(radius: wheelRadius) {
            ForEach(0..<wedgeCount) { index in
                WheelWedgeView(index: index, isTimeToFlip: $animationFinished, campaign: $chosenCampaign, campaignChoiceID: $campaignChoiceID, shouldFlip: index == indexToFlip)
                    .frame(width: sectionWidth, height: wheelRadius)
                    .rotationEffect(Angle(degrees: (360/Double(wedgeCount))*Double(index)))
            }
        }
        .frame(width: wheelRadius*2, height: wheelRadius*2)
        .clipShape(Circle())
        .background(Color.black.clipShape(Circle()))
        .shadow(radius: 10)
        .overlay {
            wheelCenterView
        }
        .rotationEffect(wheelRotation)
        .padding([.bottom], -wheelRadius*(animationFinished ? 0.8 : 0.9))
        .onTapGesture {
            if animationFinished {
                spinAgain()
            }
        }
    }
    
    @ViewBuilder
    var wheelCenterView: some View {
        ZStack {
            Image(.iconRegular)
                .resizable()
                .frame(width: wheelRadius/5, height: wheelRadius/5)
                .overlay {
                    Circle()
                        .stroke(.black, lineWidth: 4)
                }
                .clipShape(Circle())
                .rotationEffect(Angle(degrees: -wheelRotation.degrees))
                .shadow(radius: 5)
            Circle()
                .stroke(.black, lineWidth: 4)
        }
    }
    
    @ViewBuilder
    var chosenCampaignInfoView: some View {
        VStack {
            Spacer()
            if let campaign = chosenCampaign, animationFinished {
                VStack {
                    Spacer()
                    Text(campaign.title)
                        .lineLimit(3)
                        .multilineTextAlignment(.center)
                        .font(.title)
                        .bold()
                    Text(campaign.user.username)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .italic()
                        .foregroundStyle(.secondary)
                    Button(action: {
                        campaignChoiceID = chosenCampaign?.id
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("View this fundraiser")
                            .font(.headline)
                    })
                    .buttonStyle(PrimaryButtonStyle())
                    Spacer()
                    Button(action: spinAgain, label: {
                        Text("Spin Again")
                    })
                    .buttonStyle(PrimaryButtonStyle(padding: 10))
                    .padding(.bottom)
                }
            }
        }
        .padding([.bottom], wheelRadius*1.25)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Image(.confetti)
                .resizable()
                .scaleEffect(animationFinished ? CGSize(width: 3.0, height: 1.0) : .zero)
                .opacity(animationFinished || isResetting ? 0 : 1)
            self.chosenCampaignInfoView
        }
        .overlay(alignment:.bottom) {
            self.wheelView
        }
        .background {
            GeometryReader { geo in
                Color.clear.preference(key: Self.WidthPreferenceKey.self, value: geo.size.width)
            }
        }
        .onPreferenceChange(Self.WidthPreferenceKey.self) { value in
            self.wheelRadius = min((1.5 * value) / 2.0, 300)
        }
        .onAppear {
            Task {
                await self.fetch()
                chosenCampaign = getRandomCampaign()
                playAnimation()
                SoundEffectHelper.shared.play(.drumroll)
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: {
                    self.dismiss()
                }, label: {
                    Image(systemName: "xmark")
                })
            }
        }
#if !os(macOS)
        .onReceive(timer) { _ in
            if !animationFinished && !isResetting {
                bounceHaptics.impactOccurred()
            }
        }
#endif
    }
    
    func fetch() async {
        do {
            dataLogger.notice("Fetched stored fundraiser")
            try Task.checkCancellation()
            self.allCampaigns = try await AppDatabase.shared.fetchAllCampaigns().filter { !HIDDEN_CAMPAIGN_IDS.contains($0.id) }
        } catch {
            dataLogger.error("Failed to fetch stored fundraisers: \(error.localizedDescription)")
        }
    }
}

private extension RandomCampaignPickerView {
    func getRandomCampaign() -> Campaign {
        while true {
            if let random = allCampaigns.randomElement(), random.id != RELAY_CAMPAIGN {
                return random
            }
        }
    }
    
    func playAnimation() {
        withAnimation(.timingCurve(0.37, 0, 0.25, 1, duration: animationDuration)) {
            
            let segmentWidth = 360.0 / Double(wedgeCount)
            
            // Pick a random number of segments to move round the wheel
            let numberOfSegmentsToSpin = Int.random(in: 0...14)
            
            // Spin four times round the wheel, then the previous random number
            let angleDegrees = wheelRotation.degrees + (segmentWidth * Double((4 * wedgeCount) + numberOfSegmentsToSpin))
            
            // Clockwise spinning makes the numbers go in reverse, so subtract the number of segments we're moving by
            // from the current segment, handling the wraparound below zero
            var newSegmentIndex = indexToFlip - numberOfSegmentsToSpin
            if newSegmentIndex < 0 {
                newSegmentIndex = wedgeCount + newSegmentIndex
            }
            
            indexToFlip = newSegmentIndex
            wheelRotation = Angle(degrees: Double(angleDegrees))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+animationDuration, execute: {
#if !os(macOS)
            bounceHaptics.impactOccurred(intensity: 1)
#endif
            withAnimation(.spring()) {
                animationFinished = true
            }
        })
    }
    
    struct WidthPreferenceKey: PreferenceKey {
        static let defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
}
