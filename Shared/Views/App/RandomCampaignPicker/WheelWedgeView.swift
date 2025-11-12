//
//  WheelWedgeView.swift
//  St Jude
//
//  Created by Justin Hamilton on 11/11/25.
//

import SwiftUI
import Kingfisher

struct WheelWedgeView: View {
    @Environment(\.presentationMode) var presentationMode
    var index: Int
    @Binding var isTimeToFlip: Bool
    @Binding var campaign: Campaign?
    @Binding var campaignChoiceID: UUID?
    var shouldFlip: Bool
    
    @ViewBuilder
    func image() -> some View {
        if let campaign = campaign, let url = URL(string: campaign.avatar?.src ?? "") {
            KFImage.url(url)
                .resizable()
                .placeholder {
                    ProgressView()
                }
                .aspectRatio(contentMode: .fit)
                .cornerRadius(5)
                .onTapGesture {
                    campaignChoiceID = campaign.id
                    presentationMode.wrappedValue.dismiss()
                }
        } else {
            EmptyView()
        }
    }
    
    let colors: [Color] = [
        Color.brandRed,
        Color.brandBlue,
        Color.brandGreen,
        Color.brandPurple,
        Color.brandYellow
    ]
    
    var body: some View {
        Triangle()
            .foregroundStyle(colors[index % colors.count])
            .overlay {
                ZStack {
                    if(shouldFlip && isTimeToFlip) {
                        VStack {
                            image()
                                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                                .padding()
                                .padding()
                            Spacer()
                        }
                    }
                    Triangle()
                        .stroke(.black, lineWidth: 2)
                }
            }
            .rotation3DEffect(.degrees(shouldFlip && isTimeToFlip ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            .animation(.easeInOut, value: isTimeToFlip)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        
        return path
    }
}
