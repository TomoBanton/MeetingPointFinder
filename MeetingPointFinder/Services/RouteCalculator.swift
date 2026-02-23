//
//  RouteCalculator.swift
//  MeetingPointFinder
//
//  ルート計算サービス:
//  車はMKDirections、電車は距離ベースの推定（MVP）
//

import Foundation
import MapKit
import CoreLocation

enum RouteCalculatorError: LocalizedError {
    case noRouteFound
    case directionsError(String)
    
    var errorDescription: String? {
        switch self {
        case .noRouteFound:
            return "ルートが見つかりませんでした"
        case .directionsError(let message):
            return "ルート計算エラー: \(message)"
        }
    }
}

enum RouteCalculator {
    
    /// 出発地点から目的地までの移動時間を計算
    ///
    /// - Parameters:
    ///   - from: 出発地点の座標
    ///   - to: 目的地の座標
    ///   - transportMode: 交通手段
    /// - Returns: 移動時間（秒）
    static func calculateTravelTime(
        from: CLLocationCoordinate2D,
        to: CLLocationCoordinate2D,
        transportMode: TransportMode
    ) async throws -> TimeInterval {
        switch transportMode {
        case .car:
            // 車: MKDirectionsで実際のルートを計算
            return try await calculateCarTravelTime(from: from, to: to)
            
        case .train:
            // 電車: MVPでは距離ベースの推定を使用
            // TODO: Phase 2でGoogle Maps Directions APIの乗換検索に置き換え
            return calculateTrainTravelTimeEstimate(from: from, to: to)
        }
    }
    
    // MARK: - 車のルート計算
    
    /// MKDirectionsを使用して車の移動時間を計算
    private static func calculateCarTravelTime(
        from: CLLocationCoordinate2D,
        to: CLLocationCoordinate2D
    ) async throws -> TimeInterval {
        let request = MKDirections.Request()
        
        request.source = MKMapItem(
            placemark: MKPlacemark(coordinate: from)
        )
        request.destination = MKMapItem(
            placemark: MKPlacemark(coordinate: to)
        )
        request.transportType = .automobile
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        
        do {
            let response = try await directions.calculate()
            
            guard let route = response.routes.first else {
                throw RouteCalculatorError.noRouteFound
            }
            
            return route.expectedTravelTime
        } catch let error as RouteCalculatorError {
            throw error
        } catch {
            throw RouteCalculatorError.directionsError(error.localizedDescription)
        }
    }
    
    // MARK: - 電車の移動時間推定
    
    /// 距離ベースで電車の移動時間を推定
    ///
    /// MVP実装:
    /// - 平均速度: 40km/h（待ち時間・停車時間含む）
    /// - 乗り換え追加時間: 10分（600秒）
    /// - 最寻アクセス時間: 5分（300秒）
    ///
    /// TODO: 実際の乗換検索APIに置き換えることで精度向上
    private static func calculateTrainTravelTimeEstimate(
        from: CLLocationCoordinate2D,
        to: CLLocationCoordinate2D
    ) -> TimeInterval {
        // Haversine距離を計算（km）
        let distanceKm = HaversineDistance.haversine(
            lat1: from.latitude,
            lon1: from.longitude,
            lat2: to.latitude,
            lon2: to.longitude
        )
        
        // 平均速度40km/hで移動時間を計算（秒）
        let averageSpeedKmPerHour: Double = 40.0
        let travelTimeSeconds = (distanceKm / averageSpeedKmPerHour) * 3600.0
        
        // 乗り換え時間を追加（10分）
        let transferTime: TimeInterval = 600.0
        
        // 最寻アクセス時間を追加（5分）
        let accessTime: TimeInterval = 300.0
        
        return travelTimeSeconds + transferTime + accessTime
    }
}
