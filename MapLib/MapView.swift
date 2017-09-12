//
//  MapView.swift
//  Project: NextGIS Mobile SDK
//  Author:  Dmitry Baryshnikov, dmitry.baryshnikov@nextgis.com
//
//  Created by Dmitry Baryshnikov on 26.06.17.
//  Copyright © 2017 NextGIS, info@nextgis.com
//
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU Lesser Public License for more details.
//
//  You should have received a copy of the GNU Lesser Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

import UIKit
import GLKit
import ngstore
import CoreLocation

public protocol GestureDelegate: class {
    func onSingleTap(sender: UIGestureRecognizer)
    func onDoubleTap(sender: UIGestureRecognizer)
    func onPanGesture(sender: UIPanGestureRecognizer)
    func onPinchGesture(sender: UIPinchGestureRecognizer)
}

public protocol LocationDelegate: class {
    func onLocationChanged(location: CLLocation)
}

public class MapView: GLKView {
    var map: Map? = nil
    var drawState: Map.DrawState = .PRESERVED
    weak var globalTimer: Timer? = nil
    var timerDrawState: Map.DrawState = .PRESERVED
    weak var gestureDelegate: GestureDelegate? = nil
    weak var locationDelegate: LocationDelegate? = nil
    let locationManager = CLLocationManager()
    public var currentLocation: CLLocation? = nil
        
    var showLocationVal: Bool = false
    public var showLocation: Bool {
        get {
            return showLocationVal
        }
        set {
            showLocationVal = newValue
            if showLocationVal {
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.delegate = self
                locationManager.requestWhenInUseAuthorization()
                locationManager.pausesLocationUpdatesAutomatically = true
                locationManager.startUpdatingLocation()
            }
            else {
                locationManager.stopUpdatingLocation()
            }
        }
    }
    
    public var freeze: Bool {
        get {
            return self.freeze
        }
        
        set(newValue) {
            self.freeze = newValue
        }
    }
    
    public var mapScale: Double {
        get {
            return map?.scale ?? 0.0000015
        }
        
        set(newScale) {
            map?.scale = newScale
        }
    }
    
