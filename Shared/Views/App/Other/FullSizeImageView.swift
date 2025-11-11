//
//  FullSizeImageView.swift
//  St Jude
//
//  Created by Justin Hamilton on 9/6/25.
//

import SwiftUI
import Kingfisher

struct FullSizeImageView: View {
    var imageUrl: URL
    
    @State private var currentScale: Double = 0.0
    @State private var totalScale: Double = 1.0
    
    /**
     */
    
    var body: some View {
        GeometryReader { geometry1 in
            ScrollView([.horizontal, .vertical]) {
                KFImage.url(self.imageUrl)
                    .placeholder {
                        ProgressView()
                            .frame(width: 45, height: 45)
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry1.size.width * (self.currentScale + self.totalScale))
                    .gesture(
                        MagnifyGesture()
                            .onChanged { value in
                                self.currentScale = value.magnification - 1
                            }
                            .onEnded { value in
                                withAnimation {
                                    self.totalScale = min(3, max(1, self.totalScale + self.currentScale))
                                    self.currentScale = 0
                                }
                            }
                    )
                    .gesture(
                        TapGesture(count: 2)
                            .onEnded { value in
                                withAnimation {
                                    self.totalScale = self.totalScale == 1.0 ? 2.0 : 1.0
                                }
                            }
                    )
            }
        }
    }
}

#Preview {
    FullSizeImageView(imageUrl: URL(string: "https://tildy.dev/assets/Team_Logo_v3.png")!)
}
