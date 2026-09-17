//
//  ScoreBoxView.swift
//  St Jude
//
//  Created by David Stephens on 03/09/2026.
//
import SwiftUI

struct ScoreGroupBoxView: View {
    let myke: Double
    let stephen: Double
    var showBackground: Bool = true
    
    @ViewBuilder
    var content: some View {
        HStack {
            VStack {
                Text("Myke")
                    .bold()
                    .font(.footnote)
                Text(formatWidgetNumber(myke))
                    .bold()
                    .foregroundStyle(WidgetAppearance.mykeRed2026)
                    .font(Font.custom("KilnSansSpiked", size: UIFont.preferredFont(forTextStyle: .title1).pointSize))
            }
            .padding(.trailing, 5)
            VStack {
                Text("Stephen")
                    .bold()
                    .font(.footnote)
                Text(formatWidgetNumber(stephen))
                    .bold()
                    .foregroundStyle(WidgetAppearance.stephenYellow2026.darker(by: 5))
                    .font(Font.custom("KilnSansSpiked", size: UIFont.preferredFont(forTextStyle: .title1).pointSize))
            }
            .padding(.leading, 5)
        }
    }
    
    var body: some View {
        if self.showBackground {
            GroupBox {
                self.content
            }
            .themedGroupBox(type: .primary, id: "scoreWidgetScoreBox")
        } else {
            self.content
        }
    }
}

func formatWidgetNumber(_ num: Double) -> String {
    if num == 0 {
        return "0"
    }
    let str = String(format: "%0.2f", num)
    return str.trimmingCharacters(in: .init(charactersIn: "0")).trimmingCharacters(in: .init(charactersIn: "."))
}
