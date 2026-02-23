//
//  LocationManager.swift
//  MeetingPointFinder
//
//  位置情報マネージャー: CLLocationManagerDelegateを実装
//

import Foundation
import CoreLocation
import Observation

@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {
    /// CLLocationManagerインスタンス
    private let manager = CLLocationManager()
    
    /// 現在位置
    var currentLocation: CLLocationCoordinate2D?
    
    /// 位置情報取得中フラグ
    var isLoading: Bool = false
    
    /// エラーメッセージ
    var errorMessage: String?
    
    /// 許可状態
    var authorizationStatus: CLAuthorizationStatus {
        manager.authorizationStatus
    }
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    /// 位置情報をリクエスト
    func requestLocation() {
        isLoading = true
        errorMessage = nil
        
        // 許可状態に応じて処理
        switch manager.authorizationStatus {
        case .notDetermined:
            // 初回: 許可をリクエスト
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            // 許可済み: 位置情報を取得
            manager.requestLocation()
        case .denied, .restricted:
            // 拒否・制限: エラーを表示
            isLoading = false
            errorMessage = "位置情報の使用が許可されていません。設定アプリから許可してください。"
        @unknown default:
            isLoading = false
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    /// 許可状態が変更されたとき
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // 許可されたら位置情報を取得
            if isLoading {
                manager.requestLocation()
            }
        case .denied:
            isLoading = false
            errorMessage = "位置情報の使用が拒否されました"
        default:
            break
        }
    }
    
    /// 位置情報が更新されたとき
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        isLoading = false
        
        if let location = locations.last {
            currentLocation = location.coordinate
        }
    }
    
    /// 位置情報取得に失敗したとき
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLoading = false
        errorMessage = "位置情報の取得に失敗しました: \(error.localizedDescription)"
    }
}
