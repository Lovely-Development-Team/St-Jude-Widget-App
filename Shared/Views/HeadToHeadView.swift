//
//  HeadToHeadView.swift
//  St Jude
//
//  Created by Ben Cardy on 29/08/2023.
//

import SwiftUI
import Kingfisher

let HEAD_TO_HEAD_COLOR_1 = WidgetAppearance.red
let HEAD_TO_HEAD_COLOR_2 = WidgetAppearance.purple

struct HeadToHeadView: View {
    @Environment(\.presentationMode) var presentationMode

    @State var campaign1: Campaign
    @State var campaign2: Campaign
    
    @State private var animateIn: Bool = false
    
    init(campaign1: Campaign, campaign2: Campaign) {
        _campaign1 = State(wrappedValue: campaign1)
        _campaign2 = State(wrappedValue: campaign2)
    }
    
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var progressBarValue: Float {
        let denominator = campaign1.totalRaisedNumerical + campaign2.totalRaisedNumerical
        guard denominator > 0 else { return 0.5 }
        return Float(campaign1.totalRaisedNumerical / denominator)
    }

    var highestTotal: Double {
        max(campaign1.totalRaisedNumerical, campaign2.totalRaisedNumerical)
    }

    func distanceFromWin(for campaign: Campaign) -> Double {
        return highestTotal - campaign.totalRaisedNumerical
    }

