//
//  HeadToHeadView.swift
//  St Jude
//
//  Created by Ben Cardy on 29/08/2023.
//

import SwiftUI
import Kingfisher

struct HeadToHeadView: View {
    @Environment(\.presentationMode) var presentationMode

    @Binding var campaign1: Campaign
    @Binding var campaign2: Campaign
    
    @State private var animateIn: Bool = false
    
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
    func campaignDetails(for campaign: Campaign, alignment: TextAlignment, color: Color) -> some View {
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

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Color.brandRed
                Color.brandPurple
            }
            VStack(spacing: 0) {
                ZStack {
                    VStack(spacing: 0) {
                        Color.brandRed
                        Rectangle()
                            .fill(Color.white)
                            .frame(height: 1)
                    }
                    ZStack(alignment: .bottomTrailing) {
                        VStack(spacing: 0) {
                            Spacer()
                            if animateIn {
                            campaignDetails(for: campaign1, alignment: .leading, color: .brandRed)
                                .foregroundStyle(WidgetAppearance.red.foregroundColor)
                                .padding(.bottom)
                                .transition(.move(edge: .leading))
                                HStack(alignment: .firstTextBaseline) {
                                    Text(campaign1.totalRaisedDescription(showFullCurrencySymbol: false, trimDecimalPlaces: true))
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundStyle(WidgetAppearance.red.foregroundColor)
                                    Text(campaign1.user.username)
                                        .font(.caption)
                                    Spacer()
                                }
                                .foregroundStyle(WidgetAppearance.red.foregroundColor)
                                .transition(.move(edge: .leading))
                            }
                        }
                        if campaign1.totalRaisedNumerical == highestTotal {
                            Text("👑")
                                .font(.system(size: 50))
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
                        Color.brandPurple
                    }
                    ZStack(alignment: .topLeading) {
                        VStack(spacing: 0) {
                            ProgressBar(value: .constant(progressBarValue), barColour: .brandPurple, fillColor: .accentColor, showDivider: true, dividerWidth: 2)
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
                                .foregroundStyle(WidgetAppearance.blue.foregroundColor)
                                .transition(.move(edge: .trailing))
                            campaignDetails(for: campaign2, alignment: .trailing, color: .brandBlue)
                                .foregroundStyle(WidgetAppearance.blue.foregroundColor)
                                .padding(.top)
                                .transition(.move(edge: .trailing))
                            }
                            Spacer()
                        }
                        if campaign2.totalRaisedNumerical == highestTotal {
                            Text("👑")
                                .font(.system(size: 50))
                                .background(Circle().fill(.white).blur(radius: 30))
                                .offset(y: 20)
                        }
                    }
                    .offset(y: -10)
                    .padding(.horizontal)
                }
            }
            .transformEffect(CGAffineTransform(a: 1, b: -0.15, c: 0, d: 1, tx: 0, ty: 0))
            .offset(y: 20)
        }
        .edgesIgnoringSafeArea(.all)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .bold()
                        Text("Back")
                    }
                }
                .foregroundStyle(Color.white)
            }
        }
        .navigationBarBackButtonHidden()
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
        HeadToHeadView(campaign1: .constant(Campaign(from: TiltifyCauseCampaign(publicId: UUID(), name: "The Lovely Developers for St. Jude 2023", slug: "aarons-campaign-for-st-jude", goal: TiltifyAmount(currency: "USD", value: "500"), totalAmountRaised: TiltifyAmount(currency: "USD", value: "160.00"), user: TiltifyUser(username: "TheLovelyDevelopers", slug: "agmcleod", avatar: TiltifyAvatar(alt: "", src: "https://assets.tiltify.com/assets/default-avatar.png", height: nil, width: nil)), avatar: TiltifyAvatar(alt: "", src: "https://assets.tiltify.com/uploads/user/thumbnail/447696/blob-59ba2e8f-8d1a-4037-bce2-515075a7f6aa.png", height: nil, width: nil), description: "I'm fundraising for St. Jude Children's Research Hospital."))), campaign2: .constant(Campaign(from: TiltifyCauseCampaign(publicId: UUID(), name: "Support the Research of Relay FM's Official Historian 📜", slug: "aarons-campaign-for-st-jude", goal: TiltifyAmount(currency: "USD", value: "500"), totalAmountRaised: TiltifyAmount(currency: "USD", value: "460.00"), user: TiltifyUser(username: "rhl__", slug: "agmcleod", avatar: TiltifyAvatar(alt: "", src: "https://assets.tiltify.com/assets/default-avatar.png", height: nil, width: nil)), avatar: TiltifyAvatar(alt: "", src: "https://assets.tiltify.com/uploads/user/thumbnail/312463/blob-d2e2dc23-8ea5-4632-b63b-9ed3a2cdf374.jpeg", height: nil, width: nil), description: "I'm fundraising for St. Jude Children's Research Hospital."))))
    }
}
