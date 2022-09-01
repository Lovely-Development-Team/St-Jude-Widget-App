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
    
    var body: some View {
        let supporters = fetch.supporters
        if (supporters.count > 0) {
            VStack {
                Text("Supporters")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Our thanks to these awesome people for donating $10 or more to our fundraiser:")
                    .padding(.top, 2)
                    .padding(.bottom, 10)
                    .multilineTextAlignment(.center)
                ScrollView {
                    ForEach(supporters.indices) {
                        Text(supporters[$0])
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(2)
                    }
                }
                
            }
            .padding(10)
        }
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

