//
//  Station.swift
//  MeetingPointFinder
//
//  駅データSwiftDataモデル
//  駅データ.jpのCSVフォーマットに対応
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class Station {
    /// 駅コード（駅データ.jpのstation_cd）
    var id: Int
    
    /// 駅名
    var name: String
    
    /// 緯度
    var lat: Double
    
    /// 経度
    var lon: Double
    
    /// 路線名
    var lineName: String
    
    /// 都道府県コード
    var prefectureCode: Int
    
    /// CLLocationCoordinate2Dへの変換プロパティ
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    init(id: Int, name: String, lat: Double, lon: Double, lineName: String, prefectureCode: Int) {
        self.id = id
        self.name = name
        self.lat = lat
        self.lon = lon
        self.lineName = lineName
        self.prefectureCode = prefectureCode
    }
}
