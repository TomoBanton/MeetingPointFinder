//
//  MeetingResult.swift
//  MeetingPointFinder
//
//  合流地点検索結果のデータ構造体
//

import Foundation

/// 各メンバーの移動時間情報
struct MemberTravelTime: Identifiable {
    let id = UUID()
    
    /// メンバー名
    let memberName: String
    
    /// 移動時間（秒）
    let travelTime: TimeInterval
    
    /// 交通手段
    let transportMode: TransportMode
    
    /// 移動時間のフォーマット済み文字列
    var formattedTravelTime: String {
        let hours = Int(travelTime) / 3600
        let minutes = (Int(travelTime) % 3600) / 60
        if hours > 0 {
            return "\(hours)時間\(minutes)分"
        } else {
            return "\(minutes)分"
        }
    }
}

/// 合流地点の検索結果
struct MeetingResult: Identifiable {
    let id = UUID()
    
    /// 候補駅
    let station: Station
    
    /// 各メンバーの移動時間一覧
    let memberTravelTimes: [MemberTravelTime]
    
    /// 全メンバーの合計移動時間（秒）
    let totalTime: TimeInterval
    
    /// 全メンバーの最大移動時間（秒）
    let maxTime: TimeInterval
    
    /// 合計移動時間のフォーマット済み文字列
    var formattedTotalTime: String {
        formatTime(totalTime)
    }
    
    /// 最大移動時間のフォーマット済み文字列
    var formattedMaxTime: String {
        formatTime(maxTime)
    }
    
    /// 秒数を「○時間○分」形式に変換
    private func formatTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        if hours > 0 {
            return "\(hours)時間\(minutes)分"
        } else {
            return "\(minutes)分"
        }
    }
}
