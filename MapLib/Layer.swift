//
//  Layer.swift
//  Project: NextGIS Mobile SDK
//  Author:  Dmitry Baryshnikov, dmitry.baryshnikov@nextgis.com
//
//  Created by Dmitry Baryshnikov on 13.06.17.
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
//

import Foundation
import ngstore

public class Layer {
    let layerH: LayerH!
    
    public var name: String {
        get {
            return String(cString: ngsLayerGetName(layerH))
        }
        
        set(newName) {
            ngsLayerSetName(layerH, newName)
        }
    }
    
    public var visible: Bool {
        get {
            return ngsLayerGetVisible(layerH) == 1 ? true : false
        }
        
        set(newVisibility) {
            ngsLayerSetVisible(layerH, newVisibility == true ? 1 : 0)
        }
    }
    
    init(layerH: LayerH!) {
        self.layerH = layerH
    }
    
    func getHandler() -> LayerH {
        return layerH
    }
    
}
