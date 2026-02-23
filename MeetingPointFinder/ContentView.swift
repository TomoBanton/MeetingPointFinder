//
//  ContentView.swift
//  MeetingPointFinder
//
//  メインTabView: ホーム画面と設定画面
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("ホーム", systemImage: "magnifyingglass")
                }

            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Station.self, SearchHistory.self], inMemory: true)
}
