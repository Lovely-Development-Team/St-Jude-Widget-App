//
//  ContentView.swift
//  Shared
//
//  Created by David on 21/08/2021.
//

import SwiftUI
import WidgetKit
import BackgroundTasks

enum ActiveSheet: Identifiable {
    case notifications, egg
    
    var id: Int {
        hashValue
    }
}

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
    @AppStorage(UserDefaults.inAppPreferFutureMilestonesKey, store: UserDefaults.shared) var preferFutureMilestones: Bool = false
    @AppStorage(UserDefaults.inAppShowFullCurrencySymbolKey, store: UserDefaults.shared) var showFullCurrencySymbol: Bool = false
    @AppStorage(UserDefaults.inAppShowGoalPercentageKey, store: UserDefaults.shared) var showGoalPercentage: Bool = true
    @AppStorage(UserDefaults.inAppShowMilestonePercentageKey, store: UserDefaults.shared) var showMilestonePercentage: Bool = true
    @AppStorage(UserDefaults.inAppUseTrueBlackBackgroundKey, store: UserDefaults.shared) var useTrueBlackBackground: Bool = false
    
//    static let maxFrameHeight = DeviceType.isSmallPhone() ? 310 : 378.5
    @State private var maxFrameHeight = 378.5
    @State private var rectangleSize: CGSize = .zero
    @State private var rectangleCenter: CGPoint = .zero
    
    @State private var fadeInWidget = true
    
    @State var activeSheet: ActiveSheet?
    
    #if !os(macOS)
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    #endif
    
    var blurView: some View {
        #if !os(iOS)
        BlurView()
            .opacity((self.isWidgetFlipped) ? 1.0 : 0)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture(perform: {
                self.dismissSettings()
            })
        #else
        BlurView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
            .opacity((self.isWidgetFlipped) ? 1.0 : 0)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture(perform: {
                self.dismissSettings()
                impactMed.impactOccurred()
            })
        #endif
    }
    
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
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .accessibility(label: Text("Relay FM for Saint Jude 2021"))
                Text("This app provides a widget to track the progress of the 2021 Relay FM St. Jude fundraiser. Add the widget to your Home Screen!")
                    .multilineTextAlignment(.center)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.7)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibility(label: Text("This app provides a widget to track the progress of the 2021 Relay FM Saint Jude fundraiser. Add the widget to your Home Screen!"))
                    .padding(.bottom, 5)
                Spacer()
                Rectangle()
                    .frame(minWidth: 0, maxWidth: 795, maxHeight: 378.5)
                    .foregroundColor(.clear)
                    .background(
                        GeometryReader { geometry -> Color in
                            DispatchQueue.main.async {
                                let frame = geometry.frame(in: CoordinateSpace.global)
                                self.maxFrameHeight = min(frame.size.height, 378.5) // 378.5
                                self.rectangleCenter = CGPoint(x: frame.midX, y: frame.midY)
                                self.rectangleSize = frame.size
                            }
                            return Color.clear
                        })
                Spacer()
                VStack{
                    Link("Visit the fundraiser!", destination: URL(string: "https://stjude.org/relay")!)
                        .font(.headline)
                        .foregroundColor(Color(.sRGB, red: 43 / 255, green: 54 / 255, blue: 61 / 255, opacity: 1))
                        .padding(10)
                        .padding(.horizontal, 20)
                        .background(Color(.sRGB, red: 254 / 255, green: 206 / 255, blue: 52 / 255, opacity: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .frame(minHeight: 80)
                    Button(action: {
                        activeSheet = .notifications
                    }, label: {
                        HStack {
                            Image(systemName: "bell.badge")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 15)
                                .foregroundColor(Color.label)
                                .accessibility(hidden: true)
                            Text("Notification Settings")
                                .foregroundColor(Color.label)
                                .font(.callout)
                                .fontWeight(.bold)
                        }
                    })
                        .buttonStyle(PlainButtonStyle())
                }
                Spacer()
                Button(action: {
                    activeSheet = .egg
                }, label: {
                    HStack {
                        Text("From the makers of MottoBotto")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Image("l2culogosvg")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.secondary)
                            .frame(height: 15)
                            .accessibility(hidden: true)
                            
                    }
                })
                    .buttonStyle(PlainButtonStyle())
                    .padding(.vertical, 5)
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
                            checkSignificantAmounts(for: self.widgetData)
                            checkNewMilestones(for: self.widgetData)
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
            .scaleEffect((self.isWidgetFlipped) ? 0.95 : 1.0)
            
            blurView
            
            VStack {
                if isWidgetFlipped {
                    WidgetSettingsView(onDismiss: self.dismissSettings)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                } else {
                    EntryView(campaign: $widgetData, showMilestones: (self.maxFrameHeight/self.rectangleSize.width < 0.68) ? false : showMilestones, preferFutureMilestones: preferFutureMilestones, showFullCurrencySymbol: showFullCurrencySymbol, showGoalPercentage: showGoalPercentage, showMilestonePercentage: showMilestonePercentage, useTrueBlackBackground: useTrueBlackBackground, forceHidePreviousMilestone: (self.maxFrameHeight/self.rectangleSize.width < 0.75) ? true : false)
                        .onAppear {
#if os(iOS)
                            submitRefreshTask()
#endif
                            do {
                                self.widgetData = try apiClient.jsonDecoder.decode(TiltifyWidgetData.self, from: storedData)
                                checkSignificantAmounts(for: self.widgetData)
                                checkNewMilestones(for: self.widgetData)
                            } catch {
                                dataLogger.error("Failed to store API response: \(error.localizedDescription)")
                            }
                        }
                }
                
            }
            .background(Color.secondarySystemBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(radius: 20)
            .frame(minWidth: 0, maxWidth: 795, maxHeight: self.maxFrameHeight)
            .rotation3DEffect(.degrees(isWidgetFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            .onTapGesture {
                #if !os(macOS)
                    impactMed.impactOccurred()
                #endif
                self.showSettings()
            }
            .onLongPressGesture {
                #if !os(macOS)
                    impactHeavy.impactOccurred()
                #endif
                self.showSettings()
            }
            .padding()
            .position(self.rectangleCenter)
            .edgesIgnoringSafeArea(.all)
//            .padding(.top, DeviceType.isSmallPhone() ? 80 : 0)
            .sheet(item: $activeSheet) { item in
                switch item {
                case .notifications:
                    NotificationSettings()
                case .egg:
                    EasterEggView()
                        .background(Color.secondarySystemBackground)
                        .edgesIgnoringSafeArea(.all)
                }
            }
            .opacity((!self.fadeInWidget) ? 1 : 0)
        }
        .onAppear(perform: {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                withAnimation(.spring(), {
                    self.fadeInWidget = false
                })
            })
        })
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
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))
    }
}
