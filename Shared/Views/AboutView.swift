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
        VStack {
            Image("Banner")
                .resizable()
                .aspectRatio(contentMode: .fit)
            ScrollView {
                VStack(spacing: 20) {
                    Text("The mission of St. Jude Children’s Research Hospital is to advance cures, and means of prevention, for paediatric catastrophic diseases through research and treatment. Consistent with the vision of our founder Danny Thomas, no child is denied treatment based on race, religion or a family’s ability to pay.")
                        .padding()
                        .foregroundStyle(Color.white)
                        .background(Color(red: 28 / 255, green: 28 / 255, blue: 30 / 255))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    Text("Every year throughout the month of September, Relay FM raises money for St. Jude to help continue its mission. Read more about the reason why, and this year's fundraiser, over at 512pixels.net.")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.white)
                    Link(destination: URL(string: "https://512pixels.net/2023/08/relay-fm-st-jude-2023/")!) {
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
                        .foregroundStyle(.white)
                    Text("This app was developed by a group of friends from around the world, who came together thanks to Relay FM's membership program.")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.white)
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
                        Spacer()
                        Link("tildy.dev", destination: URL(string: "https://tildy.dev")!)
                        Spacer()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding(.top, -180)
        }
        .overlay(alignment: .topTrailing) {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Image(systemName: "xmark")
                    .foregroundStyle(Color.white)
                    .padding([.all], 7)
                    .background(Color.gray.opacity(0.75))
                    .clipShape(Circle())
                    .shadow(radius: 5)
            })
            .padding()
        }
        .background(.black)
        .sheet(isPresented: $showSupporterSheet) {
            SupporterView()
        }
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button(action: {
//                    presentationMode.wrappedValue.dismiss()
//                }) {
//                    Text("Done")
//                }
//            }
//        }
//        .navigationTitle("About Relay FM for St. Jude")
        .navigationBarTitleDisplayMode(.inline)
//        .preferredColorScheme(.dark)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AboutView()
        }
    }
}