    public var mapCenter: Point {
        get {
            return map?.center ?? Point()
        }
        
        set(newPoint) {
            map?.center = newPoint
        }
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame, context: EAGLContext(api: .openGLES2))
        delegate = self
        freeze = true
        
    }
    
    override init(frame: CGRect, context: EAGLContext)
    {
        super.init(frame: frame, context: context)
        delegate = self
        freeze = true
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        context = EAGLContext(api: .openGLES2)
        delegate = self
        freeze = true
    }
    
    deinit {
        
    }
    
    public func setMap(map: Map) {
        self.map = map
        map.setSize(width: bounds.width, height: bounds.height)
        
        printMessage("Map set size w: \(bounds.width) h:\(bounds.height)")
        
        refresh()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        map?.setSize(width: bounds.width, height: bounds.height)
        
        printMessage("Map set size w: \(bounds.width) h:\(bounds.height)")
        
        refresh()
    }
    
    func draw(_ state: Map.DrawState) {
        drawState = state
        display()
    }
    
    public func cancelDraw() -> Bool {
        return false
    }
    
    public func refresh(normal: Bool = true) {
        if !freeze {
            if normal {
                draw(.NORMAL)
            } else {
                draw(.REFILL)
            }
        }
    }
    
    public func zoomIn(multiply: Double = 2.0) {
        map?.zoomIn(multiply)
        draw(.PRESERVED)
        scheduleDraw(drawState: .NORMAL)
    }
    
    public func zoomOut(multiply: Double = 2.0) {
        map?.zoomOut(multiply)
        draw(.PRESERVED)
        scheduleDraw(drawState: .NORMAL)
    }
    
    public func centerMap(coordinate: Point) {
        map?.center = coordinate
        draw(.PRESERVED)
        scheduleDraw(drawState: .NORMAL)
    }
    
    public func centerInCurrentLocation() {
        if currentLocation == nil {
            return
        }
        let newCenter = transformFrom(gps: currentLocation?.coordinate.longitude ?? 0.0,
                                       y: currentLocation?.coordinate.latitude ?? 0.0)
        centerMap(coordinate: newCenter)
    }
    
    public func invalidate(envelope: Envelope) {
        map?.invalidate(extent: envelope)
        scheduleDraw(drawState: .PRESERVED, timeInterval: 0.70)
    }
    
    public func pan(w: Double, h: Double) {
        map?.pan(w, h)
        draw(.PRESERVED)
        scheduleDraw(drawState: .NORMAL)
    }
    
    func transformFrom(gps x: Double, y: Double) -> Point {
        let ct = CoordinateTransformation.new(fromEPSG: 4326, toEPSG: 3857)
        return ct.transform(Point(x: x, y: y))
    }
    
    func onTimer(timer: Timer) {
        globalTimer = nil
        let drawState = timer.userInfo as! Map.DrawState
        draw(drawState)
    }
    
    public func scheduleDraw(drawState: Map.DrawState, timeInterval: TimeInterval = Constants.refreshTime) {
        // timer?.invalidate()
        if timerDrawState != drawState {
            globalTimer?.invalidate()
            globalTimer = nil
        }
        
        if globalTimer != nil {
            return
        }
        
        timerDrawState = drawState
        
        globalTimer = Timer.scheduledTimer(timeInterval: timeInterval,
                                     target: self,
                                     selector: #selector(onTimer(timer:)),
                                     userInfo: drawState,
                                     repeats: false)
    }
    
    public func registerGestureRecognizers(_ delegate: GestureDelegate) {
        isUserInteractionEnabled = true
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(onSingleTap(sender:)))
        singleTap.numberOfTapsRequired = 1
        addGestureRecognizer(singleTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(onDoubleTap(sender:)))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        
        singleTap.require(toFail: doubleTap)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPanGesture(sender:)))
        addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(onPinchGesture(sender:)))
        addGestureRecognizer(pinchGesture)
        
        gestureDelegate = delegate
    }
    
    public func registerLocation(_ delegate: LocationDelegate) {
        locationDelegate = delegate
    }
    
    func onDoubleTap(sender: UIGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.ended {
            
            let position = sender.location(in: sender.view)
            let x = Double(position.x)
            let y = Double(position.y)
            
            map?.setCenterAndZoom(x, y)
            draw(.PRESERVED)
            scheduleDraw(drawState: .NORMAL)
            
            gestureDelegate?.onDoubleTap(sender: sender)
        }
    }
    
    func onSingleTap(sender: UIGestureRecognizer) {
        // Iterate through visible map layers and return found features
        if sender.state == UIGestureRecognizerState.ended {
            gestureDelegate?.onSingleTap(sender: sender)
        }
    }
    
    func onPanGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self)
        
        let x = Double(translation.x)
        let y = Double(translation.y)
        
        if(abs(x) > Constants.Sizes.minPanPix || abs(y) > Constants.Sizes.minPanPix) {
            pan(w: x, h: y)
            sender.setTranslation(CGPoint(x: 0.0, y: 0.0), in: self)
        }
        
        gestureDelegate?.onPanGesture(sender: sender)
    }
    
    func onPinchGesture(sender: UIPinchGestureRecognizer) {
        let scale = sender.scale
        
        map?.zoomIn(Double(scale))
        draw(.PRESERVED)
        scheduleDraw(drawState: .NORMAL)
        
        sender.scale = 1.0
        
        gestureDelegate?.onPinchGesture(sender: sender)
    }
    
    public func getExtent(srs: Int32) -> Envelope {
        return map?.getExtent(srs: srs) ?? Envelope()
    }
}

func drawingProgressFunc(code: ngsCode, percent: Double,
                         message: UnsafePointer<Int8>?,
                         progressArguments: UnsafeMutableRawPointer?) -> Int32 {
    if(code == COD_FINISHED) {
        return 1
    }
    
    if (progressArguments != nil) {
        let view: MapView = bridge(ptr: progressArguments!)
        view.scheduleDraw(drawState: .PRESERVED) //display()
        return view.cancelDraw() ? 0 : 1
    }
    
    return 1
}


extension MapView: GLKViewDelegate {
    public func glkView(_ view: GLKView, drawIn rect: CGRect) {
        
        let processFunc: ngstore.ngsProgressFunc = drawingProgressFunc
        map?.draw(state: drawState, processFunc, bridge(obj: self))

        drawState = .PRESERVED
    }
}

extension MapView: CLLocationManagerDelegate {
    
    
    public func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation])
    {
        let location = locations[locations.count - 1]
        if location.coordinate.latitude == currentLocation?.coordinate.latitude &&
            location.coordinate.longitude == currentLocation?.coordinate.longitude &&
            location.altitude == currentLocation?.altitude &&
            location.course == currentLocation?.course &&
            location.horizontalAccuracy == currentLocation?.horizontalAccuracy {
            return // Nothing changed
        }
        
        currentLocation = location
        if currentLocation != nil {
        
            if showLocation {
                let position = transformFrom(gps: currentLocation!.coordinate.longitude,
                                             y: currentLocation!.coordinate.latitude)
                map?.location(update: position, direction: Float(currentLocation!.course),
                              accuracy: Float(currentLocation!.horizontalAccuracy))
                draw(.PRESERVED)
            }
        
            printMessage("Location. Lat: \(currentLocation!.coordinate.latitude) Long:\(currentLocation!.coordinate.longitude) Alt:\(currentLocation!.altitude) Dir:\(currentLocation!.course), Accuracy: \(currentLocation!.horizontalAccuracy)")
        
            locationDelegate?.onLocationChanged(location: currentLocation!)
        }
    }
}
