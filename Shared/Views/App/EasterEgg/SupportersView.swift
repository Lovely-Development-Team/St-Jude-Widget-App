//
//  SupportersView.swift
//  St Jude
//
//  Created by Matthew Cooksey on 8/31/22.
//

import SwiftUI

struct SupportersView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @State private var supporters: [String] = []
    
    @ViewBuilder
    var topView: some View {
        GroupBox {
            Text("Our thanks to these awesome people for donating to our fundraiser!")
                .padding(.top, 2)
                .padding(.bottom, 10)
                .multilineTextAlignment(.center)
            Link(destination: URL(string: "https://tildy.dev/stjude")!, label: {
                Text("tildy.dev/stjude")
                    .font(.headline)
                    .fullWidth(alignment: .center)
            })
            .themedButton(type: .primary)
        }
    }
    
    @ViewBuilder
    var supportersListView: some View {
        VStack {
            if (self.supporters.count > 0) {
                GroupBox {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 0) {
                        ForEach(self.supporters, id: \.self) { supporter in
                            Text(supporter)
                                .multilineTextAlignment(.center)
                                .padding(4)
                        }
                    }
                }
            } else {
                GroupBox {
                    ProgressView()
                    Text("Loading ...")
                        .fullWidth(alignment: .center)
                        .padding(.bottom, 40)
                }
            }
        }
    }
    
    @ViewBuilder
    var mascotView: some View {
        Image(.l2Cu)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .tapToAnimate(jumpHeight: 5)
            .padding()
    }
    
    var body: some View {
        ScrollView {
            VStack {
                self.topView
                self.supportersListView
                self.mascotView
            }
            .padding(.horizontal)
        }
        .background(ignoresSafeAreaEdges: .all)
        .navigationTitle("Supporters")
        .toolbar {
            ToolbarItem(placement: .cancellationAction, content: {
                Button(action: {
                    self.dismiss()
                }, label: {
                    Image(systemName: "xmark")
                })
            })
        }
        .onAppear {
            self.fetchSupporters()
        }
    }
}

extension SupportersView {
    struct Supporter: Decodable {
        let supporters: [String]
    }
    
    private func fetchSupporters() {
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

struct SupportersView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SupportersView()
        }
    }
}
