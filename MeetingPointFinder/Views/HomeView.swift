//
//  HomeView.swift
//  MeetingPointFinder
//
//  ホーム画面: 合流地点検索ボタンと検索履歴一覧
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    
    /// 検索履歴を日付降順で取得
    @Query(sort: \SearchHistory.date, order: .reverse)
    private var searchHistories: [SearchHistory]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // アプリタイトル
                VStack(spacing: 8) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 48))
                        .foregroundStyle(.blue)
                    
                    Text("合流地点ファインダー")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("みんなにちょうどいい駅を見つけよう")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 32)
                
                // 検索開始ボタン
                NavigationLink(destination: MemberSetupView()) {
                    Label("合流地点を探す", systemImage: "magnifyingglass")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                
                // 検索履歴一覧
                if !searchHistories.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("検索履歴")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button("すべて削除") {
                                deleteAllHistories()
                            }
                            .font(.caption)
                            .foregroundStyle(.red)
                        }
                        .padding(.horizontal)
                        
                        List {
                            ForEach(searchHistories) { history in
                                HistoryRow(history: history)
                            }
                            .onDelete(perform: deleteHistories)
                        }
                        .listStyle(.plain)
                    }
                } else {
                    Spacer()
                    
                    Text("検索履歴はまだありません")
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
            }
            .navigationTitle("ホーム")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    /// 指定の履歴を削除
    private func deleteHistories(at offsets: IndexSet) {
        for offset in offsets {
            modelContext.delete(searchHistories[offset])
        }
    }
    
    /// すべての履歴を削除
    private func deleteAllHistories() {
        for history in searchHistories {
            modelContext.delete(history)
        }
    }
}

/// 検索履歴の1行表示
private struct HistoryRow: View {
    let history: SearchHistory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundStyle(.blue)
                
                Text(history.resultStationName)
                    .font(.body)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(history.formattedTotalTime)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Text("\(history.memberCount)人で検索")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(history.formattedDate)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Station.self, SearchHistory.self], inMemory: true)
}
