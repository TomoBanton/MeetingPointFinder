//
//  TransitAPIService.swift
//  MeetingPointFinder
//
//  乗換検索APIサービス（Phase 2で実装予定）
//
//  TODO: Phase 2でGoogle Maps Directions APIのtransitモードを実装
//  現在はRouteCalculatorの距離ベース推定を使用中
//

import Foundation
import CoreLocation

// MARK: - APIレスポンスのデータ構造体

/// Google Maps Directions APIのレスポンス
struct DirectionsResponse: Codable {
    let routes: [DirectionsRoute]
    let status: String
}

/// ルート情報
struct DirectionsRoute: Codable {
    let legs: [DirectionsLeg]
    let summary: String?
}

/// ルートの区間情報
struct DirectionsLeg: Codable {
    let distance: DirectionsValue
    let duration: DirectionsValue
    let steps: [DirectionsStep]?
    let departureTime: DirectionsValue?
    let arrivalTime: DirectionsValue?
    
    enum CodingKeys: String, CodingKey {
        case distance, duration, steps
        case departureTime = "departure_time"
        case arrivalTime = "arrival_time"
    }
}

/// 距離・時間の値
struct DirectionsValue: Codable {
    let text: String
    let value: Int
}

/// ルートのステップ情報
struct DirectionsStep: Codable {
    let distance: DirectionsValue
    let duration: DirectionsValue
    let travelMode: String
    let transitDetails: TransitDetails?
    
    enum CodingKeys: String, CodingKey {
        case distance, duration
        case travelMode = "travel_mode"
        case transitDetails = "transit_details"
    }
}

/// 乗換詳細情報
struct TransitDetails: Codable {
    let line: TransitLine?
    let departureStop: TransitStop?
    let arrivalStop: TransitStop?
    let numStops: Int?
    
    enum CodingKeys: String, CodingKey {
        case line
        case departureStop = "departure_stop"
        case arrivalStop = "arrival_stop"
        case numStops = "num_stops"
    }
}

/// 路線情報
struct TransitLine: Codable {
    let name: String?
    let shortName: String?
    let vehicle: TransitVehicle?
    
    enum CodingKeys: String, CodingKey {
        case name
        case shortName = "short_name"
        case vehicle
    }
}

/// 停留所情報
struct TransitStop: Codable {
    let name: String
    let location: TransitLocation?
}

/// 位置情報
struct TransitLocation: Codable {
    let lat: Double
    let lng: Double
}

/// 乗り物情報
struct TransitVehicle: Codable {
    let name: String?
    let type: String?
}

// MARK: - TransitAPIService

/// 乗換検索APIサービス
///
/// TODO: Phase 2で実装
/// - Google Maps Directions APIのtransitモードを使用
/// - APIキーのInfo.plistまたは環境変数からの取得
/// - レートリミットの考慮
/// - キャッシュ機構の実装
enum TransitAPIService {
    
    /// Google Maps Directions APIのベースURL
    private static let baseURL = "https://maps.googleapis.com/maps/api/directions/json"
    
    /// APIキー（Phase 2で設定）
    private static var apiKey: String {
        // TODO: Info.plistまたは環境変数から取得
        return ""
    }
    
    /// 乗換検索で移動時間を取得
    ///
    /// TODO: Phase 2で実装
    ///
    /// - Parameters:
    ///   - from: 出発地点
    ///   - to: 目的地
    /// - Returns: 移動時間（秒）
    static func fetchTransitTime(
        from: CLLocationCoordinate2D,
        to: CLLocationCoordinate2D
    ) async throws -> TimeInterval {
        // Phase 2で実装予定
        // 現在はダミー値を返す
        fatalError("TransitAPIServiceはまだ実装されていません。RouteCalculatorを使用してください。")
    }
}
