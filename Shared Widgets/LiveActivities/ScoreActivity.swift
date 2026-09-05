//
//  ScoreActivity.swift
//  St Jude
//
//  Created by David Stephens on 02/09/2026.
//

import WidgetKit
import SwiftUI


struct ScoreActivityConfiguration: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ScoreAttributes.self) { context in
            lockScreenContent(contentState: context.state)
        } dynamicIsland: { context in
            DynamicIsland {
                expandedContent(contentState: context.state, isStale: context.isStale)
            } compactLeading: {
                compactScore(icon: .mykeHeadIcon2026Tiny, score: context.state.myke, color: WidgetAppearance.mykeRed2026)
            } compactTrailing: {
                compactScore(icon: .stephenHeadIcon2026Tiny, score: context.state.stephen, color: WidgetAppearance.stephenYellow2026.darker(by: 5))
            } minimal: {
                ScoreActivityMinimalView(state: context.state)
            }
        }
    }

    @DynamicIslandExpandedContentBuilder
    private func expandedContent(contentState: ScoreAttributes.ContentState,
                                 isStale: Bool) -> DynamicIslandExpandedContent<some View> {
        DynamicIslandExpandedRegion(.leading) {
            expandedMykeScore(score: contentState.myke)
        }

        DynamicIslandExpandedRegion(.trailing) {
            expandedStephenScore(score: contentState.stephen)
        }
    }
    
    @ViewBuilder
    private func expandedScoreText(title: String, score: Double, color: Color) -> some View {
        VStack {
            Text(title)
                .font(.footnote)
                .bold()
            Text(formatWidgetNumber(score))
                .font(.title3)
                .bold()
                .foregroundStyle(color)
        }
        .font(Font.custom("KilnSansSpiked", size: UIFont.preferredFont(forTextStyle: .title1).pointSize))
    }
    
    @ViewBuilder
    private func expandedMykeScore(score: Double) -> some View {
        HStack {
            ScoreIcon(icon: .myke2026Small)
            expandedScoreText(title: "Myke", score: score, color: WidgetAppearance.mykeRed2026)
        }
    }
    
    @ViewBuilder
    private func expandedStephenScore(score: Double) -> some View {
        HStack {
            expandedScoreText(title: "Stephen", score: score, color: WidgetAppearance.stephenYellow2026.darker(by: 5))
            ScoreIcon(icon: .stephen2026Small)
        }
    }

    // MARK: Lock Screen
    
    private func scoreGroupBoxView(contentState: ScoreAttributes.ContentState) ->  some View{
        GroupBox {
            HStack {
                VStack {
                    Text("Myke")
                        .bold()
                        .font(.footnote)
                    Text(formatWidgetNumber(contentState.myke))
                        .bold()
                        .foregroundStyle(WidgetAppearance.mykeRed2026)
                        .font(Font.custom("KilnSansSpiked", size: UIFont.preferredFont(forTextStyle: .title1).pointSize))
                }
                .padding(.trailing, 5)
                VStack {
                    Text("Stephen")
                        .bold()
                        .font(.footnote)
                    Text(formatWidgetNumber(contentState.stephen))
                        .bold()
                        .foregroundStyle(WidgetAppearance.stephenYellow2026.darker(by: 5))
                        .font(Font.custom("KilnSansSpiked", size: UIFont.preferredFont(forTextStyle: .title1).pointSize))
                }
                .padding(.leading, 5)
            }
        }
        .themedGroupBox(type: .primary, id: "scoreWidgetScoreBox")
    }

    @ViewBuilder
    private func lockScreenContent(contentState: ScoreAttributes.ContentState) -> some View {
        let imageHeight: CGFloat = 100
        ZStack {
//             Fill out the whole space
            Rectangle()
                .foregroundStyle(.clear)
            HStack {
                Spacer()
                    .overlay {
                        Image(.myke2026Small)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: imageHeight * 2)
                            .padding(.top, imageHeight)
                            .offset(x: 10)
                            .shadow(radius: 10)
                    }
                    .zIndex(2)
                ScoreGroupBoxView(myke: contentState.myke, stephen: contentState.stephen)
                    .padding(.bottom, 199 / 3)
                    .zIndex(1)
                Spacer()
                    .overlay {
                        Image(.stephen2026Small)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: imageHeight * 2)
                            .padding(.top, imageHeight)
                            .offset(x: -10)
                            .shadow(radius: 10)
                    }
                    .zIndex(2)
            }
        }
        .background {
            Group {
                    Image(.sky2026Small)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    Image(.buildings2026Small)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.top, imageHeight / 3)
            }
            .scaleEffect(x: 1.5, y: 1.5)
            .padding(.bottom, imageHeight / 3)
        }
    }

    @ViewBuilder
    private func compactScore(icon: ImageResource, score: Double, color: Color) -> some View {
        HStack(spacing: 2) {
            Image(icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
            Text(formatWidgetNumber(score))
                .foregroundStyle(color)
        }
    }
}

#Preview("Expanded", as: .dynamicIsland(.expanded), using: ScoreAttributes()) {
    ScoreActivityConfiguration()
} contentStates: {
    ScoreAttributes.ContentState(myke: 45, stephen: 35)
    ScoreAttributes.ContentState(myke: 35, stephen: 45)
    ScoreAttributes.ContentState(myke: 35, stephen: 35)
}

#Preview("Compact", as: .dynamicIsland(.compact), using: ScoreAttributes()) {
    ScoreActivityConfiguration()
} contentStates: {
    ScoreAttributes.ContentState(myke: 45, stephen: 35)
    ScoreAttributes.ContentState(myke: 35, stephen: 45)
    ScoreAttributes.ContentState(myke: 35, stephen: 35)
}

#Preview("Minimal", as: .dynamicIsland(.minimal), using: ScoreAttributes()) {
    ScoreActivityConfiguration()
} contentStates: {
    ScoreAttributes.ContentState(myke: 45, stephen: 35)
    ScoreAttributes.ContentState(myke: 35, stephen: 45)
    ScoreAttributes.ContentState(myke: 35, stephen: 35)
}
