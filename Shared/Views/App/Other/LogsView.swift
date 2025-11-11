//
//  LogsView.swift
//  St Jude
//
//  Created by Justin Hamilton on 11/10/25.
//

import SwiftUI
import Combine

@Observable
class LogsContainer {
    var logs: [String] = []
    
    func addLog(_ newLog: String) {
        self.logs.append(newLog)
    }
    
    init(logs: [String] = []) {
        self.logs = logs
    }
}

struct LogsView: View {
    let logContainer: LogsContainer
    
    var logs: [String] {
        logContainer.logs
    }
    
    var body: some View {
        if !logs.isEmpty {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 3) {
                        ForEach(Array(logs.enumerated()), id: \.0) { idx, log in
                            Text(log)
                                .foregroundColor(.black)
                                .font(.system(.caption2))
                                .multilineTextAlignment(.leading)
                                .fullWidth(alignment: .leading)
                                .id(idx)
                        }
                    }
                    .padding(4)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .padding(.horizontal)
                }
                .frame(maxHeight: 200)
                .onChange(of: logs) { oldValue, newValue in
                    proxy.scrollTo(newValue.endIndex-1)
                }
            }
        }
    }
}
