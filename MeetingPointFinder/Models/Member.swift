//
//  Member.swift
//  MeetingPointFinder
//
//  合流メンバーのデータモデル
//

import Foundation
import CoreLocation
import Observation

/// 交通手段の列挙型
enum TransportMode: String, CaseIterable, Codable, Identifiable {
    case train = "電車"
    case car = "車"
    
    var id: String { rawValue }
    
    /// アイコン名
    var iconName: String {
        switch self {
        case .train: return "tram.fill"
        case .car: return "car.fill"
        }
    }
}

@Observable
final class Member: Identifiable {
    let id: UUID
    
    /// メンバー名
    var name: String
    
    /// 出発地点の座標
    var departureLocation: CLLocationCoordinate2D?
    
    /// 出発地点の表示名
    var departureLocationName: String
    
    /// 交通手段
    var transportMode: TransportMode
    
    /// 出発地点が設定済みかどうか
    var hasValidDeparture: Bool {
        departureLocation != nil
    }
    
    init(
        id: UUID = UUID(),
        name: String = "",
        departureLocation: CLLocationCoordinate2D? = nil,
        departureLocationName: String = "",
        transportMode: TransportMode = .train
    ) {
        self.id = id
        self.name = name
        self.departureLocation = departureLocation
        self.departureLocationName = departureLocationName
        self.transportMode = transportMode
    }
}
