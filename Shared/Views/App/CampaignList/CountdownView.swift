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
    let closingDate: Date? = Date(timeIntervalSince1970: 1759766400)
    let countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Group {
            if let closingDate = closingDate {
                VStack {
                    if campaignsHaveClosed {
                        GroupBox {
                            VStack(alignment: .leading) {
                                Text("Fundraisers are now closed!")
                                    .font(.title3)
                                    .bold()
                                    .multilineTextAlignment(.leading)
                                Text("An enormous thank you to everyone who helped raise such a phenomenal amount.")
                                    .multilineTextAlignment(.leading)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .themedGroupBox(type: .primary)
                    } else {
                        GroupBox {
                            Group {
                                if showAbsoluteDate {
                                    Group {
                                        Text("Fundraisers close on ") + Text(closingDate, style: .date) + Text(" at ") + Text(closingDate, style: .time) + Text("!")
                                    }
                                        .fullWidth()
                                } else {
                                    Group {
                                        Text("Fundraisers close in ") + Text(closingDate, style: .relative) + Text("!")
                                    }
                                    .fullWidth()
                                }
                            }
                            .bold()
                        }
                        .themedGroupBox(type: .primary)
                        .onTapGesture {
                            withAnimation {
                                showAbsoluteDate.toggle()
                            }
                        }
                        .font(.title3)
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
