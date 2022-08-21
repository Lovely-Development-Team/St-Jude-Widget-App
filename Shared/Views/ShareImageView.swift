//
//  ShareImageView.swift
//  St Jude
//
//  Created by Tony Scida on 8/20/22.
//

import SwiftUI

struct ShareImageView: View {
    @State private var isShareSheetPresented = false
    var image: UIImage
    
    @Environment(\.presentationMode) var presentationMode
    
    init(_ image: UIImage) {
        self.image = image
    }
    var body: some View {
            Group{
                Image(uiImage: image)
                Button(action: {
                    self.isShareSheetPresented.toggle()
                    
                }) {
                    HStack{
                        Text("Share")
                        Image(systemName: "square.and.arrow.up")
                    }
                    .foregroundColor(.white)
                    .padding(10)
                    .padding(.horizontal, 20)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    

                   
                }
                .sheet(isPresented: $isShareSheetPresented) {
                    ShareSheetView(activityItems: [image])
                }
            }
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button("Done",
                    action: {
            presentationMode.wrappedValue.dismiss()
        }))
    }
   
}

struct ShareImageView_Previews: PreviewProvider {
    static var previews: some View {
        ShareImageView(UIImage(imageLiteralResourceName: "Team_Logo_F"))
            .padding(100.0)
    }
}