    @ViewBuilder
    func image(for campaign: Campaign, size: CGFloat = 75) -> some View {
        if let url = URL(string: campaign.avatar?.src ?? "") {
            KFImage.url(url)
                .resizable()
                .placeholder {
                    ProgressView()
                        .frame(width: size, height: size)
                }
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .cornerRadius(5)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    func campaignDetails(for campaign: Campaign, alignment: TextAlignment) -> some View {
        ZStack(alignment: alignment == .leading ? .topTrailing : .topLeading) {
            HStack(alignment: .top) {
                if alignment == .leading {
                    image(for: campaign)
                } else {
                    Spacer()
                }
                Text(campaign.title)
                    .multilineTextAlignment(alignment)
                    .font(.title2)
                    .bold()
                if alignment == .trailing {
                    image(for: campaign)
                } else {
                    Spacer()
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity)
        }
    }
    
    @State private var animateMyke = false
    @State private var animateStephen = false
    #if !os(macOS)
    let bounceHaptics = UIImpactFeedbackGenerator(style: .light)
    let selectionHaptics = UISelectionFeedbackGenerator()
    #endif

    var body: some View {
        VStack(spacing: 0) {
            VStack {
                if animateIn {
                    Text("Fundraiser")
                        .padding(.top, 5)
                    Text("Head to Head!")
                }
//                Rectangle().fill(.white).frame(height: 2)
            }
            .font(.title)
            .bold()
//            .foregroundColor(HEAD_TO_HEAD_COLOR_1.foregroundColor)
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(minHeight: 105)
            .overlay(
                HStack {
                    if animateIn {
                        Image("myke")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        .frame(height: 110)
                        .offset(y: 5)
                        .onTapGesture {
                            withAnimation {
                                #if !os(macOS)
                                bounceHaptics.impactOccurred()
                                #endif
                                self.animateMyke.toggle()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.animateMyke.toggle()
                            }
                        }
                        .offset(x: 0, y: animateMyke ? -5 : 0)
                        .animation(animateMyke ? .easeInOut(duration: 0.15).repeatForever(autoreverses: true) : .default, value: animateMyke)
                        .background(
                            VStack {
                                Spacer()
                                Ellipse()
                                    .fill(.black)
                                    .frame(height: 5)
                                    .blur(radius: 10)
                                    .opacity(0.8)
                            }
                        )
                        .transition(.move(edge: .leading))
                        Spacer()
                        Image("stephen")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        .frame(height: 110)
                        .offset(y: -20)
                        .onTapGesture {
                            withAnimation {
                                #if !os(macOS)
                                bounceHaptics.impactOccurred()
                                #endif
                                self.animateStephen.toggle()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.animateStephen.toggle()
                            }
                        }
                        .offset(x: 0, y: animateStephen ? -5 : 0)
                        .animation(animateStephen ? .easeInOut(duration: 0.15).repeatForever(autoreverses: true) : .default, value: animateStephen)
                        .background(
                            VStack {
                                Spacer()
                                Ellipse()
                                    .fill(.black)
                                    .frame(height: 5)
                                    .blur(radius: 10)
                                    .opacity(0.8)
                            }
                        )
                        .transition(.move(edge: .trailing))
                    }
                }
                .padding()
            )
//            .padding(.top)
            .zIndex(2)
            .background(Color(uiColor: .systemBackground))
//            .background(HEAD_TO_HEAD_COLOR_1.backgroundColors[0])
            ZStack {
                VStack(spacing: 0) {
                    HEAD_TO_HEAD_COLOR_1.backgroundColors[0]
                    HEAD_TO_HEAD_COLOR_2.backgroundColors[0]
                }
                VStack(spacing: 0) {
                    ZStack {
                        VStack(spacing: 0) {
                            HEAD_TO_HEAD_COLOR_1.backgroundColors[0]
                            Rectangle()
                                .fill(Color.white)
                                .frame(height: 1)
                        }
                        ZStack(alignment: .bottomTrailing) {
                            VStack(spacing: 0) {
                                Spacer()
                                if animateIn {
                                    campaignDetails(for: campaign1, alignment: .leading)
                                        .foregroundStyle(HEAD_TO_HEAD_COLOR_1.foregroundColor)
                                        .padding(.bottom)
                                        .transition(.move(edge: .leading))
                                    HStack(alignment: .firstTextBaseline) {
                                        Text(campaign1.totalRaisedDescription(showFullCurrencySymbol: false, trimDecimalPlaces: true))
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundStyle(HEAD_TO_HEAD_COLOR_1.foregroundColor)
                                        Text(campaign1.user.username)
                                            .font(.caption)
                                        Spacer()
                                    }
                                    .foregroundStyle(HEAD_TO_HEAD_COLOR_1.foregroundColor)
                                    .transition(.move(edge: .leading))
                                }
                            }
                            if campaign1.totalRaisedNumerical == highestTotal {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 30))
                                    .imageScale(.large)
                                    .foregroundStyle(Color.brandYellow)
                                    .background(Circle().fill(.white).blur(radius: 30))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                        .offset(y: -10)
                    }
                    ZStack {
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.white)
                                .frame(height: 1)
                            HEAD_TO_HEAD_COLOR_2.backgroundColors[0]
                        }
                        ZStack(alignment: .topLeading) {
                            VStack(spacing: 0) {
                                ProgressBar(value: .constant(progressBarValue), barColour: HEAD_TO_HEAD_COLOR_2.backgroundColors[0], fillColor: HEAD_TO_HEAD_COLOR_1.backgroundColors[0], showDivider: true, dividerWidth: 2)
                                    .frame(height: 20)
                                    .overlay {
                                        Capsule().stroke(.white, style: StrokeStyle(lineWidth: 3))
                                    }
                                if animateIn {
                                    HStack(alignment: .firstTextBaseline) {
                                        Spacer()
                                        Text(campaign2.user.username)
                                            .font(.caption)
                                        Text(campaign2.totalRaisedDescription(showFullCurrencySymbol: false, trimDecimalPlaces: true))
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .padding(.top)
                                    }
                                    .foregroundStyle(HEAD_TO_HEAD_COLOR_2.foregroundColor)
                                    .transition(.move(edge: .trailing))
                                    campaignDetails(for: campaign2, alignment: .trailing)
                                        .foregroundStyle(HEAD_TO_HEAD_COLOR_2.foregroundColor)
                                        .padding(.top)
                                        .transition(.move(edge: .trailing))
                                }
                                Spacer()
                            }
                            if campaign2.totalRaisedNumerical == highestTotal {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 30))
                                    .imageScale(.large)
                                    .foregroundStyle(Color.brandYellow)
                                    .background(Circle().fill(.white).blur(radius: 30))
                                    .offset(y: 30)
                            }
                        }
                        .offset(y: -10)
                        .padding(.horizontal)
                    }
                }
                .transformEffect(CGAffineTransform(a: 1, b: -0.15, c: 0, d: 1, tx: 0, ty: 0))
                .offset(y: 20)
                .clipped()
            }
//            .border(.red)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
//            .padding(.bottom)
//            .edgesIgnoringSafeArea(.bottom)
        }
        .padding()
        .background(
//            HEAD_TO_HEAD_COLOR_1.backgroundColors[0]
//            VStack(spacing: 0) {
//                HEAD_TO_HEAD_COLOR_1.backgroundColors[0]
//                HEAD_TO_HEAD_COLOR_2.backgroundColors[0]
//            }
//            HEAD_TO_HEAD_COLOR_2.backgroundColors[0]
        )
//        .toolbarBackground(HEAD_TO_HEAD_COLOR_1.backgroundColors[0])
//        .edgesIgnoringSafeArea(.bottom)
//        .toolbar {
//            ToolbarItem(placement: .topBarTrailing) {
//                Button(action: {
//                    presentationMode.wrappedValue.dismiss()
//                }) {
//                    HStack {
//                        Image(systemName: "chevron.left")
//                            .bold()
//                        Text("Back")
//                    }
//                }
////                .foregroundStyle(Color.white)
//            }
//        }
//        .navigationBarBackButtonHidden()
//        .tint(.white)
//        .toolbarColorScheme(.dark)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeOut) {
                    animateIn = true
                }
            }
        }
        .task {
            await refresh()
        }
        .onReceive(timer) { _ in
            Task {
                await refresh()
            }
        }
    }
    
    func refresh() async {
        if let c1 = await campaign1.updateFromAPI() {
            withAnimation {
                campaign1 = c1
            }
        }
        if let c2 = await campaign2.updateFromAPI() {
            withAnimation {
                campaign2 = c2
            }
        }
    }
    
}

