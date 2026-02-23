//
//  SettingsView.swift
//  MeetingPointFinder
//
//  設定画面: 最適化モード、候補駅数、表示結果数の設定
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    /// 最適化モード: 合計最短 or 最大最短
    @AppStorage("optimizationMode") private var optimizationMode = "totalTime"
    
    /// 候補駅の検索数（30-100）
    @AppStorage("candidateStationCount") private var candidateStationCount = 50
    
    /// 表示結果数（3-10）
    @AppStorage("resultCount") private var resultCount = 5
    
    @Environment(\.modelContext) private var modelContext
    
    /// 駅データインポート状態
    @State private var isImporting = false
    @State private var importMessage = ""
    @State private var showImportAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                // 最適化モード
                Section {
                    Picker("最適化モード", selection: $optimizationMode) {
                        Text("合計時間が最短")
                            .tag("totalTime")
                        Text("最大時間が最短")
                            .tag("maxTime")
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("最適化モード")
                } footer: {
                    switch optimizationMode {
                    case "totalTime":
                        Text("全員の移動時間の合計が最も少ない駅を優先します")
                    case "maxTime":
                        Text("最も遠い人の移動時間が最も短い駅を優先します")
                    default:
                        EmptyView()
                    }
                }
                
                // 候補駅数
                Section {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("候補駅数")
                            Spacer()
                            Text("\(candidateStationCount)駅")
                                .foregroundStyle(.secondary)
                        }
                        
                        Slider(
                            value: Binding(
                                get: { Double(candidateStationCount) },
                                set: { candidateStationCount = Int($0) }
                            ),
                            in: 30...100,
                            step: 10
                        )
                    }
                } header: {
                    Text("検索設定")
                } footer: {
                    Text("中心点から近い駅をこの数だけ取得して計算します。数が大きいほど精度が上がりますが、計算に時間がかかります。")
                }
                
                // 表示結果数
                Section {
                    Stepper(
                        value: $resultCount,
                        in: 3...10
                    ) {
                        HStack {
                            Text("表示結果数")
                            Spacer()
                            Text("\(resultCount)件")
                                .foregroundStyle(.secondary)
                        }
                    }
                } footer: {
                    Text("検索結果に表示する候補駅の件数です")
                }
                
                // 駅データ管理
                Section {
                    Button(action: importStationData) {
                        HStack {
                            if isImporting {
                                ProgressView()
                                    .padding(.trailing, 4)
                            }
                            
                            Text(isImporting ? "インポート中..." : "駅データをインポート")
                        }
                    }
                    .disabled(isImporting)
                } header: {
                    Text("データ管理")
                } footer: {
                    Text("アプリ同梱のCSVファイルから駅データをインポートします。初回起動時に自動でインポートされます。")
                }
                
                // アプリ情報
                Section {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("駅データソース")
                        Spacer()
                        Text("駅データ.jp")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("アプリ情報")
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .alert("駅データ", isPresented: $showImportAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(importMessage)
            }
        }
    }
    
    /// 駅データをCSVからインポート
    private func importStationData() {
        isImporting = true
        
        Task {
            do {
                try await StationDataService.importStationsFromCSV(modelContext: modelContext)
                importMessage = "駅データのインポートが完了しました"
            } catch {
                importMessage = "インポートに失敗しました: \(error.localizedDescription)"
            }
            
            isImporting = false
            showImportAlert = true
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [Station.self, SearchHistory.self], inMemory: true)
}
