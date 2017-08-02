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

public class MapView: GLKView {
    var map: Map?
    var drawState: ngsDrawState = DS_PRESERVED
    weak var globalTimer: Timer?
    var timerDrawState: ngsDrawState = DS_PRESERVED
    
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
    
    func draw(_ state: ngsDrawState) {
        drawState = state
        display()
    }
    
    public func cancelDraw() -> Bool {
        return false
    }
    
    public func refresh() {
        if !freeze {
            draw(DS_REDRAW)
        }
    }
    
    public func zoomIn(multiply: Double = 2.0) {
        map?.zoomIn(multiply)
        draw(DS_PRESERVED)
        scheduleDraw(drawState: DS_NORMAL)
    }
    
    public func zoomOut(multiply: Double = 2.0) {
        map?.zoomOut(multiply)
        draw(DS_PRESERVED)
        scheduleDraw(drawState: DS_NORMAL)
    }
    
    public func pan(w: Double, h: Double) {
        map?.pan(w, h)
        draw(DS_PRESERVED)
        scheduleDraw(drawState: DS_NORMAL)
    }
    
    func onTimer(timer: Timer) {
        globalTimer = nil
        let drawState = timer.userInfo as! ngsDrawState
        draw(drawState)
    }
    
    func scheduleDraw(drawState: ngsDrawState) {
        // timer?.invalidate()
        if timerDrawState != drawState {
            globalTimer?.invalidate()
            globalTimer = nil
        }
        
        if globalTimer != nil {
            return
        }
        
        timerDrawState = drawState
        
        globalTimer = Timer.scheduledTimer(timeInterval: Constants.refreshTime,
                                     target: self,
                                     selector: #selector(onTimer(timer:)),
                                     userInfo: drawState,
                                     repeats: false)
    }
    
}

func drawingProgressFunc(code: ngsCode, percent: Double, message: UnsafePointer<Int8>?, progressArguments: UnsafeMutableRawPointer?) -> Int32 {
    if(code == COD_FINISHED) {
        return 1
    }
    
    if (progressArguments != nil) {
        let view: MapView = bridge(ptr: progressArguments!)
        view.scheduleDraw(drawState: DS_PRESERVED) //display()
        return view.cancelDraw() ? 0 : 1
    }
    
    return 1
}


extension MapView: GLKViewDelegate {
    public func glkView(_ view: GLKView, drawIn rect: CGRect) {
        
        let processFunc: ngstore.ngsProgressFunc = drawingProgressFunc
        map?.draw(state: drawState, processFunc, bridge(obj: self))

        drawState = DS_PRESERVED
    }
}
