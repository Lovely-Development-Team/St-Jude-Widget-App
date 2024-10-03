//
//  CountdownView.swift
//  St Jude
//
//  Created by Ben Cardy on 03/10/2024.
//

import SwiftUI

struct CountdownView: View {
    
    @State private var campaignsHaveClosed: Bool = false
    @State private var showAbsoluteDate: Bool = false
    
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    let closingDate: Date? = Date(timeIntervalSince1970: 1728309641)
    let countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Group {
            if let closingDate = closingDate {
                VStack {
                    if campaignsHaveClosed {
                        GroupBox {
                            VStack(spacing: 5) {
                                Text("Fundraisers are now closed!")
                                    .font(.title3)
                                    .bold()
                                    .multilineTextAlignment(.leading)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                Text("An enormous thank you to everyone who helped raise such a phenomenal amount.")
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .foregroundColor(.white)
                        .groupBoxStyle(BlockGroupBoxStyle(tint: .accentColor))
                    } else {
                        GroupBox {
                            Group {
                                if showAbsoluteDate {
                                    Text("Fundraisers close on ") + Text(closingDate, style: .date) + Text(" at ") + Text(closingDate, style: .time) + Text("!")
                                } else {
                                    Text("Fundraisers close in ") + Text(closingDate, style: .relative) + Text("!")
                                }
                            }
                            .bold()
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        }
                        .onTapGesture {
                            withAnimation {
                                showAbsoluteDate.toggle()
                            }
                        }
                        .font(.title3)
                        .foregroundColor(.white)
//                        .lineLimit(1)
//                        .minimumScaleFactor(0.5)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .groupBoxStyle(BlockGroupBoxStyle(tint: .accentColor))
                    }
                }
            } else {
                EmptyView()
            }
        }
        .onAppear {
            updateDate()
        }
        .onReceive(countdownTimer) { _ in
            updateDate()
        }
    }
    
    func updateDate() {
        if let closingDate = closingDate {
            campaignsHaveClosed = closingDate < Date()
        }
    }
}

#Preview {
    CountdownView()
}
