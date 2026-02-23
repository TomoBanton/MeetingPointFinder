//
//  ResultDetailView.swift
//  MeetingPointFinder
//
//  結果詳細画面: 駅とメンバーの位置を地図上に表示、移動時間一覧
//

import SwiftUI
import MapKit

struct ResultDetailView: View {
    let result: MeetingResult
    let members: [Member]
    
    /// 地図のカメラポジション
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        VStack(spacing: 0) {
            // 地図: 駅とメンバーの出発地点を表示
            Map(position: $cameraPosition) {
                // 候補駅のピン
                Annotation(result.station.name, coordinate: result.station.coordinate) {
                    VStack(spacing: 2) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundStyle(.red)
                        
                        Text(result.station.name)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(.white.opacity(0.9))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
                
                // メンバーの出発地点ピン
                ForEach(members) { member in
                    if let coord = member.departureLocation {
                        Annotation(member.name, coordinate: coord) {
                            VStack(spacing: 2) {
                                Image(systemName: member.transportMode.iconName)
                                    .font(.title2)
                                    .foregroundStyle(.orange)
                                    .padding(4)
                                    .background(.white)
                                    .clipShape(Circle())
                                
                                Text(member.name)
                                    .font(.caption2)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    .background(.white.opacity(0.9))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                        }
                    }
                }
            }
            .frame(height: 300)
            .mapControls {
                MapCompass()
                MapScaleView()
            }
            
            // 駅情報ヘッダー
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(.red)
                    
                    Text(result.station.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                
                HStack {
                    Text(result.station.lineName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("合計: \(result.formattedTotalTime)")
                            .font(.caption)
                            .foregroundStyle(.blue)
                        
                        Text("最大: \(result.formattedMaxTime)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            
            // メンバー別移動時間一覧
            List {
                Section {
                    ForEach(result.memberTravelTimes) { travelTime in
                        HStack {
                            // 交通手段アイコン
                            Image(systemName: travelTime.transportMode.iconName)
                                .foregroundStyle(.blue)
                                .frame(width: 24)
                            
                            // メンバー名
                            Text(travelTime.memberName)
                                .font(.body)
                            
                            Spacer()
                            
                            // 交通手段
                            Text(travelTime.transportMode.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(.blue.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                            
                            // 移動時間
                            Text(travelTime.formattedTravelTime)
                                .font(.body)
                                .fontWeight(.medium)
                                .monospacedDigit()
                        }
                    }
                } header: {
                    Text("メンバー別移動時間")
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle("詳細")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let sampleStation = Station(
        id: 1,
        name: "東京",
        lat: 35.6812,
        lon: 139.7671,
        lineName: "JR山手線",
        prefectureCode: 13
    )
    
    let sampleResult = MeetingResult(
        station: sampleStation,
        memberTravelTimes: [
            MemberTravelTime(memberName: "太郎", travelTime: 1800, transportMode: .train),
            MemberTravelTime(memberName: "花子", travelTime: 2400, transportMode: .car)
        ],
        totalTime: 4200,
        maxTime: 2400
    )
    
    NavigationStack {
        ResultDetailView(result: sampleResult, members: [])
    }
}
