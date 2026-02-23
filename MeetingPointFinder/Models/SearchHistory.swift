//
//  SearchHistory.swift
//  MeetingPointFinder
//
//  検索履歴のSwiftDataモデル
//

import Foundation
import SwiftData

@Model
final class SearchHistory {
    /// 一意識別子
    var id: UUID
    
    /// 検索日時
    var date: Date
    
    /// 結果駅名（最上位の候補駅）
    var resultStationName: String
    
    /// メンバー数
    var memberCount: Int
    
    /// 合計移動時間（秒）
    var totalTime: TimeInterval
    
    /// 合計移動時間のフォーマット済み文字列
    var formattedTotalTime: String {
        let hours = Int(totalTime) / 3600
        let minutes = (Int(totalTime) % 3600) / 60
        if hours > 0 {
            return "\(hours)時間\(minutes)分"
        } else {
            return "\(minutes)分"
        }
    }
    
    /// 検索日時のフォーマット済み文字列
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        resultStationName: String,
        memberCount: Int,
        totalTime: TimeInterval
    ) {
        self.id = id
        self.date = date
        self.resultStationName = resultStationName
        self.memberCount = memberCount
        self.totalTime = totalTime
    }
}
