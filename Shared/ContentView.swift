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
    
    @State private var isWidgetFlipped: Bool = false
    @AppStorage(UserDefaults.inAppShowMilestonesKey, store: UserDefaults.shared) var showMilestones: Bool = true
    @AppStorage(UserDefaults.inAppShowFullCurrencySymbolKey, store: UserDefaults.shared) var showFullCurrencySymbol: Bool = false
    @AppStorage(UserDefaults.inAppShowGoalPercentageKey, store: UserDefaults.shared) var showGoalPercentage: Bool = true
    @AppStorage(UserDefaults.inAppShowMilestonePercentageKey, store: UserDefaults.shared) var showMilestonePercentage: Bool = true
    
    static let maxFrameHeight = DeviceType.isSmallPhone() ? 310 : 378.5
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Text("Relay FM for St. Jude 2021")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .allowsTightening(true)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 5)
                    .accessibility(label: Text("Relay FM for Saint Jude 2021"))
                Text("This app provides a widget to track the progress of the 2021 Relay FM St. Jude fundraiser. Add the widget to your Home Screen!")
                    .multilineTextAlignment(.center)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.8)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibility(label: Text("This app provides a widget to track the progress of the 2021 Relay FM Saint Jude fundraiser. Add the widget to your Home Screen!"))
                Spacer()
                Rectangle()
                    .frame(minWidth: 0, maxWidth: 795, minHeight: 300, maxHeight: Self.maxFrameHeight)
                    .foregroundColor(.clear)
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
            .accessibility(hidden: isWidgetFlipped)
            .padding()
            .onAppear {
                self.showMilestones = UserDefaults.shared.inAppShowMilestones
                self.showFullCurrencySymbol = UserDefaults.shared.inAppShowFullCurrencySymbol
            }
            .onChange(of: showMilestones, perform: { newShowMilestones in
                UserDefaults.shared.inAppShowMilestones = newShowMilestones
            })
            .onChange(of: showFullCurrencySymbol, perform: { newShowFullCurrencySymbol in
                UserDefaults.shared.inAppShowFullCurrencySymbol = newShowFullCurrencySymbol
            })
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
            
            BlurView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                .opacity((self.isWidgetFlipped) ? 1.0 : 0)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture(perform: {
                    self.dismissSettings()
                })
                
            VStack {
                if isWidgetFlipped {
                    WidgetSettingsView(onDismiss: self.dismissSettings)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                        .frame(minWidth: 0, maxWidth: 795, minHeight: 300, maxHeight: Self.maxFrameHeight)
                } else {
                    EntryView(campaign: $widgetData, showMilestones: showMilestones, showFullCurrencySymbol: showFullCurrencySymbol, showGoalPercentage: showGoalPercentage, showMilestonePercentage: showMilestonePercentage)
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
                        .contextMenu {
                            Button {
                                self.isWidgetFlipped = true
                            } label: {
                                Label("Edit Widget", systemImage: "info.circle")
                            }
                        }
                }
            }
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .frame(minWidth: 0, maxWidth: 795, minHeight: 300, maxHeight: Self.maxFrameHeight)
            .rotation3DEffect(.degrees(isWidgetFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            .onTapGesture {
                self.showSettings()
            }
            .padding()
            .shadow(radius: 20)
            .padding(.top, DeviceType.isSmallPhone() ? 80 : 0)
        }
    }
    
    func showSettings() {
        withAnimation(.spring(), {
            self.isWidgetFlipped = true
        })
    }
    
    func dismissSettings() {
        withAnimation(.spring()) {
            self.isWidgetFlipped = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
