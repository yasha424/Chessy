//
//  ChessyWidget.swift
//  ChessyWidget
//
//  Created by Yasha Serhiienko on 19.08.2023.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {

    func placeholder(in context: Context) -> Entry {
        Entry(date: Date(), fen: "")
    }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
        let entry = Entry(date: Date(), fen: "")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [Entry] = []

        let userDefaults = UserDefaults(suiteName: "group.com.yasha424.Chessy.default")!
        let fenString = userDefaults.string(forKey: "fen") ?? ""
        entries.append(Entry(date: .now, fen: fenString))

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct Entry: TimelineEntry {
    let date: Date
    let fen: String
}

struct ChessyWidgetView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        let separetedFen = entry.fen.split(separator: " ")
        let fen = separetedFen.isEmpty ? "" : String(separetedFen[0])
        BoardPreview(board: Board(fromFen: fen)).boardView
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .padding(widgetFamily == .systemLarge ? 20 : 10)
            .background(.ultraThinMaterial)
    }
}

struct ChessyWidget: Widget {
    let kind: String = "ChessyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ChessyWidgetView(entry: entry)
                    .scaledToFill()
                    .containerBackground(
                        LinearGradient(
                            colors: [.blue, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        for: .widget
                    )
            } else {
                ChessyWidgetView(entry: entry)
                    .scaledToFill()
                    .background(LinearGradient(
                        colors: [.blue, .yellow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            }
        }
        .contentMarginsDisabled()
        .supportedFamilies([.systemSmall, .systemLarge])
        .configurationDisplayName("Game preview")
        .description("Preview your current game")
    }
}
