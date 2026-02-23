//
//  MeetingViewModel.swift
//  MeetingPointFinder
//
//  合流地点検索のメインロジックを担当するViewModel
//

import Foundation
import SwiftData
import CoreLocation
import Observation

@Observable
final class MeetingViewModel {
    /// メンバー一覧
    var members: [Member] = []
    
    /// 検索結果一覧
    var results: [MeetingResult] = []
    
    /// 検索中フラグ
    var isSearching: Bool = false
    
    /// エラーメッセージ
    var errorMessage: String?
    
    /// 合流地点を検索するメインメソッド
    /// 
    /// アルゴリズム:
    /// 1. 全メンバーの出発地点の重心（セントロイド）を計算
    /// 2. 重心から近いN駅を取得
    /// 3. 各駅について全メンバーの移動時間を計算
    /// 4. 最適化モードに応じてソート
    /// 5. 上位N件を結果として返す
    ///
    /// - Parameters:
    ///   - modelContext: SwiftDataのモデルコンテキスト
    ///   - optimizationMode: 最適化モード（"totalTime" or "maxTime"）
    ///   - candidateCount: 候補駅の取得数
    ///   - resultCount: 結果の表示数
    @MainActor
    func findMeetingPoint(
        modelContext: ModelContext,
        optimizationMode: String = "totalTime",
        candidateCount: Int = 50,
        resultCount: Int = 5
    ) async throws {
        // 検索開始
        isSearching = true
        results = []
        errorMessage = nil
        
        defer {
            isSearching = false
        }
        
        // メンバーの出発地点を取得
        let departureLocations = members.compactMap { $0.departureLocation }
        
        guard departureLocations.count == members.count else {
            throw MeetingPointError.missingDepartureLocation
        }
        
        guard departureLocations.count >= 2 else {
            throw MeetingPointError.insufficientMembers
        }
        
        // ステップ1: 重心（セントロイド）を計算
        let centroid = calculateCentroid(locations: departureLocations)
        
        // ステップ2: 重心から近い駅を取得
        let candidateStations = try StationDataService.fetchNearestStations(
            to: centroid,
            count: candidateCount,
            modelContext: modelContext
        )
        
        guard !candidateStations.isEmpty else {
            throw MeetingPointError.noStationsFound
        }
        
        // ステップ3: 各駅について全メンバーの移動時間を計算
        var meetingResults: [MeetingResult] = []
        
        for station in candidateStations {
            var memberTravelTimes: [MemberTravelTime] = []
            var totalTime: TimeInterval = 0
            var maxTime: TimeInterval = 0
            var hasError = false
            
            for member in members {
                guard let departure = member.departureLocation else {
                    hasError = true
                    break
                }
                
                do {
                    // 移動時間を計算
                    let travelTime = try await RouteCalculator.calculateTravelTime(
                        from: departure,
                        to: station.coordinate,
                        transportMode: member.transportMode
                    )
                    
                    let memberTravelTime = MemberTravelTime(
                        memberName: member.name,
                        travelTime: travelTime,
                        transportMode: member.transportMode
                    )
                    
                    memberTravelTimes.append(memberTravelTime)
                    totalTime += travelTime
                    maxTime = max(maxTime, travelTime)
                } catch {
                    // ルート計算失敗時はスキップ
                    hasError = true
                    break
                }
            }
            
            // エラーがなければ結果に追加
            if !hasError {
                let result = MeetingResult(
                    station: station,
                    memberTravelTimes: memberTravelTimes,
                    totalTime: totalTime,
                    maxTime: maxTime
                )
                meetingResults.append(result)
            }
        }
        
        // ステップ4: 最適化モードに応じてソート
        switch optimizationMode {
        case "maxTime":
            // 最大移動時間が最も短い順
            meetingResults.sort { $0.maxTime < $1.maxTime }
        default:
            // 合計移動時間が最も短い順
            meetingResults.sort { $0.totalTime < $1.totalTime }
        }
        
        // ステップ5: 上位N件を結果として返す
        results = Array(meetingResults.prefix(resultCount))
    }
    
    /// 全メンバーの出発地点の重心（セントロイド）を計算
    ///
    /// 単純な緯度・経度の平均を使用
    /// （日本国内の範囲であれば十分な精度）
    private func calculateCentroid(locations: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
        let totalLat = locations.reduce(0.0) { $0 + $1.latitude }
        let totalLon = locations.reduce(0.0) { $0 + $1.longitude }
        let count = Double(locations.count)
        
        return CLLocationCoordinate2D(
            latitude: totalLat / count,
            longitude: totalLon / count
        )
    }
}

/// 合流地点検索のエラー定義
enum MeetingPointError: LocalizedError {
    case missingDepartureLocation
    case insufficientMembers
    case noStationsFound
    case calculationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .missingDepartureLocation:
            return "すべてのメンバーの出発地点を設定してください"
        case .insufficientMembers:
            return "最低2人のメンバーが必要です"
        case .noStationsFound:
            return "近くに駅が見つかりませんでした。駅データをインポートしてください"
        case .calculationFailed(let message):
            return "計算エラー: \(message)"
        }
    }
}
