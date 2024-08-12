//
//  SupporterView.swift
//  St Jude
//
//  Created by Matthew Cooksey on 8/31/22.
//

import SwiftUI

class FetchSupporters: ObservableObject {
    @Published var supporters = [String]()
    init() {
            let supporterUrl = URL(string: "https://raw.githubusercontent.com/Lovely-Development-Team/St-Jude-Widget-App/main/supporters.json")!
            URLSession.shared.dataTask(with: supporterUrl) {(data, response, error) in
                do {
                    if let supporterData = data {
                        let decodedData = try JSONDecoder().decode(Supporter.self, from: supporterData)
                        DispatchQueue.main.async {
                            self.supporters = decodedData.supporters
                        }
                    } else {
                        print("No data")
                    }
                } catch {
                    print(error)
                }
            }.resume()
    }
}

struct SupporterView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var fetch = FetchSupporters()
    
    @State private var animate = false
    @State private var animationType: Animation? = .none
    @State private var showSupporterSheet: Bool = false
    #if !os(macOS)
    let bounceHaptics = UIImpactFeedbackGenerator(style: .light)
    #endif
    
    var body: some View {
        let supporters = fetch.supporters
        ScrollView {
            VStack(spacing: 0) {
                VStack {
                    Text("Supporters")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top)
                    Text("Our thanks to these awesome people for donating to our fundraiser!")
                        .padding(.top, 2)
                        .padding(.bottom, 10)
                        .multilineTextAlignment(.center)
                    Link(destination: URL(string: "https://tildy.dev/stjude")!, label: {
                        Text("tildy.dev/stjude")
                            .font(.headline)
                            .foregroundColor(.white)
                            .fullWidth(alignment: .center)
                    })
                    .buttonStyle(BlockButtonStyle(tint: .accentColor))
                    .padding(.bottom, 30)
                }
                .padding()
                .background {
                    ZStack(alignment: .bottom) {
                        Color.skyBackground
                        AdaptiveImage(colorScheme: self.colorScheme, light: .skyRepeatable, dark: .skyRepeatableNight)
                            .tiledImageAtScale(scale: Double.spriteScale, axis: .horizontal)
                            .animation(.none, value: UUID())
                        AdaptiveImage.groundRepeatable(colorScheme: self.colorScheme)
                            .tiledImageAtScale(axis: .horizontal)
                    }
                }
                VStack {
                    if (supporters.count > 0) {
                        //                    ScrollView {
                        GroupBox {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 0) {
                                ForEach(supporters.indices) {
                                    Text(supporters[$0])
                                        .multilineTextAlignment(.center)
                                        .padding(4)
                                }
                            }
                        }
                        .groupBoxStyle(BlockGroupBoxStyle())
                        Button(action: {
                            withAnimation {
#if !os(macOS)
                                bounceHaptics.impactOccurred()
#endif
                                self.animate.toggle()
                                self.animationType = .default
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.animate.toggle()
                            }
                        }) {
                            Image("Team_Logo_F")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 200)
                                .padding()
                                .offset(x: 0, y: animate ? -5 : 0)
                                .animation(animate ? .easeInOut(duration: 0.15).repeatForever(autoreverses: true) : animationType)
                        }
                        .buttonStyle(PlainButtonStyle())
                        //                    }
                    } else {
                        GroupBox {
                            ProgressView()
                                .padding(.top, 40)
                            Text("Loading ...")
                                .fullWidth(alignment: .center)
                                .padding(.bottom, 40)
                        }
                        .groupBoxStyle(BlockGroupBoxStyle())
                    }
                    Spacer()
                }
                .padding()
                .background {
                    GeometryReader { geometry in
                        AdaptiveImage(colorScheme: self.colorScheme, light: .undergroundRepeatable, dark: .undergroundRepeatableNight)
                            .tiledImageAtScale(scale: Double.spriteScale)
                            .frame(height:geometry.size.height + 1000)
                            .animation(.none, value: UUID())
                    }
                }
            }
        }
        .background {
            Color.skyBackground
        }
        .background(ignoresSafeAreaEdges: .all)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SupporterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SupporterView()
        }
    }
}

struct Supporter: Decodable {
    let supporters: [String]
}

