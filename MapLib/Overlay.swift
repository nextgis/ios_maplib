//
//  Overlay.swift
//  Project: NextGIS Mobile SDK
//  Author:  Dmitry Baryshnikov, dmitry.baryshnikov@nextgis.com
//
//  Created by Dmitry Baryshnikov on 25.11.2017.
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

import Foundation
import ngstore

/// Map overlay to draw different features (for example, current position, edit features, etc.)
public class Overlay {
    
    weak var map: Map!
    let type: Map.OverlayType
    
    fileprivate init(map: Map, type: Map.OverlayType) {
        self.map = map
        self.type = type
    }
    
    /// Overlay visible read/write property.
    public var visible: Bool {
        get {
            return ngsOverlayGetVisible(map.id, ngsMapOverlayType(type.rawValue)) == 1
        }
        
        set {
            ngsOverlaySetVisible(map.id, Int32(type.rawValue), newValue ? 1 : 0)
        }
    }
    
    /// Overlay options key-value dictionary. The keys depend on overlay type.
    public var options: [String:String] {
        get {
            if let rawOptions = ngsOverlayGetOptions(map.id, ngsMapOverlayType(type.rawValue)) {
                var count = 0
                var out: [String: String] = [:]
                while(rawOptions[count] != nil) {
                    let optionItem = String(cString: rawOptions[count]!)
                    if let splitIndex = optionItem.range(of: "=") {
                        let key = optionItem.substring(to: splitIndex.lowerBound)
                        let value = optionItem.substring(from: optionItem.index(splitIndex.lowerBound, offsetBy: 1))
                        out[key] = value
                    }
                    count += 1
                }
                return out
            }
            return [:]
        }
        set {
            _ = ngsOverlaySetOptions(map.id, ngsMapOverlayType(type.rawValue),
                                     toArrayOfCStrings(newValue))
        }
    }
}


/// Overlay showing current position
public class LocationOverlay : Overlay {
    
    init(map: Map) {
        super.init(map: map, type: .LOCATION)
    }
    
    /// Overlay style json object
    public var style: JsonObject {
        get {
            return JsonObject(handle: ngsLocationOverlayGetStyle(map.id))
        }
        
        set {
            ngsLocationOverlaySetStyle(map.id, newValue.handle)
        }
    }
    
    /// Set ovelay style name.
    ///
    /// - Parameter name: Overlay style name. The supported names depnds of overlay type.
    /// - Returns: True on success.
    public func setStyle(name: String) -> Bool {
        return ngsLocationOverlaySetStyleName(map.id, name) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    func location(update location: Point, direction: Float, accuracy: Float) {
        let loc = ngsCoordinate(X: location.x, Y: location.y, Z: 0.0)
        ngsLocationOverlayUpdate(map.id, loc, direction, accuracy)
    }
}

/// Overlay showing edit features
public class EditOverlay : Overlay {
    
    /// Edit layer read/write property.
    public var editLayer: Layer? = nil
    
    /// Edit operation result type.
    ///
    /// - NON_LAST: deleted point/part was not last in geometry.
    /// - LINE: delete line.
    /// - HOLE: the hole in polygon was deleted.
    /// - GEOMETRY_PART: part of the geometry was deleted.
    /// - GEOMETRY: the whole geometry was deleted.
    public enum DeleteResultType: UInt32 {
        case NON_LAST
        case LINE
        case HOLE
        case GEOMETRY_PART
        case GEOMETRY
        
        public var rawValue: UInt32 {
            switch self {
            case .NON_LAST:
                return EDT_NON_LAST.rawValue
            case .LINE:
                return EDT_LINE.rawValue
            case .HOLE:
                return EDT_HOLE.rawValue
            case .GEOMETRY_PART:
                return EDT_GEOMETRY_PART.rawValue
            case .GEOMETRY:
                return EDT_GEOMETRY.rawValue
            }
        }
    }
    
    init(map: Map) {
        super.init(map: map, type: .EDIT)
    }
    
    /// Point json object style.
    public var pointStyle: JsonObject {
        get {
            return JsonObject(handle: ngsEditOverlayGetStyle(map.id, EST_POINT))
        }
        
        set {
            ngsEditOverlaySetStyle(map.id, EST_POINT, newValue.handle)
        }
    }
    
    /// Line json object style.
    public var lineStyle: JsonObject {
        get {
            return JsonObject(handle: ngsEditOverlayGetStyle(map.id, EST_LINE))
        }
        
        set {
            ngsEditOverlaySetStyle(map.id, EST_LINE, newValue.handle)
        }
    }
    
    /// Polygon json object style.
    public var fillStyle: JsonObject {
        get {
            return JsonObject(handle: ngsEditOverlayGetStyle(map.id, EST_FILL))
        }
        
        set {
            ngsEditOverlaySetStyle(map.id, EST_FILL, newValue.handle)
        }
    }
    
