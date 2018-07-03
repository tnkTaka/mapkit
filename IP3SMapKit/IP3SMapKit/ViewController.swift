//
//  ViewController.swift
//  IP3SMapKit
//
//  Created by web on 2018/05/18.
//  Copyright © 2018年 web. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,UISearchBarDelegate,CLLocationManagerDelegate,MKMapViewDelegate{
    
    let tokyo = CLLocationCoordinate2DMake(35.691529,139.696872)
    let osaka = CLLocationCoordinate2DMake(34.699875,135.493032)
    let nagoya = CLLocationCoordinate2DMake(35.168165,136.885778)
    let apple = CLLocationCoordinate2DMake(37.322998,-122.032182)

    var state = 0
    var nowAnnotations : [MKAnnotation] = []
    var myLocationManager:CLLocationManager!
    
    @IBOutlet weak var displayMap: MKMapView!
    @IBOutlet weak var searchText: UISearchBar!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 位置情報取得の許可を求めるメッセージの表示.必須.
        myLocationManager = CLLocationManager()
        
        myLocationManager.delegate = self
        
        //位置情報の許可を得る(アプリ起動時)
        myLocationManager.requestWhenInUseAuthorization()
        
        searchText.delegate = self
        displayMap.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //delegateメソッド
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        //ピンのカスタマイズ
        let nowAnnotationView = MKPinAnnotationView()
        if let nowAnnotation = annotation as? MyPointAnnotation {
            nowAnnotationView.annotation = annotation
            nowAnnotationView.pinTintColor = nowAnnotation.pinColor
        }
        // pinのイベントを許可する
        nowAnnotationView.canShowCallout = true
        
        // pinをタップした時に出てくるポップアップの右側にボタンをつける
        nowAnnotationView.rightCalloutAccessoryView = UIButton(type: .infoLight)
        
        return nowAnnotationView
    }
    
    //吹き出しに表示されているボタンが押された時に動くメソッド
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //URLスキームを使用した外部アプリの起動
        let strUrl:String = view.annotation!.subtitle! ?? "null"
        if let url = URL(string: strUrl), UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url)
        }
        
    }
    
    //緯度・経度情報(GPS)が変わった時に動く
    func locationManager(_ manager: CLLocationManager,didUpdateLocations locations: [CLLocation]) {
        print("緯度:\(String(describing: manager.location?.coordinate.latitude.description))")
        print("経度:\(String(describing: manager.location?.coordinate.longitude.description))")
        
        self.latitudeLabel.text = "緯度：\(myLocationManager.location!.coordinate.latitude)"
        self.longitudeLabel.text = "経度：\(myLocationManager.location!.coordinate.longitude)"
        
        myLocationManager.distanceFilter = 50.0
        
        let pin = MyPointAnnotation()
        pin.pinColor = UIColor.blue
        pin.coordinate = myLocationManager.location!.coordinate
        displayMap.addAnnotation(pin)
        let span = MKCoordinateSpanMake(0.005, 0.005) //1度...111km
        let region = MKCoordinateRegionMake(myLocationManager.location!.coordinate, span); displayMap.setRegion(region, animated:true)
        nowAnnotations.append(pin)
    }
    
    //緯度・経度情報(GPS)が取れなかった時に動く
    func locationManager(_ manager: CLLocationManager,didFailWithError error: Error){
        print(error)
    }
    
    //トラッキング
    var count = 0
    @IBOutlet weak var trackingButtonTitle: UIButton!
    @IBAction func trackingButton(_ sender: Any) {
        if(count == 0){
            print("trackingStart")
            myLocationManager.startUpdatingLocation()
            trackingButtonTitle.setTitle("終了", for: .normal) // ボタンのタイトル
            count += 1
        }else{
            print("trackingEnd")
            myLocationManager.stopUpdatingLocation()
            trackingButtonTitle.setTitle("開始", for: .normal) // ボタンのタイトル
            count = 0
        }
    }
    
    //ピンの削除
    @IBAction func clearButton(_ sender: Any) {
        for nowAnnotation in nowAnnotations{
            displayMap.removeAnnotation(nowAnnotation)
        }
    }
    
    // 検索ボタンが押された時に呼ばれる
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
        self.view.endEditing(true)
        searchBar.showsCancelButton = true
        // セット済みのピンを削除
        self.displayMap.removeAnnotations(self.displayMap.annotations)
        
        let myGeocoder = CLGeocoder()
        myGeocoder.geocodeAddressString(searchText.text!, completionHandler: {(placemarks:[CLPlacemark]?,error:Error?) in
            if let placemark = placemarks?[0]{
                if let targetCoordinate = placemark.location?.coordinate{
                    let span = MKCoordinateSpanMake(0.005, 0.005) //1度...111km
                    self.displayMap.removeAnnotations(self.displayMap.annotations)
                    let pin = MyPointAnnotation()
                    pin.pinColor = UIColor.green
                    
                    pin.coordinate = targetCoordinate
                    self.displayMap.addAnnotation(pin)
                    let region = MKCoordinateRegionMake(targetCoordinate,span)
                    self.displayMap.setRegion(region, animated: true)
                    self.latitudeLabel.text = "緯度：\(targetCoordinate.latitude)"
                    self.longitudeLabel.text = "経度：\(targetCoordinate.longitude)"
                }
            }
        })
    }
    
    // キャンセルボタンが押された時に呼ばれる
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarCancelButtonClicked")
        searchBar.showsCancelButton = false
        self.view.endEditing(true)
        searchBar.text = ""
    }
    
    // テキストフィールド入力開始前に呼ばれる
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        print("searchBarShouldBeginEditing")
        searchBar.showsCancelButton = true
        return true
    }
    
    @IBAction func ActionButton(_ sender: Any) {
        displayMap.removeAnnotations(displayMap.annotations)
        let buttonTagButton:UIButton = sender as!UIButton; print(buttonTagButton.tag)
        let pin = MyPointAnnotation();
        switch buttonTagButton.tag {
        case 0:
            pin.coordinate = osaka;
            pin.title="HAL大阪";
            pin.subtitle="https://www.hal.ac.jp/osaka"
            displayMap.addAnnotation(pin)
            
            let span = MKCoordinateSpanMake(0.005, 0.005) //1度...111km
            let region = MKCoordinateRegionMake(osaka, span); displayMap.setRegion(region, animated:true)
            self.latitudeLabel.text = "緯度：\(osaka.latitude)"
            self.longitudeLabel.text = "経度：\(osaka.longitude)"
            state = 1
        
        case 1:
            pin.coordinate = nagoya;
            pin.title="HAL名古屋";
            pin.subtitle="https://www.hal.ac.jp/nagoya"
            displayMap.addAnnotation(pin)
            
            let span = MKCoordinateSpanMake(0.005, 0.005) //1度...111km
            let region = MKCoordinateRegionMake(nagoya, span); displayMap.setRegion(region, animated:true)
            self.latitudeLabel.text = "緯度：\(nagoya.latitude)"
            self.longitudeLabel.text = "経度：\(nagoya.longitude)"
            state = 2
            
        case 2:
            pin.coordinate = tokyo;
            pin.title="HAL東京";
            pin.subtitle="https://www.hal.ac.jp/tokyo"
            displayMap.addAnnotation(pin)
            
            let span = MKCoordinateSpanMake(0.005, 0.005) //1度...111km
            let region = MKCoordinateRegionMake(tokyo, span); displayMap.setRegion(region, animated:true)
            self.latitudeLabel.text = "緯度：\(tokyo.latitude)"
            self.longitudeLabel.text = "経度：\(tokyo.longitude)"
            state = 3
            
        case 3:
            pin.coordinate = apple;
            pin.title="Apple本社";
            pin.subtitle="https://www.apple.com/jp"
            displayMap.addAnnotation(pin)
            
            let span = MKCoordinateSpanMake(0.005, 0.005) //1度...111km
            let region = MKCoordinateRegionMake(apple, span); displayMap.setRegion(region, animated:true)
            self.latitudeLabel.text = "緯度：\(apple.latitude)"
            self.longitudeLabel.text = "経度：\(apple.longitude)"
            state = 3
         default:
            break
        }
    }
    
    @IBAction func changeMapButton(_ sender: Any) {
        switch displayMap.mapType {
        case .standard:
            displayMap.mapType = .satellite
        case .satellite:
            displayMap.mapType = .hybrid
        case .hybrid:
            displayMap.mapType = .satelliteFlyover
        case .satelliteFlyover:
            displayMap.mapType = .hybridFlyover
        case .hybridFlyover:
            displayMap.mapType = .standard
        default:
            break
        }
    }
    
}

