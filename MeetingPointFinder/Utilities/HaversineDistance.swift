//
//  HaversineDistance.swift
//  MeetingPointFinder
//
//  Haversine公式による2地点間の距離計算（km）
//

import Foundation

enum HaversineDistance {
    /// 地球の半径（km）
    private static let earthRadiusKm: Double = 6371.0
    
    /// Haversine公式で2地点間の距離を計算
    ///
    /// - Parameters:
    ///   - lat1: 地点1の緯度（度）
    ///   - lon1: 地点1の経度（度）
    ///   - lat2: 地点2の緯度（度）
    ///   - lon2: 地点2の経度（度）
    /// - Returns: 2地点間の距離（キロメートル）
    static func haversine(
        lat1: Double,
        lon1: Double,
        lat2: Double,
        lon2: Double
    ) -> Double {
        // 度をラジアンに変換
        let dLat = degreesToRadians(lat2 - lat1)
        let dLon = degreesToRadians(lon2 - lon1)
        let lat1Rad = degreesToRadians(lat1)
        let lat2Rad = degreesToRadians(lat2)
        
        // Haversine公式
        let a = sin(dLat / 2) * sin(dLat / 2)
            + cos(lat1Rad) * cos(lat2Rad)
            * sin(dLon / 2) * sin(dLon / 2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        return earthRadiusKm * c
    }
    
    /// 度をラジアンに変換
    private static func degreesToRadians(_ degrees: Double) -> Double {
        return degrees * .pi / 180.0
    }
}
