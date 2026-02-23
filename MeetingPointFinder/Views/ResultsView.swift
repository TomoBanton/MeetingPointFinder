//
//  ResultsView.swift
//  MeetingPointFinder
//
//  検索結果画面: 候補駅の地図表示とランキングリスト
//

import SwiftUI
import MapKit

struct ResultsView: View {
    let viewModel: MeetingViewModel
    
    /// 地図のカメラポジション
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        VStack(spacing: 0) {
            // 地図エリア: 候補駅をピンで表示
            Map(position: $cameraPosition) {
                // 候補駅のピン
                ForEach(Array(viewModel.results.enumerated()), id: \.element.id) { index, result in
                    Annotation(
                        "\(index + 1). \(result.station.name)",
                        coordinate: result.station.coordinate
                    ) {
                        ZStack {
                            Circle()
                                .fill(rankColor(for: index))
                                .frame(width: 30, height: 30)
                            
                            Text("\(index + 1)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                    }
                }
                
                // メンバーの出発地点ピン
                ForEach(viewModel.members) { member in
                    if let coord = member.departureLocation {
                        Annotation(member.name, coordinate: coord) {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.orange)
                        }
                    }
                }
            }
            .frame(height: 280)
            .mapControls {
                MapCompass()
                MapScaleView()
            }
            
            // 結果リスト
            if viewModel.results.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("候補駅が見つかりませんでした")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            } else {
                List {
                    Section {
                        ForEach(Array(viewModel.results.enumerated()), id: \.element.id) { index, result in
                            NavigationLink(destination: ResultDetailView(result: result, members: viewModel.members)) {
                                ResultRow(result: result, rank: index + 1)
                            }
                        }
                    } header: {
                        Text("候補駅ランキング（\(viewModel.results.count)件）")
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("検索結果")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    /// ランクに応じた色を返す
    private func rankColor(for index: Int) -> Color {
        switch index {
        case 0: return .blue
        case 1: return .green
        case 2: return .orange
        default: return .gray
        }
    }
}

/// 結果1行の表示
private struct ResultRow: View {
    let result: MeetingResult
    let rank: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // ランク表示
            ZStack {
                Circle()
                    .fill(rankColor)
                    .frame(width: 36, height: 36)
                
                Text("\(rank)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
            
            // 駅情報
            VStack(alignment: .leading, spacing: 4) {
                Text(result.station.name)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(result.station.lineName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // 時間情報
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text("合計 \(result.formattedTotalTime)")
                        .font(.caption)
                }
                .foregroundStyle(.blue)
                
                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.caption2)
                    Text("最大 \(result.formattedMaxTime)")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .blue
        case 2: return .green
        case 3: return .orange
        default: return .gray
        }
    }
}

#Preview {
    NavigationStack {
        ResultsView(viewModel: MeetingViewModel())
    }
}
