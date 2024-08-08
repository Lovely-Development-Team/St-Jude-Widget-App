//
//  AboutView.swift
//  St Jude
//
//  Created by Ben Cardy on 01/09/2022.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @State private var showSupporterSheet: Bool = false
    
    @State private var backgroundColor: Color = .black
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing:0) {
                    VStack {
                        Image(.bannerForeground)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.bottom)
                        AdaptiveImage.groundRepeatable(colorScheme: self.colorScheme)
                            .tiledImageAtScale(axis: .horizontal)
                    }
                    .background {
                        ZStack(alignment: .bottom) {
                            Color.skyBackground
                            AdaptiveImage(colorScheme: self.colorScheme, light: .skyRepeatable, dark: .skyRepeatableNight)
                                .tiledImageAtScale(scale: Double.spriteScale, axis: .horizontal)
                                .animation(.none, value: UUID())
                        }
                    }
                    VStack {
                        GroupBox {
                            VStack() {
                                Text("About St. Jude")
                                    .font(.title3)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                Text("The mission of St. Jude Children’s Research Hospital is to advance cures, and means of prevention, for paediatric catastrophic diseases through research and treatment. Consistent with the vision of our founder Danny Thomas, no child is denied treatment based on race, religion or a family’s ability to pay.")
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                //                            .padding()
                                //                        .background(Color(uiColor: .systemGroupedBackground))
                                //                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                Text("Every year throughout the month of September, Relay raises money for St. Jude to help continue its mission. Read more about the reason why, and this year's fundraiser, over at 512pixels.net.")
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical)
                                Link(destination: URL(string: "https://512pixels.net/2024/08/relay-st-jude-2024/")!) {
                                    Text("Read Stephen's post")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                    //                                .padding(10)
                                    //                                .padding(.horizontal, 20)
                                    //                                .background(Color.accentColor)
                                    //                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                    //                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                }
                                .buttonStyle(BlockButtonStyle(tint: .accentColor))
                                //                        Text("Our thanks go to everybody who donates to St. Jude via our fundraiser:")
                                //                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                //                        Button(action: {
                                //                            showSupporterSheet = true
                                //                        }) {
                                //                            Text("Supporters")
                                //                                .font(.headline)
                                //                                .foregroundColor(.white)
                                //                                .padding(10)
                                //                                .padding(.horizontal, 20)
                                //                                .background(Color.accentColor)
                                //                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                //                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                //                        }
                                //                        HStack {
                                //                            Spacer()
                                //                            Link("tildy.dev", destination: URL(string: "https://tildy.dev")!)
                                //                            Spacer()
                                //                        }
                            }
                        }
                        .groupBoxStyle(BlockGroupBoxStyle())
                        
                        GroupBox {
                            VStack {
                                Text("About the app")
                                    .font(.title3)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                Text("This app was developed by a group of friends from around the world, who came together thanks to Relay's membership program.")
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                Link(destination: URL(string: "https://tildy.dev/")!, label: {
                                    Text("tildy.dev")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                })
                                .buttonStyle(BlockButtonStyle(tint: .accentColor))
                            }
                        }
                        .groupBoxStyle(BlockGroupBoxStyle())
                    }
                    .padding()
                    .padding(.bottom, 60)
                    .background {
                        GeometryReader { geometry in
                            AdaptiveImage.undergroundRepeatable(colorScheme: self.colorScheme)
                                .tiledImageAtScale()
                                .frame(height: geometry.size.height+1000)
                        }
                    }
                }
            }
        }
        .background {
            Color.skyBackground
        }
        .background(ignoresSafeAreaEdges: .all)
        .overlay(alignment: .bottomTrailing) {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Image(systemName: "xmark")
//                    .imageScale(.large)
//                    .foregroundStyle(Color.gray.opacity(0.75))
//                    .padding([.all], 7)
//                    .background(Color.gray.opacity(0.75))
//                    .clipShape(Circle())
//                    .shadow(radius: 5)
            })
            .buttonStyle(BlockButtonStyle())
            .padding()
        }
        .sheet(isPresented: $showSupporterSheet) {
            SupporterView()
        }
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
