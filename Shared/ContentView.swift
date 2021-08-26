//
//  ContentView.swift
//  Shared
//
//  Created by David on 21/08/2021.
//

import SwiftUI
import BackgroundTasks

struct ContentView: View {
    // MARK: Environment
    @Environment(\.scenePhase) private var scenePhase
    
    // MARK: State
    @State private var widgetData = sampleCampaign
    @AppStorage("relayData", store: UserDefaults.shared) private var storedData: Data = Data()
    @StateObject private var apiClient = ApiClient.shared
    #if os(iOS)
    @State var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    #endif
    
    var body: some View {
        VStack {
            Spacer()
            Text("Relay FM for St. Jude 2021")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 5)
                .accessibility(label: Text("Relay FM for Saint Jude 2021"))
            Text("This app provides a widget to track the progress of the 2021 Relay FM St. Jude fundraiser. Add the widget to your Home Screen!")
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .accessibility(label: Text("This app provides a widget to track the progress of the 2021 Relay FM Saint Jude fundraiser. Add the widget to your Home Screen!"))
            Spacer()
            EntryView(campaign: $widgetData, showMilestones: true, showFullCurrencySymbol: true)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .frame(minWidth: 0, maxWidth: 795, minHeight: 300, maxHeight: 378.5)
                .onAppear {
                    #if os(iOS)
                    submitRefreshTask()
                    #endif
                    do {
                        widgetData = try apiClient.jsonDecoder.decode(TiltifyWidgetData.self, from: storedData)
                    } catch {
                        dataLogger.error("Failed to store API response: \(error.localizedDescription)")
                    }
                }
            Spacer()
            Link("Visit the fundraiser!", destination: URL(string: "https://stjude.org/relay")!)
                .font(.headline)
                .foregroundColor(Color(.sRGB, red: 43 / 255, green: 54 / 255, blue: 61 / 255, opacity: 1))
                .padding(10)
                .padding(.horizontal, 20)
                .background(Color(.sRGB, red: 254 / 255, green: 206 / 255, blue: 52 / 255, opacity: 1))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .frame(minHeight: 80)
            Spacer()
            HStack {
                Text("From the makers of MottoBotto")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Image("tildy")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 15)
                    .accessibility(hidden: true)
            }
        }
        .padding()
        .onChange(of: scenePhase) { newPhase in
            if scenePhase == .background && newPhase != .background{
                let dataTask = apiClient.fetchCampaign { result in
                    switch result {
                    case .failure(let error):
                        dataLogger.error("Request failed: \(error.localizedDescription)")
                    case .success(let response):
                        self.widgetData = TiltifyWidgetData(from: response.data.campaign)
                        do {
                            self.storedData = try apiClient.jsonEncoder.encode(self.widgetData)
                        } catch {
                            dataLogger.error("Failed to store API response: \((error as? LocalizedError)?.errorDescription ?? error.localizedDescription)")
                        }
                    }
                    #if os(iOS)
                    UIApplication.shared.endBackgroundTask(backgroundTask)
                    #endif
                }
                #if os(iOS)
                backgroundTask = UIApplication.shared.beginBackgroundTask {
                    dataTask?.cancel()
                    UIApplication.shared.endBackgroundTask(backgroundTask)
                }
                #endif
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
