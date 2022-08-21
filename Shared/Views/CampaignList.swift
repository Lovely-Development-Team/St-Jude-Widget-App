//
//  CampaignList.swift
//  St Jude
//
//  Created by Ben Cardy on 18/08/2022.
//

import SwiftUI

// From https://codakuma.com/swiftui-view-to-image-2/
extension View {
    var asImage: UIImage {
        // Must ignore safe area due to a bug in iOS 15+ https://stackoverflow.com/a/69819567/1011161
        let controller = UIHostingController(rootView: self.edgesIgnoringSafeArea(.top))
        let view = controller.view
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: CGPoint(x: 0, y: 0), size: targetSize)
        view?.backgroundColor = .clear

        let format = UIGraphicsImageRendererFormat()
        format.scale = 3 // Ensures 3x-scale images. You can customise this however you like.
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}


struct CampaignList: View {
    
    @State private var causeData: TiltifyCauseData? = nil
    @StateObject private var apiClient = ApiClient.shared
    @State private var isShareSheetPresented = false
    
    var body: some View {
        Group {
            if let causeData = causeData {
                let campaignImage = MainCampaign(causeData).asImage
                VStack {
                    ZStack {
                        MainCampaign(causeData)
                        Button {
                            self.isShareSheetPresented.toggle()
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 30.0)
                        .padding(.top, -70.0)
                        .sheet(isPresented: $isShareSheetPresented) {
                            NavigationView{
                                ShareImageView(campaignImage)
                            }
                            
                        }

                    }
                    Link("Visit the fundraiser!", destination: URL(string: "https://stjude.org/relay")!)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(10)
                        .padding(.horizontal, 20)
                        .background(causeData.fundraisingEvent.colors.backgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    //                        .frame(minHeight: 80)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .padding(.bottom)
                    
                    Text("Fundraisers")
                        .font(.title)
                        .fontWeight(.bold)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    List {
                        //                    .background(LinearGradient(colors: [
                        //                        Color(.sRGB, red: 43 / 255, green: 54 / 255, blue: 61 / 255, opacity: 1),
                        //                        Color(.sRGB, red: 51 / 255, green: 63 / 255, blue: 72 / 255, opacity: 1)
                        //                    ], startPoint: .bottom, endPoint: .top))
                        
                        
                        ForEach(causeData.fundraisingEvent.publishedCampaigns.edges, id: \.node.publicId) { campaign in
                            NavigationLink(destination: ContentView(vanity: campaign.node.user.slug, slug: campaign.node.slug, user: campaign.node.user.username).navigationTitle(campaign.node.name)) {
                                VStack(alignment: .leading) {
                                    Text(campaign.node.name)
                                        .font(.headline)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    HStack(alignment: .top) {
                                        Text(campaign.node.user.username)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text(campaign.node.totalAmountRaised.description(showFullCurrencySymbol: false))
                                            .font(.title)
                                            .fontWeight(.bold)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
//                .listRowSeparator(.hidden)
            } else {
                Text("Loading...")
            }
        }
        .onAppear {
            let dataTask1 = apiClient.fetchCause { result in
                switch result {
                case .failure(let error):
                    dataLogger.error("Request failed: \(error.localizedDescription)")
                case .success(let response):
                    causeData = response.data
                }
            }
        }
    }
}

struct CampaignList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CampaignList()
        }
    }
}