#Preview {
    NavigationStack {
        HeadToHeadView(campaign1: Campaign(from: TiltifyCauseCampaign(publicId: UUID(), name: "The Lovely Developers for St. Jude 2023", slug: "aarons-campaign-for-st-jude", goal: TiltifyAmount(currency: "USD", value: "500"), totalAmountRaised: TiltifyAmount(currency: "USD", value: "160.00"), user: TiltifyUser(username: "TheLovelyDevelopers", slug: "agmcleod", avatar: TiltifyAvatar(alt: "", src: "https://assets.tiltify.com/assets/default-avatar.png", height: nil, width: nil)), avatar: TiltifyAvatar(alt: "", src: "https://assets.tiltify.com/uploads/user/thumbnail/447696/blob-59ba2e8f-8d1a-4037-bce2-515075a7f6aa.png", height: nil, width: nil), description: "I'm fundraising for St. Jude Children's Research Hospital.")), campaign2: Campaign(from: TiltifyCauseCampaign(publicId: UUID(), name: "Support the Research of Relay FM's Official Historian 📜", slug: "aarons-campaign-for-st-jude", goal: TiltifyAmount(currency: "USD", value: "500"), totalAmountRaised: TiltifyAmount(currency: "USD", value: "460.00"), user: TiltifyUser(username: "rhl__", slug: "agmcleod", avatar: TiltifyAvatar(alt: "", src: "https://assets.tiltify.com/assets/default-avatar.png", height: nil, width: nil)), avatar: TiltifyAvatar(alt: "", src: "https://assets.tiltify.com/uploads/user/thumbnail/312463/blob-d2e2dc23-8ea5-4632-b63b-9ed3a2cdf374.jpeg", height: nil, width: nil), description: "I'm fundraising for St. Jude Children's Research Hospital.")))
    }
}
