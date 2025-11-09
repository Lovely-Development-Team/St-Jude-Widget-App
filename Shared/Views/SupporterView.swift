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
    @Environment(\.dismiss) var dismiss
    @StateObject var fetch = FetchSupporters()
    
    @AppStorage(UserDefaults.selectedAccentColorKey, store: UserDefaults.shared) private var selectedAccentColorKey = 0
    
    @State private var animate = false
    @State private var animationType: Animation? = .none
    @State private var showSupporterSheet: Bool = false
    #if !os(macOS)
    let bounceHaptics = UIImpactFeedbackGenerator(style: .light)
    #endif
    
    @ViewBuilder
    var topView: some View {VStack(spacing: 0) {
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
                    .foregroundColor(.black)
                    .fullWidth(alignment: .center)
            })
            .buttonStyle(PrimaryButtonStyle())
            .padding(.bottom, 30)
        }
        .padding()
    }
    .foregroundColor(.white)
    }
    
    @ViewBuilder
    var supportersListView: some View {
        let supporters = fetch.supporters
        VStack {
            if (supporters.count > 0) {
                //                    ScrollView {
                GroupBox {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 0) {
                        ForEach(supporters, id: \.self) { supporter in
                            Text(supporter)
                                .multilineTextAlignment(.center)
                                .padding(4)
                        }
                    }
                }
                //                    }
            } else {
                GroupBox {
                    ProgressView()
                        .padding(.top, 40)
                    Text("Loading ...")
                        .fullWidth(alignment: .center)
                        .padding(.bottom, 40)
                }
            }
            Button(action: {
                self.dismiss()
            }, label: {
                Text("Close")
                    .font(.headline)
                    .foregroundColor(.black)
                    .fullWidth(alignment: .center)
            })
            .buttonStyle(PrimaryButtonStyle())
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
                Image(.l2Cu)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .offset(x: 0, y: animate ? -5 : 0)
                    .animation(animate ? .easeInOut(duration: 0.15).repeatForever(autoreverses: true) : animationType)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                self.topView
                self.supportersListView
            }
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

