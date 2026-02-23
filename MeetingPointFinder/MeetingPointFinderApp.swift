//
//  MeetingPointFinderApp.swift
//  MeetingPointFinder
//
//  合流地点検索アプリのエントリーポイント
//

import SwiftUI
import SwiftData

@main
struct MeetingPointFinderApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // SwiftDataのモデルコンテナを設定
        .modelContainer(for: [Station.self, SearchHistory.self])
    }
}
