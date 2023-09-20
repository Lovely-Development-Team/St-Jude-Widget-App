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
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var campaignChoiceID: UUID?
    @State var allCampaigns: [Campaign]
    @State var chosenCampaign: Campaign?
    
    @State private var animationDuration: Double = 2.25
    
    @State private var wheelRotation: Angle = .degrees(0)
    
    @State private var indexToFlip: Int = 0
    @State private var animationFinished: Bool = false
    @State private var isResetting: Bool = false
        
#if !os(macOS)
    let bounceHaptics = UIImpactFeedbackGenerator(style: .light)
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
#endif
    
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
    
    @State var wheelRadius: Double = 300
    @State var wedgeCount = 14
    
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
            SoundEffectHelper.shared.playDrumrollSoundEffect()
        })
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Image(.confetti)
                .resizable()
                .scaleEffect(animationFinished ? CGSize(width: 3.0, height: 1.0) : .zero)
                .opacity(animationFinished || isResetting ? 0 : 1)
            VStack {
                Text("Wheel of Fundraisers")
                    .font(.largeTitle)
                    .bold()
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
                                .foregroundColor(.white)
                                .padding(10)
                                .padding(.horizontal, 20)
                                .background(Color.accentColor)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        })
                        Spacer()
                        Button(action: spinAgain, label: {
                            Text("Spin Again")
                        })
                    }
                }
            }
            .padding([.bottom], wheelRadius*1.25)
        }
        .background(BrandShapeBackground())
        .overlay(alignment:.bottom) {
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
                ZStack {
                    Image(.fullSizeAppIcon)
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
            .rotationEffect(wheelRotation)
            .padding([.bottom], -wheelRadius*(animationFinished ? 0.8 : 0.9))
            .onTapGesture {
                if animationFinished {
                    spinAgain()
                }
            }
        }
        .overlay(alignment: .bottomLeading) {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Image(systemName: "xmark")
                    .foregroundStyle(Color.white)
                    .padding(7)
                    .background(Color.gray.opacity(0.5))
                    .clipShape(Circle())
                    .shadow(radius: 5)
            })
        }
        .background {
            GeometryReader { geo in
                Color.clear.preference(key: Self.WidthPreferenceKey.self, value: geo.size.width)
            }
        }
        .onPreferenceChange(Self.WidthPreferenceKey.self) { value in
            self.wheelRadius = min((1.5 * value) / 2.0, 300)
        }
        .padding()
        .onAppear {
            chosenCampaign = getRandomCampaign()
            playAnimation()
            SoundEffectHelper.shared.playDrumrollSoundEffect()
        }
#if !os(macOS)
        .onReceive(timer) { _ in
            if !animationFinished && !isResetting {
                bounceHaptics.impactOccurred()
            }
        }
#endif
    }
}

private extension RandomCampaignPickerView {
    struct WidthPreferenceKey: PreferenceKey {
        static let defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
}

struct WheelWedgeView: View {
    @Environment(\.presentationMode) var presentationMode
    var index: Int
    @Binding var isTimeToFlip: Bool
    @Binding var campaign: Campaign?
    @Binding var campaignChoiceID: UUID?
    var shouldFlip: Bool
    
    @ViewBuilder
    func image() -> some View {
        if let campaign = campaign, let url = URL(string: campaign.avatar?.src ?? "") {
            KFImage.url(url)
                .resizable()
                .placeholder {
                    ProgressView()
                }
                .aspectRatio(contentMode: .fit)
                .cornerRadius(5)
                .onTapGesture {
                    campaignChoiceID = campaign.id
                    presentationMode.wrappedValue.dismiss()
                }
        } else {
            EmptyView()
        }
    }
    
    let colors: [Color] = [
        .brandRed,
        .brandYellow,
        .brandBlue,
        .brandGreen,
        .brandPurple,
    ]
    
    var body: some View {
        Triangle()
            .foregroundStyle(colors[index % colors.count])
            .overlay {
                ZStack {
                    if(shouldFlip && isTimeToFlip) {
                        VStack {
                            image()
                                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                                .padding()
                                .padding()
                            Spacer()
                        }
                    }
                    Triangle()
                        .stroke(.black, lineWidth: 2)
                }
            }
            .rotation3DEffect(.degrees(shouldFlip && isTimeToFlip ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            .animation(.easeInOut, value: isTimeToFlip)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        
        return path
    }
}

struct WheelLayout: Layout {
    var radius: Double
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        return proposal.replacingUnspecifiedDimensions()
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let angle: Double = (2 * Double.pi) / Double(subviews.count)
        
        // apple sample code is the best thank you big tim
        
        for (index, subview) in subviews.enumerated() {
            // Find a vector with an appropriate size and rotation.
            var point = CGPoint(x: 0, y: -radius/2)
                .applying(CGAffineTransform(
                    rotationAngle: angle * Double(index)))
            
            
            // Shift the vector to the middle of the region.
            point.x += bounds.midX
            point.y += bounds.midY
            
            
            // Place the subview.
            subview.place(at: point, anchor: .center, proposal: .unspecified)
        }
        
    }

}
