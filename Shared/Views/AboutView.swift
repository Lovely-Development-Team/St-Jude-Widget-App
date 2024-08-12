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
        ScrollView {
            VStack(spacing:0) {
                AboutViewHeader()
                VStack {
                    GroupBox {
                        VStack {
                            Text("About St. Jude")
                                .font(.title3)
                                .fullWidth()
                            Text("The mission of St. Jude Children’s Research Hospital is to advance cures, and means of prevention, for paediatric catastrophic diseases through research and treatment. Consistent with the vision of our founder Danny Thomas, no child is denied treatment based on race, religion or a family’s ability to pay.")
                                .fullWidth()
                                .padding(.top)
                            Text("Every year throughout the month of September, Relay raises money for St. Jude to help continue its mission. Read more about the reason why, and this year's fundraiser, over at 512pixels.net.")
                                .fullWidth()
                                .padding(.top)
                            Link(destination: URL(string: "https://512pixels.net/2024/08/relay-st-jude-2024/")!) {
                                Text("Read Stephen's post")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .fullWidth(alignment: .center)
                            }
                            .buttonStyle(BlockButtonStyle(tint: .accentColor))
                            .padding(.top)
                        }
                    }
                    .groupBoxStyle(BlockGroupBoxStyle())
                    
                    GroupBox {
                        VStack {
                            Text("About the app")
                                .font(.title3)
                                .fullWidth()
                            Text("This app was developed by a group of friends from around the world, who came together thanks to Relay's membership program.")
                                .fullWidth()
                                .padding(.top)
                            Link(destination: URL(string: "https://tildy.dev/")!, label: {
                                Text("tildy.dev")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .fullWidth(alignment: .center)
                            })
                            .buttonStyle(BlockButtonStyle(tint: .accentColor))
                            .padding(.top)
                            Text("Our thanks go to everybody who donates to St. Jude via our fundraiser.")
                                .fullWidth()
                                .padding(.top)
                            Button(action: {
                                showSupporterSheet = true
                            }) {
                                Text("Supporters")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .fullWidth(alignment: .center)
                            }
                            .buttonStyle(BlockButtonStyle(tint: .accentColor))
                            .padding(.top)
                        }
                    }
                    .groupBoxStyle(BlockGroupBoxStyle())
                    
                }
                .padding()
                .padding(.bottom, 60)
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
        .overlay(alignment: .bottomTrailing) {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Image(systemName: "xmark")
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

struct AboutViewHeader: View {
    @Environment(\.colorScheme) var colorScheme
    @State var cloudMoved: Bool = false
    var body: some View {
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
                AdaptiveImage.cloud(colorScheme: self.colorScheme)
                    .imageAtScale(scale: Double.spriteScale)
                    .offset(y: -(Double.spriteScale * 450))
                    .offset(x: cloudMoved ? -1000 : 200)
            }
            .onAppear {
                withAnimation(.linear(duration: 250)) {
                    cloudMoved = true
                }
            }
        }
    }
}