    /// The cross in screen center style read/write property.
    public var crossStyle: JsonObject {
        get {
            return JsonObject(handle: ngsEditOverlayGetStyle(map.id, EST_CROSS))
        }
        
        set {
            ngsEditOverlaySetStyle(map.id, EST_CROSS, newValue.handle)
        }
    }
    
    /// Edit geometry property.
    public var geometry: Geometry? {
        get {
            if let handle = ngsEditOverlayGetGeometry(map.id) {
                return Geometry(handle: handle)
            }
            return nil
        }
    }
    
    /// Edit geometry type property.
    public var geometryType: Geometry.GeometryType {
        get {
            if editLayer != nil {
                if let ds = editLayer?.dataSource as? FeatureClass {
                    return ds.geometryType
                }
            }
            return .NONE
        }
    }
    
    /// Enable/disable edit by walk mode.
    public var walkingMode: Bool {
        get {
            return ngsEditOverlayGetWalkingMode(map.id) == 1
        }
        
        set {
            ngsEditOverlaySetWalkingMode(map.id, newValue ? 1 : 0)
        }
    }
    
    /// Set edit overlay point feature style.
    ///
    /// - Parameter name: Style name.
    /// - Returns: True on success.
    public func setStyle(point name: String) -> Bool {
        return ngsEditOverlaySetStyleName(map.id, EST_POINT, name) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    /// Set edit overlay line feature style.
    ///
    /// - Parameter name: Style name.
    /// - Returns: True on success.
    public func setStyle(line name: String) -> Bool {
        return ngsEditOverlaySetStyleName(map.id, EST_LINE, name) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    /// Set edit overlay polygon feature style.
    ///
    /// - Parameter name: Style name.
    /// - Returns: True on success.
    public func setStyle(fill name: String) -> Bool {
        return ngsEditOverlaySetStyleName(map.id, EST_FILL, name) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    /// Set edit overlay cross style.
    ///
    /// - Parameter name: Style name.
    /// - Returns: True on success.
    public func setStyle(cross name: String) -> Bool {
        return ngsEditOverlaySetStyleName(map.id, EST_CROSS, name) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    /// Can undo edit operation.
    ///
    /// - Returns: True or false.
    public func canUndo() -> Bool {
        return ngsEditOverlayCanUndo(map.id) == 1
    }
    
    /// Can redo edit operation.
    ///
    /// - Returns: True or false.
    public func canRedo() -> Bool {
        return ngsEditOverlayCanRedo(map.id) == 1
    }
    
    /// Undo edit operation.
    ///
    /// - Returns: True on success.
    public func undo() -> Bool {
        return ngsEditOverlayUndo(map.id) == 1
    }
    
    /// Redo edit operation.
    ///
    /// - Returns: True on success.
    public func redo() -> Bool {
        return ngsEditOverlayRedo(map.id) == 1
    }
    
    /// Save edits and return result feature instance.
    ///
    /// - Returns: Feature class instance or nil.
    public func save() -> Feature? {
        if let feature = ngsEditOverlaySave(map.id) {
            return Feature(handle: feature,
                           table: editLayer?.dataSource as? FeatureClass)
        }
        return nil
    }
    
    /// Cancel any edits.
    ///
    /// - Returns: True on success.
    public func cancel() -> Bool {
        return ngsEditOverlayCancel(map.id) == Int32(COD_SUCCESS.rawValue)
    }
    
    /// Create new geometry and start editing. If the layer datasource is point - te pont at the center of screen will be created, if line - line with two points, if polygon - polygon with three points.
    ///
    /// - Parameter layer: Layer in which to create new geometry. The feature will be created in layer datasource.
    /// - Returns: True on success.
    public func createNewGeometry(in layer: Layer) -> Bool {
        editLayer = layer
        return ngsEditOverlayCreateGeometryInLayer(map.id, layer.layerH, 0) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    /// Create new geometry and start editing. The geometry will be empty. This is for edit by walk editing.
    ///
    /// - Parameter layer: Layer in which to create new geometry. The feature will be created in layer datasource.
    /// - Returns: True on success.
    public func createNewEmptyGeometry(in layer: Layer) -> Bool {
        editLayer = layer
        return ngsEditOverlayCreateGeometryInLayer(map.id, layer.layerH, 1) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    /// Create new geometry and start editing.
    ///
    /// - Parameter type: Geometry type.
    /// - Returns: True on success.
    public func createNewGeometry(of type: Geometry.GeometryType) -> Bool {
        editLayer = nil
        return ngsEditOverlayCreateGeometry(map.id, ngsGeometryType(type.rawValue)) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    /// Start editing geometry from feature.
    ///
    /// - Parameter feature: Feature to edit geometry.
    /// - Returns: True on success.
    public func editGeometry(of feature: Feature) -> Bool {
        if let layer = map.getLayer(for: feature) {
            editLayer = layer
            return ngsEditOverlayEditGeometry(map.id, layer.layerH, feature.id) ==
                Int32(COD_SUCCESS.rawValue)
        }
        return false
    }
    
    /// Delete geometry in editing feature.
    ///
    /// - Returns: True on success.
    public func deleteGeometry() -> Bool {
        return ngsEditOverlayDeleteGeometry(map.id) == Int32(COD_SUCCESS.rawValue)
    }
    
    /// Add geomtry part.
    ///
    /// - Returns: True on success.
    public func addGeometryPart() -> Bool {
        return ngsEditOverlayAddGeometryPart(map.id) == Int32(COD_SUCCESS.rawValue)
    }
    
    /// Add point to geometry. Make sense only for line or polygon ring.
    ///
    /// - Returns: True on success.
    public func addGeometryPoint() -> Bool {
        return ngsEditOverlayAddPoint(map.id) == Int32(COD_SUCCESS.rawValue)
    }
    
    /// Add point to geometry. Make sense only for line or polygon ring.
    ///
    /// - Parameter coordinates: Point coordinates.
    /// - Returns: True on success.
    public func addGeometryPoint(with coordinates: Point) -> Bool {
        return ngsEditOverlayAddVertex(map.id, ngsCoordinate(X: coordinates.x,
                                                             Y: coordinates.y,
                                                             Z: 0.0)) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    /// Delete point from geometry.
    ///
    /// - Returns: True on success.
    public func deleteGeometryPoint() -> DeleteResultType {
        return EditOverlay.DeleteResultType(
            rawValue: UInt32(ngsEditOverlayDeletePoint(map.id).rawValue)) ??
            .NON_LAST
    }
    
    /// Delete geometry part
    ///
    /// - Returns: The value of type enum DeleteResultType
    public func deleteGeometryPart() -> DeleteResultType {
        return EditOverlay.DeleteResultType(
            rawValue: UInt32(ngsEditOverlayDeleteGeometryPart(map.id).rawValue)) ??
            .NON_LAST
    }
    
    /// Add hole topolygon geometry.
    ///
    /// - Returns: True on success.
    public func addGeometryHole() -> Bool {
        return ngsEditOverlayAddHole(map.id) == Int32(COD_SUCCESS.rawValue)
    }
    
    /// Delete geometry hole.
    ///
    /// - Returns: delete result type indicating is this last hole or any already exists.
    public func deleteGeometryHole() -> DeleteResultType {
        return EditOverlay.DeleteResultType(
            rawValue: UInt32(ngsEditOverlayDeleteHole(map.id).rawValue)) ??
            .NON_LAST
    }
    
    /// Touch down event in edit overlay.
    ///
    /// - Parameters:
    ///   - x: x screen coordinate.
    ///   - y: y screen coordinate.
    /// - Returns: Tuple with selected point identificator and is this point belongs to hole.
    public func touch(down x: Double, y: Double) -> (pointId: Int32, isHole: Bool) {
        let touchPointStruct = ngsEditOverlayTouch(map.id, x, y, MTT_ON_DOWN)
        let pointId = touchPointStruct.pointId
        let isHole: Bool = touchPointStruct.isHole == 1
        return (pointId: pointId, isHole: isHole)
    }
    
    /// Touch up event in edit overlay.
    ///
    /// - Parameters:
    ///   - x: x screen coordinate.
    ///   - y: y screen coordinate.
    /// - Returns: Tuple with selected point identificator and is this point belongs to hole.
    public func touch(up x: Double, y: Double) -> (pointId: Int32, isHole: Bool) {
        let touchPointStruct = ngsEditOverlayTouch(map.id, x, y, MTT_ON_UP)
        let pointId = touchPointStruct.pointId
        let isHole: Bool = touchPointStruct.isHole == 1
        return (pointId: pointId, isHole: isHole)
    }
    
    /// Touch move event in edit overlay.
    ///
    /// - Parameters:
    ///   - x: x screen coordinate.
    ///   - y: y screen coordinate.
    /// - Returns: Tuple with selected point identificator and is this point belongs to hole.
    public func touch(move x: Double, y: Double) -> (pointId: Int32, isHole: Bool) {
        let touchPointStruct = ngsEditOverlayTouch(map.id, x, y, MTT_ON_MOVE)
        let pointId = touchPointStruct.pointId
        let isHole: Bool = touchPointStruct.isHole == 1
        return (pointId: pointId, isHole: isHole)
    }
    
    /// Touch single event in edit overlay. Fotr example down and up.
    ///
    /// - Parameters:
    ///   - x: x screen coordinate.
    ///   - y: y screen coordinate.
    /// - Returns: Tuple with selected point identificator and is this point belongs to hole.
    public func touch(single x: Double, y: Double) -> (pointId: Int32, isHole: Bool) {
        let touchPointStruct = ngsEditOverlayTouch(map.id, x, y, MTT_SINGLE)
        let pointId = touchPointStruct.pointId
        let isHole: Bool = touchPointStruct.isHole == 1
        return (pointId: pointId, isHole: isHole)
    }
}
