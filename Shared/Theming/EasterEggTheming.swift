//
//  EasterEggTheming.swift
//  St Jude
//
//  Created by Justin Hamilton on 9/10/26.
//

import SwiftUI

extension Theme {
    
    @ViewBuilder
    func viewForEasterEggString(string: String) -> some View {
        switch string.lowercased() {
        case "jonycube", "jony cube":
            Image(.jonycube)
                .resizable()
                .aspectRatio(contentMode: .fit)
        case "l2cu":
            Image(Theme.current.mascotImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        case "grey":
            Image(.bsod)
                .resizable()
                .aspectRatio(contentMode: .fit)
        default:
            EmptyView()
        }
        
        switch self {
        case .campaign2026:
            if string.lowercased() == "clementine" {
                FeedClementineView()
            }
        default:
            EmptyView()
        }
    }
}

// MARK: - 2026 Easter Egg Views
struct FeedClementineView: View {
    @State private var animating: Bool = false
    @State private var animationType: Animation? = .none
    @State private var animationTimer: Timer?
    @State private var animationDuration = 1.0
    @State private var isPetting = false
    @State private var pettingAnimationType: Animation? = .none
    
    @ViewBuilder
    var chickenView: some View {
        Image(.friedChicken)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 150)
    }
    
    @ViewBuilder
    var cottonCandyView: some View {
        Image(.cottonCandy)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 150)
    }
    
    var petGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if !self.isPetting {
                    self.isPetting = true
                    self.pettingAnimationType = .default
                }
                if Int.random(in: 0...2) == 1 || abs(value.velocity.width + value.velocity.height)/2 > 100 {
                    self.particleSystem.addParticle(at: value.location)
                }
            }
            .onEnded { _ in
                self.isPetting = false
                self.pettingAnimationType = .default
                SoundEffectHelper.shared.play(.horseRandom, allowOverlap: true)
            }
    }
    
    @State private var particleSystem = ParticleSystem()
    
    struct Particle: Hashable {
        let x: Double
        let y: Double
        let hue: Double = Double.random(in: 0...1)
        var initialScale: Double = .random(in: 2...4)
        var initialRotation: Double = .random(in: -90...90)
        var rotationDirection: Double = Bool.random() ? 1.0 : -1.0
        let creationDate = Date.timeIntervalSinceReferenceDate
    }
    
    class ParticleSystem {
        let image = Image(.star)
        var particles = Set<Particle>()
        
        let lifespan: Double = 1
        
        func addParticle(at location: CGPoint) {
            let newParticle = Particle(x: location.x, y: location.y)
            self.particles.insert(newParticle)
        }
        
        func update(date: TimeInterval) {
            let deathDate = date - lifespan
            for particle in self.particles {
                if particle.creationDate < deathDate {
                    self.particles.remove(particle)
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            Group {
                Image(.unicorn2026)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
                .rotationEffect(.degrees(self.isPetting ? 2 : 0), anchor: .center)
                .animation(self.isPetting ? .easeInOut(duration: 0.25).repeatForever(autoreverses: true) : self.pettingAnimationType,
                           value: self.isPetting)
                .offset(x: 0, y: self.animating ? -5 : 0)
                .animation(self.animating ? .easeInOut(duration: 0.15).repeatForever(autoreverses: true) : self.animationType,
                           value: self.animating)
                .overlay {
                    TimelineView(.animation) { timeline in
                        Canvas { context, size in
                            let timelineDate = timeline.date.timeIntervalSinceReferenceDate
                            self.particleSystem.update(date: timelineDate)
                            
                            for particle in self.particleSystem.particles {
                                context.drawLayer { layer in
                                    layer.translateBy(x: particle.x, y: particle.y)
                                    let degrees = (timelineDate - particle.creationDate) * 50 * particle.rotationDirection
                                    layer.rotate(by: .degrees(degrees))
                                    let scale = 0.5 + (timelineDate - particle.creationDate)
                                    layer.scaleBy(x: scale, y: scale)
                                    layer.opacity = 1 - (timelineDate - particle.creationDate)
                                    layer.blendMode = .plusLighter
                                    layer.addFilter(.colorMultiply(Color(hue: particle.hue, saturation: 1, brightness: 1)))
                                    
                                    layer.draw(self.particleSystem.image, at: .zero)
                                }
                            }
                        }
                    }
                    .gesture(self.petGesture)
                    .dropDestination(for: String.self, action: { items, location in
                        SoundEffectHelper.shared.play(.horseRandom, allowOverlap: true)
                        self.animationTimer?.invalidate()
                        withAnimation {
                            self.animating = true
                            self.animationType = .default
                            self.animationTimer = Timer.scheduledTimer(withTimeInterval: self.animationDuration, repeats: false, block: {_ in
                                self.animating = false
                            })
                        }
                        return true
                    })
                }
            HStack {
                Spacer()
                self.chickenView
                    .draggable("friedChicken")
                Spacer()
                self.cottonCandyView
                    .draggable("cottonCandy")
                Spacer()
            }
        }
    }
}

#Preview {
    FeedClementineView()
}
