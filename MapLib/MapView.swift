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
    
    override init(frame: CGRect)
    {
        super.init(frame: frame, context: EAGLContext(api: .openGLES2))
        delegate = self
    }
    
    override init(frame: CGRect, context: EAGLContext)
    {
        super.init(frame: frame, context: context)
        delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        context = EAGLContext(api: .openGLES2)
        delegate = self
    }
    
    public func setMap(map: Map) {
        self.map = map
        map.setSize(width: bounds.width, height: bounds.height)
        
        printMessage("Map set size w: \(bounds.width) h:\(bounds.height)")
        
        draw(DS_REDRAW)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        map?.setSize(width: bounds.width, height: bounds.height)
        
        printMessage("Map set size w: \(bounds.width) h:\(bounds.height)")
        
        draw(DS_REDRAW)
    }
    
    func draw(_ state: ngsDrawState) {
        drawState = state
        display()
    }
    
    public func cancelDraw() -> Bool {
        return false
    }
}

func drawingProgressFunc(code: ngsCode, percent: Double, message: UnsafePointer<Int8>?, progressArguments: UnsafeMutableRawPointer?) -> Int32 {
    if(code == COD_FINISHED) {
        return 1
    }
    
    if (progressArguments != nil) {
        let view: MapView = bridge(ptr: progressArguments!)
        view.display()
        return view.cancelDraw() ? 0 : 1
    }
    
    return 1
}


extension MapView: GLKViewDelegate {
    public func glkView(_ view: GLKView, drawIn rect: CGRect) {
        let processFunc: ngstore.ngsProgressFunc = drawingProgressFunc
        map?.draw(state: drawState, processFunc, bridge(obj: self))
        
        printMessage("Map draw!")

        drawState = DS_PRESERVED
    }
}
