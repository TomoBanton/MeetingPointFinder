//
//  MemberSetupView.swift
//  MeetingPointFinder
//
//  メンバー設定画面: 出発地点・交通手段の設定と検索実行
//

import SwiftUI
import SwiftData
import CoreLocation

struct MemberSetupView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var viewModel = MeetingViewModel()
    
    /// 検索結果画面へのナビゲーションフラグ
    @State private var showResults = false
    
    /// エラーメッセージの表示
    @State private var showError = false
    @State private var errorMessage = ""
    
    /// 設定値の取得
    @AppStorage("optimizationMode") private var optimizationMode = "totalTime"
    @AppStorage("candidateStationCount") private var candidateStationCount = 50
    @AppStorage("resultCount") private var resultCount = 5
    
    var body: some View {
        List {
            // メンバー一覧セクション
            Section {
                ForEach(Array(viewModel.members.enumerated()), id: \.element.id) { index, member in
                    MemberRow(
                        member: member,
                        index: index
                    )
                }
                .onDelete(perform: deleteMember)
                
                // メンバー追加ボタン
                Button(action: addMember) {
                    Label("メンバーを追加", systemImage: "person.badge.plus")
                }
            } header: {
                Text("メンバー（\(viewModel.members.count)人）")
            } footer: {
                Text("最低2人のメンバーが必要です")
                    .foregroundStyle(.secondary)
            }
            
            // 検索実行セクション
            Section {
                Button(action: startSearch) {
                    HStack {
                        Spacer()
                        
                        if viewModel.isSearching {
                            ProgressView()
                                .padding(.trailing, 8)
                            Text("検索中...")
                        } else {
                            Image(systemName: "magnifyingglass")
                            Text("検索開始")
                        }
                        
                        Spacer()
                    }
                    .font(.headline)
                    .padding(.vertical, 4)
                }
                .disabled(!canSearch)
            } footer: {
                if !canSearch {
                    Text("すべてのメンバーの名前と出発地点を設定してください")
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("メンバー設定")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showResults) {
            ResultsView(viewModel: viewModel)
        }
        .alert("エラー", isPresented: $showError) {
            Button("閉じる", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            // 初期表示時に2人分のメンバーを追加
            if viewModel.members.isEmpty {
                viewModel.members = [
                    Member(name: "メンバー1"),
                    Member(name: "メンバー2")
                ]
            }
        }
    }
    
    /// 検索可能かどうかの判定
    private var canSearch: Bool {
        viewModel.members.count >= 2
        && viewModel.members.allSatisfy { $0.hasValidDeparture && !$0.name.isEmpty }
        && !viewModel.isSearching
    }
    
    /// メンバーを追加
    private func addMember() {
        let newIndex = viewModel.members.count + 1
        viewModel.members.append(Member(name: "メンバー\(newIndex)"))
    }
    
    /// メンバーを削除（最低2人は維持）
    private func deleteMember(at offsets: IndexSet) {
        guard viewModel.members.count - offsets.count >= 2 else {
            errorMessage = "メンバーは最低2人必要です"
            showError = true
            return
        }
        viewModel.members.remove(atOffsets: offsets)
    }
    
    /// 検索を開始
    private func startSearch() {
        Task {
            do {
                try await viewModel.findMeetingPoint(
                    modelContext: modelContext,
                    optimizationMode: optimizationMode,
                    candidateCount: candidateStationCount,
                    resultCount: resultCount
                )
                
                // 検索履歴を保存
                if let topResult = viewModel.results.first {
                    let history = SearchHistory(
                        resultStationName: topResult.station.name,
                        memberCount: viewModel.members.count,
                        totalTime: topResult.totalTime
                    )
                    modelContext.insert(history)
                }
                
                showResults = true
            } catch {
                errorMessage = "検索中にエラーが発生しました: \(error.localizedDescription)"
                showError = true
            }
        }
    }
}

/// メンバー1人分の行表示
private struct MemberRow: View {
    @Bindable var member: Member
    let index: Int
    
    /// 出発地点選択画面の表示フラグ
    @State private var showLocationPicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // メンバー名入力
            HStack {
                Image(systemName: "person.fill")
                    .foregroundStyle(.blue)
                
                TextField("名前", text: $member.name)
                    .textFieldStyle(.roundedBorder)
            }
            
            // 交通手段選択
            Picker("交通手段", selection: $member.transportMode) {
                ForEach(TransportMode.allCases) { mode in
                    Label(mode.rawValue, systemImage: mode.iconName)
                        .tag(mode)
                }
            }
            .pickerStyle(.segmented)
            
            // 出発地点設定ボタン
            Button(action: { showLocationPicker = true }) {
                HStack {
                    Image(systemName: member.hasValidDeparture ? "mappin.circle.fill" : "mappin.circle")
                        .foregroundStyle(member.hasValidDeparture ? .green : .gray)
                    
                    Text(member.hasValidDeparture ? member.departureLocationName : "出発地点を設定")
                        .foregroundStyle(member.hasValidDeparture ? .primary : .secondary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showLocationPicker) {
            NavigationStack {
                LocationPickerView(
                    selectedCoordinate: $member.departureLocation,
                    locationName: $member.departureLocationName
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        MemberSetupView()
    }
    .modelContainer(for: [Station.self, SearchHistory.self], inMemory: true)
}
