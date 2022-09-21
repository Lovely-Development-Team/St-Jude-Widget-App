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
    @StateObject var fetch = FetchSupporters()
    
    @State private var animate = false
    @State private var animationType: Animation? = .none
    @State private var showSupporterSheet: Bool = false
    #if !os(macOS)
    let bounceHaptics = UIImpactFeedbackGenerator(style: .light)
    #endif
    
    var body: some View {
        let supporters = fetch.supporters
        VStack {
            Text("Supporters")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)
            Text("Our thanks to these awesome people for donating to our fundraiser!")
                .padding(.top, 2)
                .padding(.bottom, 10)
                .multilineTextAlignment(.center)
            Link("tildy.dev/stjude", destination: URL(string: "https://tildy.dev/stjude")!)
                .padding(.top, -5)
                .padding(.bottom, 10)
                .allowsTightening(true)
                .minimumScaleFactor(0.7)
                .font(.body)
                .foregroundColor(.blue)
                .buttonStyle(PlainButtonStyle())
            if (supporters.count > 0) {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 0) {
                        ForEach(supporters.indices) {
                            Text(supporters[$0])
                                .padding(4)
                        }
                    }
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
                }
            } else {
                ProgressView()
                    .padding(.top, 40)
                    .padding(.bottom, 10)
                Text("Loading ...")
                    .padding(.bottom, 40)
            }
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding(10)
        .background(Color.secondarySystemBackground)
        .edgesIgnoringSafeArea(.all)
    }
}

struct SupporterView_Previews: PreviewProvider {
    static var previews: some View {
        SupporterView()
    }
}

struct Supporter: Decodable {
    let supporters: [String]
}

