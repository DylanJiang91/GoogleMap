//
//  GMMainViewController.swift
//  MapDemo
//
//  Created by jiang hong on 2023/12/1.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

let preciseLocationZoomLevel: Float = 15.0
let approximateLocationZoomLevel: Float = 10.0
let mapId = "8109bfcaa9c1d7c1"

class GMMainViewController: UIViewController {
    
    private lazy var backView: UIButton = {
        let btn = UIButton(frame: CGRect(x: 10, y: UIDevice.statusBarHeight(), width: 44, height: 44))
        btn.setImage(UIImage(named: "icon_back"), for: .normal)
        btn.isUserInteractionEnabled = true
        return btn
    }()
    
    private lazy var startBtn: UIButton = {
        let width = 100
        let height = 44
        let y = UIDevice.statusBarHeight()
        let x = Int(self.view.bounds.size.width) - 10 - width
        let btn = UIButton(frame: CGRect(x: Int(x), y: Int(y), width: width, height: height))
        btn.setTitle("开始导航", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        return btn
    }()
    
    private lazy var showLineBtn: UIButton = {
        let width = 100
        let height = 44
        let y = CGRectGetMaxY(startBtn.frame)
        let x = Int(self.view.bounds.size.width) - 10 - width
        let btn = UIButton(frame: CGRect(x: Int(x), y: Int(y), width: width, height: height))
        btn.setTitle("路线", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        return btn
    }()
    
    private lazy var historyBtn: UIButton = {
        let width = 100
        let height = 44
        let y = CGRectGetMaxY(showLineBtn.frame)
        let x = Int(self.view.bounds.size.width) - 10 - width
        let btn = UIButton(frame: CGRect(x: Int(x), y: Int(y), width: width, height: height))
        btn.setTitle("精彩回顾", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        return btn
    }()
    
    private var mapView: GMSMapView?
    private lazy var locationManager: CLLocationManager = CLLocationManager()
    
    // 起点坐标
    private var starting: CLLocationCoordinate2D?
    
    // 终点坐标
    private var finishing: CLLocationCoordinate2D?
    
    private var didStart = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始化
        initSubviews()
        
        // 添加mapview
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: approximateLocationZoomLevel)
        let options = GMSMapViewOptions()
        options.frame = view.bounds
        options.camera = camera
        options.mapID = GMSMapID(identifier: mapId)
        mapView = GMSMapView(options: options)
        mapView?.isUserInteractionEnabled = true
        mapView?.delegate = self
        mapView?.settings.compassButton = true
        mapView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if let mapView = mapView {
            view.insertSubview(mapView, belowSubview: self.backView)
        }
        
        // 定位
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        didStart = false
    }
    
    private func initSubviews() {
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        
        // 添加返回按钮
        backView.addTarget(self, action: #selector(back), for: .touchUpInside)
        view.addSubview(backView)
        
        // 添加开始导航按钮
        startBtn.addTarget(self, action: #selector(startAction), for: .touchUpInside)
        view.addSubview(startBtn)
        
        // 显示路线
        showLineBtn.addTarget(self, action: #selector(lineAction), for: .touchUpInside)
        view.addSubview(showLineBtn)
        
        // 查看历史
        historyBtn.addTarget(self, action: #selector(historyAction), for: .touchUpInside)
        view.addSubview(historyBtn)
    }
    
    private func locationPermissionAlert() {
        let alert = UIAlertController(title: "位置访问权限", message: "请打开位置访问权限，以便于定位您的位置，添加地址信息。", preferredStyle: .alert)
        let cancle = UIAlertAction(title: "取消", style: .cancel)
        let confirm = UIAlertAction(title: "去设置", style: .default) { action in
            if let url = NSURL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url as URL) {
                UIApplication.shared.open(url as URL)
            }
        }
        alert.addAction(cancle)
        alert.addAction(confirm)
        present(alert, animated: true)
    }
    
    // 返回
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
    
    // 开始导航
    @objc private func startAction() {
        didStart = true
        guard let orign = starting, let end = finishing else {
            print("请添加启动或者终点...")
            return
        }
        
        // 得自己手动实现，google map上暂时没提供相关功能
        // 通过不停的定位更新，来绘制线路
    }
    
    // 查看规划路线
    @objc private func lineAction() {
        guard let orign = starting, let end = finishing else {
            print("请添加启动或者终点...")
            return
        }
        
        let path = GMSMutablePath()
        path.add(orign)
        path.add(end)
        
        let line = GMSPolygon(path: path)
        line.map = mapView
    }
    
    // 历史回顾
    @objc private func historyAction() {
        // 生成path
        
    }
    
    deinit {
        didStart = false
    }
}

extension GMMainViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        // 保存终点
        finishing = coordinate
        
        let position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let marker = GMSMarker(position: position)
        marker.title = "Start"
        marker.map = mapView
    }
}

extension GMMainViewController: CLLocationManagerDelegate {
        
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard manager.authorizationStatus != .notDetermined else {
            locationPermissionAlert()
           return
        }
        
        locationManager.startUpdatingLocation()
         
        mapView?.isMyLocationEnabled =  true
        mapView?.settings.myLocationButton =  true
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            // 记录开始坐标
            if didStart == false {
                starting = location.coordinate
            }
            
            let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
            mapView?.camera = GMSCameraPosition(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoomLevel);
        }
    }
}
