//
//  RandomCampaignPickerView.swift
//  St Jude
//
//  Created by Justin Hamilton on 9/17/23.
//

import SwiftUI
import AVKit

struct RandomCampaignPickerView: View {
    @Binding var isPresented: Bool
    @Binding var campaignChoiceID: UUID?
    @State var allCampaigns: [Campaign]
    
    @State private var displayedCampaigns: [Campaign] = []
    
    @State private var animationTimer: Timer? = nil
    
    @State private var animationDuration: Double = 0.75
    
    @State private var listAlignment: Alignment = .top
    
    @State private var totalAnimationLength: Double = 3.0
    
    @State private var audioPlayer: AVAudioPlayer? = nil
    
    @State private var wheelRotation: Angle = .degrees(0)
    
    func playSoundEffect() {
        do {
            if let url = Bundle.main.url(forResource: "drumroll", withExtension: "mp3") {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer!.prepareToPlay()
                audioPlayer!.play()
            }
        } catch {
            print(error)
        }
    }
    
    var linearLoopCount: Int {
        return Int((totalAnimationLength - (animationDuration * 2)) / animationDuration)
    }
    
    func getRandomCampaign() -> Campaign {
        while true {
            if let random = allCampaigns.randomElement(), random.id != RELAY_CAMPAIGN, !displayedCampaigns.contains(where: { $0.id == random.id }) {
                return random
            }
        }
    }
    
    func getRandomCampaigns() -> [Campaign] {
        if let lastCampaign = displayedCampaigns.last {
            let newRandomCampaigns = (0..<4).map { _ in
                return getRandomCampaign()
            }
            
            var newDisplayedCampaigns = [lastCampaign]
            newDisplayedCampaigns.append(contentsOf: newRandomCampaigns)
            
            return newDisplayedCampaigns
        } else {
            return (0..<5).map { _ in
                return getRandomCampaign()
            }
        }
    }
     
    @State var animationLoopIndex: Int = 0
    
    func tickTimer() {
        displayedCampaigns = getRandomCampaigns()
        animationLoopIndex+=1
        
        var animation: Animation = .linear(duration: animationDuration)
        
        if(animationLoopIndex == 1) {
            animation = Animation.timingCurve(0.25, 0, 0.5, 0.5, duration: animationDuration)
//            animation = .easeIn(duration: animationDuration)
        } else if(animationLoopIndex == linearLoopCount+2) {
            animation = Animation.timingCurve(0.25, 0.25, 0.5, 1, duration: animationDuration)
//            animation = .easeOut(duration: animationDuration)
            animationTimer?.invalidate()
            
            DispatchQueue.main.asyncAfter(deadline: .now()+animationDuration, execute: {
                campaignChoiceID = displayedCampaigns.last!.id
//                isPresented = false
            })
        }
        
//        listAlignment = .top
        wheelRotation = .degrees(0)
        withAnimation(animation, {
            wheelRotation = .degrees(360)
//            listAlignment = .bottom
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
    
    var body: some View {
        VStack {
            Spacer()
            Text("fundraiser title")
                .font(.largeTitle)
            Text("fundraiser username")
                .font(.subheadline)
            Spacer()
            WheelLayout(radius: wheelRadius) {
                ForEach(0..<wedgeCount) { index in
                    WheelWedgeView(index: index)
                        .frame(width: sectionWidth, height: wheelRadius)
                        .rotationEffect(Angle(degrees: (360/Double(wedgeCount))*Double(index)))
                }
            }
            .frame(width: wheelRadius*2, height: wheelRadius*2)
            .clipShape(Circle())
            .overlay {
                ZStack {
                    Image(uiImage: UIImage(named: "AppIcon")!)
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
            .padding([.bottom], -wheelRadius*0.9)
        }
        .onAppear {
            playSoundEffect()
            tickTimer()
            animationTimer = Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: true, block: {_ in tickTimer() })
        }
        .interactiveDismissDisabled()
    }
}

struct WheelWedgeView: View {
    var index: Int
    
    var body: some View {
        Triangle()
            .foregroundStyle(index % 2 == 0 ? WidgetAppearance.stjudeRed : WidgetAppearance.relayYellow)
            .overlay {
                ZStack {
                    VStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding()
                            .padding([.leading, .trailing])
                        Spacer()
                    }
                    Triangle()
                        .stroke(.black, lineWidth: 2)
                }
            }
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
