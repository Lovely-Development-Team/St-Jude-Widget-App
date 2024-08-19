//
//  HeadToHeadView.swift
//  St Jude
//
//  Created by Ben Cardy on 29/08/2023.
//

import SwiftUI
import Kingfisher

let HEAD_TO_HEAD_COLOR_1 = WidgetAppearance.yellow
let HEAD_TO_HEAD_COLOR_2 = WidgetAppearance.blue

struct HeadToHeadView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    @State private var landscapeData = RandomLandscapeData(isForMainScreen: false)
    
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
                .modifier(PixelRounding())
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    func campaignDetails(for campaign: Campaign, alignment: TextAlignment) -> some View {
        NavigationLink(destination: CampaignView(initialCampaign: campaign)) {
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
                        .foregroundColor(.primary)
                    if alignment == .trailing {
                        image(for: campaign)
                    } else {
                        Spacer()
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity)
            }
        }
        
    }
    
    @State private var animateMyke = false
    @State private var animateStephen = false
#if !os(macOS)
    let bounceHaptics = UIImpactFeedbackGenerator(style: .light)
    let selectionHaptics = UISelectionFeedbackGenerator()
#endif
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                RandomLandscapeView(data: self.$landscapeData) {
                    VStack {
                        if animateIn {
                            Text("Fundraiser")
                                .padding(.top, 5)
                            Text("Head to Head!")
                        }
                    }
                    .font(.title)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(minHeight: 140)
                    .padding()
                    .background {
                        SkyView()
                            .mask {
                                LinearGradient(stops: [
                                    .init(color: .clear, location: 0),
                                    .init(color: .white, location: 0.25),
                                    .init(color: .white, location: 1)
                                ], startPoint: .top, endPoint: .bottom)
                            }
                    }
                }
                .overlay(alignment: .bottom) {
                    HStack(alignment: .bottom) {
                        if animateIn {
                            AdaptiveImage.stephen(colorScheme: self.colorScheme)
                                .imageAtScale(scale: .spriteScale)
                                .scaleEffect(x: -1)
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
                                .transition(.move(edge: .leading))
                            Spacer()
                            AdaptiveImage.myke(colorScheme: self.colorScheme)
                                .imageAtScale(scale: .spriteScale)
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
                                .transition(.move(edge: .trailing))
                        }
                    }
                    .padding(.horizontal)
                }
                AdaptiveImage.groundRepeatable(colorScheme: self.colorScheme)
                    .tiledImageAtScale(axis: .horizontal)
                VStack {
                    ZStack(alignment: .topTrailing) {
                        if animateIn {
                            GroupBox {
                                VStack(spacing: 0) {
                                    campaignDetails(for: campaign1, alignment: .leading)
                                        .transition(.move(edge: .leading))
                                    HStack(alignment: .lastTextBaseline) {
                                        Text(campaign1.totalRaisedDescription(showFullCurrencySymbol: false, trimDecimalPlaces: true))
                                            .font(.title)
                                            .fontWeight(.bold)
                                        Text(campaign1.user.username)
                                            .font(.caption)
                                        Spacer()
                                    }
                                    .transition(.move(edge: .leading))
                                }
                            }
                            .groupBoxStyle(BlockGroupBoxStyle())
                        }
                    }
                    .overlay(alignment: .bottomTrailing) {
                        if campaign1.totalRaisedNumerical == highestTotal {
                            TappableCoin(collectable: false, spinOnceOnTap: true, offset: 0)
                                .scaleEffect(1.5)
                        }
                    }
                    if animateIn {
                        GroupBox {
                            ProgressBar(value: .constant(progressBarValue), barColour: HEAD_TO_HEAD_COLOR_2.backgroundColors[0], fillColor: HEAD_TO_HEAD_COLOR_1.backgroundColors[0], showDivider: true, dividerWidth: 2)
                                .frame(height: 20)
                        }
                        .groupBoxStyle(BlockGroupBoxStyle())
                    }
                    
                    ZStack(alignment: .bottomLeading) {
                        if animateIn {
                            GroupBox {
                                VStack(spacing: 0) {
                                    HStack(alignment: .firstTextBaseline) {
                                        Spacer()
                                        Text(campaign2.user.username)
                                            .font(.caption)
                                        Text(campaign2.totalRaisedDescription(showFullCurrencySymbol: false, trimDecimalPlaces: true))
                                            .font(.title)
                                            .fontWeight(.bold)
                                    }
                                    .transition(.move(edge: .trailing))
                                    campaignDetails(for: campaign2, alignment: .trailing)
                                        .padding(.top)
                                        .transition(.move(edge: .trailing))
                                }
                            }
                            .groupBoxStyle(BlockGroupBoxStyle())
                        }
                    }
                    .overlay(alignment: .topLeading) {
                        if campaign2.totalRaisedNumerical == highestTotal {
                            TappableCoin(collectable: false, spinOnceOnTap: true, offset: 0)
                                .scaleEffect(1.5)
                        }
                    }
                    Spacer()
                }
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity)
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
        HeadToHeadView(campaign1: Campaign(from: TiltifyCauseCampaign(publicId: UUID(), name: "The Lovely Developers for St. Jude 2023", slug: "aarons-campaign-for-st-jude", goal: TiltifyAmount(currency: "USD", value: "500"), totalAmountRaised: TiltifyAmount(currency: "USD", value: "160.00"), user: TiltifyUser(username: "TheLovelyDevelopers", slug: "agmcleod", avatar: TiltifyAvatar(alt: "", src: "https://assets.tiltify.com/assets/default-avatar.png", height: nil, width: nil)), avatar: TiltifyAvatar(alt: "", src: "https://assets.tiltify.com/uploads/user/thumbnail/447696/blob-59ba2e8f-8d1a-4037-bce2-515075a7f6aa.png", height: nil, width: nil), description: "I'm fundraising for St. Jude Children's Research Hospital.")), campaign2: Campaign(from: TiltifyCauseCampaign(publicId: UUID(), name: "Support the Research of Relay's Official Historian 📜", slug: "aarons-campaign-for-st-jude", goal: TiltifyAmount(currency: "USD", value: "500"), totalAmountRaised: TiltifyAmount(currency: "USD", value: "160.00"), user: TiltifyUser(username: "rhl__", slug: "agmcleod", avatar: TiltifyAvatar(alt: "", src: "https://assets.tiltify.com/assets/default-avatar.png", height: nil, width: nil)), avatar: TiltifyAvatar(alt: "", src: "https://assets.tiltify.com/uploads/user/thumbnail/312463/blob-d2e2dc23-8ea5-4632-b63b-9ed3a2cdf374.jpeg", height: nil, width: nil), description: "I'm fundraising for St. Jude Children's Research Hospital.")))
    }
}
