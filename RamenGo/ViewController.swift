//
//  ViewController.swift
//  RamenGo
//
//  Created by Yencheng on 2017/2/14.
//  Copyright © 2017年 GJTeam. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, RamenPlaceDetailDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var ramenPlaceInfoList: UIView!
    @IBOutlet weak var showRPILBtn: UIButton!
    
    @IBOutlet weak var ramenPlaceInfoTableView: UITableView!
    
    @IBOutlet weak var ramenPlaceDetailView: RamenPlaceDetailView! {
        didSet {
            ramenPlaceDetailView.delegate = self
        }
    }

    var locationManager : CLLocationManager!
    var pinLocation : CLLocationCoordinate2D?
    var currentLocation : CLLocationCoordinate2D?
    
    var selectLocation : CLLocationCoordinate2D?
    var selectAnnotation : MKAnnotationView?
    
    var centerMarker : CLLocationCoordinate2D?
    var isRamenPlaceInfoListShow = false
    var isRamenPlaceDetailViewShow = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "拉麵地圖"
        self.initLocationManager()
        self.initMapView()
        self.initData()
        self.initTableView()
        self.initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        if CLLocationManager.authorizationStatus() == .denied {
            let alertController = UIAlertController(
                title: "請開啟定位權限",
                message:"如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟",
                preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確認", style: .default, handler: nil)
            alertController.addAction(okAction)
            show(alertController, sender: self)
        }
    }
    
    private func initLocationManager() {
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLLocationAccuracyHundredMeters
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    private func initMapView() {
        self.mapView.delegate = self;
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    private func initTableView() {
        self.ramenPlaceInfoTableView.dataSource = self;
        self.ramenPlaceInfoTableView.delegate = self;
        self.ramenPlaceInfoTableView.separatorInset = UIEdgeInsets.zero;
    }

    private func initUI() {
        self.setInfoListFrame(show:false)
        self.setDetailViewFrame(show:false)
    }
    
    func initData() {
        
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self){
            
            let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(25.034),CLLocationDegrees(121.5365))
            let coordinate2 = CLLocationCoordinate2DMake(CLLocationDegrees(25.032),CLLocationDegrees(121.5368))
            
            let cafeAnnotation = MKPointAnnotation()
            cafeAnnotation.coordinate = coordinate
            cafeAnnotation.title = "夢幻拉麵店"
            
            let cafeAnnotation2 = MKPointAnnotation()
            cafeAnnotation2.coordinate = coordinate2
            cafeAnnotation2.title = "NAGI拉麵店"
            
            DispatchQueue.main.async {
                self.mapView.addAnnotations([cafeAnnotation,cafeAnnotation2])
            }
        }
        else {
            print("System can't track regions")
        }
    }
    
    // MARK:LocationManager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let LoactionCoordinate = locations.last!.coordinate
        self.currentLocation = CLLocationCoordinate2D(latitude: LoactionCoordinate.latitude, longitude: LoactionCoordinate.longitude)
        let _span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005);
        
        self.mapView.setRegion(MKCoordinateRegion(center: currentLocation!, span: _span), animated: true);
    }
    
    // MARK: MapView
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print("mapView is working")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var cafeAnnotation = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if cafeAnnotation == nil {
            cafeAnnotation = MKAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
        }
        
        cafeAnnotation?.annotation = annotation
        cafeAnnotation?.image = UIImage(named: "CafePin")
        
        
        return cafeAnnotation
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.selectLocation = view.annotation?.coordinate
        self.selectAnnotation = view
        //center the map between two location
        self.centerMarker = CLLocationCoordinate2D(latitude: ((self.currentLocation?.latitude)! + (self.selectLocation?.latitude)!)/2, longitude: ((self.currentLocation?.longitude)! + (self.selectLocation?.longitude)!)/2)
        let _span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005);
        self.mapView.setRegion(MKCoordinateRegion(center: centerMarker!, span: _span), animated: true);
        
        //hide other annotation
        
        //draw route between two location
        
        //show detail description
        self.ramenPlaceDetailView.ramenPlaceTitle.text = view.annotation?.title!
        self.showRamenPlaceDetailView()
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
        //center current location
        let _span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005);
        self.mapView.setRegion(MKCoordinateRegion(center: currentLocation!, span: _span), animated: true);
        
        //show all avalible annotation
        
        //hide detail decription
        self.hideRamenPlaceDetailView()
    }
    
    // MARK: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ramenPlaceInfoCell", for: indexPath) as! RamenPlaceInfoCell
        cell.ramenTitle.text = "拉麵店\(indexPath.row+1)號"
        cell.ramenDistance.text = "300公尺"

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61.25
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("select a store")
    }
    
    // MARK: RamenPlaceDetailView
    func dismissDetailViewButton() {
        self.hideRamenPlaceDetailView()
    }
    
    func tapSurveyButton() {
        print("go survey page")
    }
    
    // MARK: Button Action
    @IBAction func showRamenPlaceInfoList(_ sender: UIButton) {
        if (self.isRamenPlaceInfoListShow) {
            UIView.animate(withDuration: 0.3, delay: 0, options:[.curveLinear,.allowUserInteraction], animations: {self.setInfoListFrame(show:false)}, completion: nil)
            self.showRPILBtn.setTitle("開", for: .normal)
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, options:[.curveLinear,.allowUserInteraction], animations: {self.setInfoListFrame(show:true)}, completion: nil)
            self.showRPILBtn.setTitle("關", for: .normal)
        }
    }
    
    private func showRamenPlaceDetailView() {
        UIView.animate(withDuration: 0.3, delay: 0, options:[.curveLinear,.allowUserInteraction], animations: {self.setDetailViewFrame(show:true)} , completion: nil)
    }
    
    private func hideRamenPlaceDetailView() {
        UIView.animate(withDuration: 0.3, delay: 0, options:[.curveLinear,.allowUserInteraction], animations: {self.setDetailViewFrame(show:false)} , completion: nil)
        self.mapView.deselectAnnotation(self.selectAnnotation?.annotation, animated: true)
    }
    
    private func setInfoListFrame(show: Bool) {
        let x = self.ramenPlaceInfoList.frame.origin.x
        let y = self.view.frame.maxY
        let width = self.ramenPlaceInfoList.frame.size.width
        let height = self.ramenPlaceInfoList.frame.size.height
        if(show) {
            self.ramenPlaceInfoList.frame = CGRect(x:x, y:y-280, width:width, height:height)
            self.isRamenPlaceInfoListShow = true
        } else {
            self.ramenPlaceInfoList.frame = CGRect(x:x, y:y-35, width:width, height:height)
            self.isRamenPlaceInfoListShow = false
        }
    }
    
    private func setDetailViewFrame(show: Bool) {
        let x = self.ramenPlaceDetailView.frame.origin.x
        let y = self.view.frame.maxY
        let width = self.ramenPlaceDetailView.frame.size.width
        let height = self.ramenPlaceDetailView.frame.size.height
        if(show) {
            self.ramenPlaceDetailView.frame = CGRect(x:x, y:y-280, width:width, height:height)
            self.isRamenPlaceDetailViewShow = true
        } else {
            self.ramenPlaceDetailView.frame = CGRect(x:x, y:y, width:width, height:height)
            self.isRamenPlaceDetailViewShow = false
        }
    }
}

