//
//  LocationPickerView.swift
//  MeetingPointFinder
//
//  出発地点選択画面: 地図上でタップ、GPS、または検索で場所を指定
//

import SwiftUI
import MapKit
import CoreLocation

struct LocationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    
    /// 選択された座標（親ビューへのバインディング）
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    
    /// 選択された場所の名前（親ビューへのバインディング）
    @Binding var locationName: String
    
    /// 位置情報マネージャー
    @State private var locationManager = LocationManager()
    
    /// 地図のカメラポジション（東京駅をデフォルトに）
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )
    
    /// 地図上のピン位置
    @State private var pinCoordinate: CLLocationCoordinate2D?
    @State private var pinLocationName: String = ""
    
    /// 検索テキスト
    @State private var searchText: String = ""
    
    /// 検索結果
    @State private var searchResults: [MKMapItem] = []
    
    /// 検索中フラグ
    @State private var isSearching = false
    
    var body: some View {
        ZStack(alignment: .top) {
            // 地図表示
            Map(position: $cameraPosition, interactionModes: .all) {
                // 選択されたピンを表示
                if let pin = pinCoordinate {
                    Annotation(pinLocationName, coordinate: pin) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundStyle(.red)
                    }
                }
            }
            .onTapGesture { position in
                // 地図タップでピンを配置
                // 注意: iOS 17のMapでは直接座標変換が難しいため、
                // 検索またはGPSでの位置設定を推奨
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            
            // 検索バー
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.gray)
                    
                    TextField("場所を検索", text: $searchText)
                        .textFieldStyle(.plain)
                        .onSubmit {
                            performSearch()
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            searchResults = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.gray)
                        }
                    }
                }
                .padding(12)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                .padding(.top, 8)
                
                // 検索結果リスト
                if !searchResults.isEmpty {
                    List(searchResults, id: \.self) { item in
                        Button(action: {
                            selectSearchResult(item)
                        }) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name ?? "不明な場所")
                                    .font(.body)
                                
                                if let address = item.placemark.title {
                                    Text(address)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .frame(maxHeight: 200)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("出発地点を選択")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("キャンセル") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("決定") {
                    confirmSelection()
                }
                .disabled(pinCoordinate == nil)
            }
            
            ToolbarItem(placement: .bottomBar) {
                // GPSボタン
                Button(action: moveToCurrentLocation) {
                    Label("現在地を使用", systemImage: "location.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .onAppear {
            // 既存の選択座標があればそこにピンを配置
            if let existing = selectedCoordinate {
                pinCoordinate = existing
                pinLocationName = locationName
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: existing,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                )
            }
        }
    }
    
    /// 場所検索を実行
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        isSearching = true
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671),
            span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
        )
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            isSearching = false
            if let response = response {
                searchResults = response.mapItems
            }
        }
    }
    
    /// 検索結果から場所を選択
    private func selectSearchResult(_ item: MKMapItem) {
        let coordinate = item.placemark.coordinate
        pinCoordinate = coordinate
        pinLocationName = item.name ?? "選択した場所"
        searchText = pinLocationName
        searchResults = []
        
        // カメラを選択地点に移動
        cameraPosition = .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        )
    }
    
    /// 現在地に移動
    private func moveToCurrentLocation() {
        locationManager.requestLocation()
        
        // 位置情報取得後にピンを配置
        if let location = locationManager.currentLocation {
            pinCoordinate = location
            pinLocationName = "現在地"
            
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: location,
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                )
            )
            
            // 逆ジオコーディングで地名を取得
            reverseGeocode(coordinate: location)
        }
    }
    
    /// 逆ジオコーディングで座標から地名を取得
    private func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                let name = [
                    placemark.administrativeArea,
                    placemark.locality,
                    placemark.subLocality,
                    placemark.thoroughfare
                ].compactMap { $0 }.joined()
                
                if !name.isEmpty {
                    pinLocationName = name
                }
            }
        }
    }
    
    /// 選択を確定して親ビューに返す
    private func confirmSelection() {
        selectedCoordinate = pinCoordinate
        locationName = pinLocationName
        dismiss()
    }
}

#Preview {
    NavigationStack {
        LocationPickerView(
            selectedCoordinate: .constant(nil),
            locationName: .constant("")
        )
    }
}
