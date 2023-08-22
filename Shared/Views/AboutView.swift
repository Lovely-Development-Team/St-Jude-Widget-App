//
//  AboutView.swift
//  St Jude
//
//  Created by Ben Cardy on 01/09/2022.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showSupporterSheet: Bool = false
    var body: some View {
        ScrollView {
            Image("Banner")
                .resizable()
                .aspectRatio(contentMode: .fit)
            Group {
                GroupBox {
                    Text("The mission of St. Jude Children’s Research Hospital is to advance cures, and means of prevention, for pediatric catastrophic diseases through research and treatment. Consistent with the vision of our founder Danny Thomas, no child is denied treatment based on race, religion or a family’s ability to pay.")
                }
                .padding(.top, -40)
                .padding(.top)
                Text("Every year throughout the month of September, Relay FM raises money for St. Jude to help continue its mission. Read more about the reason why, and this year's fundraiser, over at 512pixels.net.")
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                Link(destination: URL(string: "https://512pixels.net/2022/08/relay-st-jude-2022/")!) {
                    Text("Read Stephen's post")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(10)
                        .padding(.horizontal, 20)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                }
                Divider()
                Text("About the app")
                    .font(.headline)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                Text("This app was developed by a group of friends from around the world, who came together thanks to Relay FM's membership program.")
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
//                Text("Our thanks go to everybody who donates to St. Jude via our fundraiser:")
//                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
//                Button(action: {
//                    showSupporterSheet = true
//                }) {
//                    Text("Supporters")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .padding(10)
//                        .padding(.horizontal, 20)
//                        .background(Color.accentColor)
//                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
//                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
//                }
                HStack {
//                    Spacer()
//                    Link("tildy.dev/stjude", destination: URL(string: "https://tildy.dev/stjude")!)
                    Spacer()
                    Link("tildy.dev", destination: URL(string: "https://tildy.dev")!)
                    Spacer()
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .sheet(isPresented: $showSupporterSheet) {
            SupporterView()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Done")
                }
            }
        }
        .navigationTitle("About Relay FM for St. Jude")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AboutView()
        }
    }
}
