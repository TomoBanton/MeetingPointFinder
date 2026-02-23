//
//  StationDataService.swift
//  MeetingPointFinder
//
//  駅データのインポート・検索サービス
//  CSVからの読み込みとHaversine距離での近傍駅検索
//

import Foundation
import SwiftData
import CoreLocation

enum StationDataServiceError: LocalizedError {
    case csvFileNotFound
    case parseError(String)
    
    var errorDescription: String? {
        switch self {
        case .csvFileNotFound:
            return "stations_sample.csvが見つかりません"
        case .parseError(let message):
            return "CSV解析エラー: \(message)"
        }
    }
}

enum StationDataService {
    
    /// Bundle内のCSVファイルから駅データをインポート
    ///
    /// CSVフォーマット: station_cd,station_name,lat,lon,line_name,pref_cd
    /// 駅データ.jpのフォーマットに対応
    ///
    /// - Parameter modelContext: SwiftDataのモデルコンテキスト
    @MainActor
    static func importStationsFromCSV(modelContext: ModelContext) async throws {
        // CSVファイルのパスを取得
        guard let csvPath = Bundle.main.path(forResource: "stations_sample", ofType: "csv") else {
            throw StationDataServiceError.csvFileNotFound
        }
        
        // CSVファイルを読み込み
        let csvContent = try String(contentsOfFile: csvPath, encoding: .utf8)
        let lines = csvContent.components(separatedBy: .newlines)
        
        // ヘッダー行をスキップしてデータ行を処理
        for (index, line) in lines.enumerated() {
            // ヘッダー行と空行をスキップ
            guard index > 0, !line.trimmingCharacters(in: .whitespaces).isEmpty else {
                continue
            }
            
            let columns = line.components(separatedBy: ",")
            
            // カラム数のバリデーション
            guard columns.count >= 6 else {
                continue
            }
            
            // 各カラムをパース
            guard let stationCd = Int(columns[0].trimmingCharacters(in: .whitespaces)),
                  let lat = Double(columns[2].trimmingCharacters(in: .whitespaces)),
                  let lon = Double(columns[3].trimmingCharacters(in: .whitespaces)),
                  let prefCd = Int(columns[5].trimmingCharacters(in: .whitespaces)) else {
                continue
            }
            
            let stationName = columns[1].trimmingCharacters(in: .whitespaces)
            let lineName = columns[4].trimmingCharacters(in: .whitespaces)
            
            // Stationモデルを作成して挿入
            let station = Station(
                id: stationCd,
                name: stationName,
                lat: lat,
                lon: lon,
                lineName: lineName,
                prefectureCode: prefCd
            )
            
            modelContext.insert(station)
        }
        
        // 変更を保存
        try modelContext.save()
    }
    
    /// 指定座標から近い駅を取得
    ///
    /// Haversine距離でソートして上位N件を返す
    ///
    /// - Parameters:
    ///   - coordinate: 中心座標
    ///   - count: 取得数
    ///   - modelContext: SwiftDataのモデルコンテキスト
    /// - Returns: 近い順にソートされた駅の配列
    @MainActor
    static func fetchNearestStations(
        to coordinate: CLLocationCoordinate2D,
        count: Int,
        modelContext: ModelContext
    ) throws -> [Station] {
        // 全駅データを取得
        let descriptor = FetchDescriptor<Station>()
        let allStations = try modelContext.fetch(descriptor)
        
        // Haversine距離でソート
        let sortedStations = allStations.sorted { station1, station2 in
            let distance1 = HaversineDistance.haversine(
                lat1: coordinate.latitude,
                lon1: coordinate.longitude,
                lat2: station1.lat,
                lon2: station1.lon
            )
            let distance2 = HaversineDistance.haversine(
                lat1: coordinate.latitude,
                lon1: coordinate.longitude,
                lat2: station2.lat,
                lon2: station2.lon
            )
            return distance1 < distance2
        }
        
        // 上位N件を返す
        return Array(sortedStations.prefix(count))
    }
}
