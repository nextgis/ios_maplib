//
//  Geometry.swift
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

/// Coordinate transformation class. Helps to transform from one spatial reference to another.
public class CoordinateTransformation {
    let handle: CoordinateTransformationH!
    
    init(handle: CoordinateTransformationH) {
        self.handle = handle
    }
    
    deinit {
        ngsCoordinateTransformationFree(handle)
    }
    
    /// Create new coordinate transformation.
    ///
    /// - Parameters:
    ///   - fromEPSG: Source EPSG spatial reference code.
    ///   - toEPSG: Destination EPSG spatial reference code.
    /// - Returns: CoordinateTransformation class instance.
    public static func new(fromEPSG: Int32, toEPSG: Int32) -> CoordinateTransformation {
        return CoordinateTransformation(
            handle: ngsCoordinateTransformationCreate(fromEPSG, toEPSG))
    }
    
    /// Perform transformation of point from one spatial reference to another.
    ///
    /// - Parameter point: Point to transform.
    /// - Returns: Point with new coordinates.
    public func transform(_ point: Point) -> Point {
        let coordIn: ngsCoordinate = ngsCoordinate(X: point.x, Y: point.y, Z: 0.0)
        let coordOut = ngsCoordinateTransformationDo(handle, coordIn)
        return Point(x: coordOut.X, y: coordOut.Y)
    }
}

/// Spatial envelope.
public struct Envelope : Equatable {
    
    /// Minimum X coordinate.
    public var minX: Double
    
    /// Maximum X coordinate.
    public var maxX: Double
    
    /// Minimum Y coordinate.
    public var minY: Double
    
    /// Maximum Y coordinate.
    public var maxY: Double
    
    var extent: ngsExtent {
        get {
            return ngsExtent(minX: minX, minY: minY, maxX: maxX, maxY: maxY)
        }
    }
    
    /// Init envelope with values.
    ///
    /// - Parameters:
    ///   - minX: Minimum X coordinate.
    ///   - minY: Minimum Y coordinate.
    ///   - maxX: Maximum X coordinate.
    ///   - maxY: Maximum Y coordinate.
    public init(minX: Double, minY: Double, maxX: Double, maxY: Double) {
        self.minX = minX
        self.maxX = maxX
        self.minY = minY
        self.maxY = maxY
    }
    
    /// Init envelope with zeroo coordinates. Envelope will be invalid.
    public init() {
        self.minX = 0.0
        self.maxX = 0.0
        self.minY = 0.0
        self.maxY = 0.0
    }
    
    init(envelope: ngsExtent) {
        self.minX = envelope.minX
        self.maxX = envelope.maxX
        self.minY = envelope.minY
        self.maxY = envelope.maxY
    }
    
    /// Check if envelope is init.
    ///
    /// - Returns: True if envelope is init.
    public func isInit() -> Bool {
        return minX != 0.0 && minY != 0.0 && maxX != 0.0 && maxY != 0.0
    }
    
    /// Merge envelope with other envelope. The result of extent of this and other envelop will be set to this envelope.
    ///
    /// - Parameter other: Other envelope.
    public mutating func merge(other: Envelope) {
        if isInit() {
            self.minX = min(minX, other.minX)
            self.minY = min(minY, other.minY)
            self.maxX = max(maxX, other.maxX)
            self.maxY = max(maxY, other.maxY)
        }
        else {
            self.minX = other.minX
            self.minY = other.minY
            self.maxX = other.maxX
            self.maxY = other.maxY
        }
    }
    
    /// Compare if envelopes are same.
    ///
    /// - Parameters:
    ///   - lhs: Envelope to compare.
    ///   - rhs: Envelope to compare.
    /// - Returns: True if same.
    public static func ==(lhs: Envelope, rhs: Envelope) -> Bool {
        return lhs.maxX == rhs.maxX && lhs.maxY == rhs.maxY &&
            lhs.minX == rhs.minX && lhs.minY == rhs.minY
    }
    
    /// Envelope width.
    public var width: Double {
        get {
            return maxX - minX
        }
    }
    
    /// Envelope height.
    public var height: Double {
        get {
            return maxY - minY
        }
    }
    
    /// Envelope center.
    public var center: Point {
        get {
            let x = minX + width / 2
            let y = minY + height / 2
            return Point(x: x, y: y)
        }
    }
    
    /// Increase envelope by value.
    ///
    /// - Parameter value: Value to increase width and height of envelope. May be negative for decrease sizes.
    public mutating func increase(by value: Double) {
        let deltaWidth = (width * value - width) / 2.0
        let deltaHeight = (height * value - height) / 2.0
        minX -= deltaWidth
        minY -= deltaHeight
        maxX += deltaWidth
        maxY += deltaHeight
    }
    
    /// Transform envelope from one spatial reference to another.
    ///
    /// - Parameters:
    ///   - fromEPSG: Source spatial reference EPSG code.
    ///   - toEPSG: Destination spatial reference EPSD code.
    public mutating func transform(fromEPSG: Int32, toEPSG: Int32) {
        let newTransform = CoordinateTransformation.new(fromEPSG: fromEPSG, toEPSG: toEPSG)
        var points: [Point] = []
        points.append(Point(x: minX, y: minY))
        points.append(Point(x: minX, y: maxY))
        points.append(Point(x: maxX, y: maxY))
        points.append(Point(x: maxX, y: minY))
        
        for index in 0..<4 {
            points[index] = newTransform.transform(points[index])
        }
        
        minX = Constants.bigValue
        minY = Constants.bigValue
        maxX = -Constants.bigValue
        maxY = -Constants.bigValue
        for index in 0..<4 {
            if minX > points[index].x {
                minX = points[index].x
            }
            if minY > points[index].y {
                minY = points[index].y
            }
            if maxX < points[index].x {
                maxX = points[index].x
            }
            if maxY < points[index].y {
                maxY = points[index].y
            }
        }
    }
    
    /// Create strong copy of envelope.
    ///
    /// - Returns: New envelope clas instance.
    public func clone() -> Envelope {
        return Envelope(minX: minX, minY: minY, maxX: maxX, maxY: maxY)
    }
}

/// Geometry class.
public class Geometry {
    let handle: GeometryH!
    
    /// Geometry type.
    ///
    /// - NONE: No geometry.
    /// - POINT: Point.
    /// - LINESTRING: Linestring.
    /// - POLYGON: Polygon.
    /// - MULTIPOINT: Multipoint.
    /// - MULTILINESTRING: Multilinestring.
    /// - MULTIPOLYGON: Multipolygon.
    public enum GeometryType: Int32 {
        case NONE = 0, POINT, LINESTRING, POLYGON, MULTIPOINT, MULTILINESTRING, MULTIPOLYGON
    }
    
    /// Get name from geometry type.
    ///
    /// - Parameter geometryType: Geometry type.
    /// - Returns: Geometry type name string.
    static func geometryTypeToName(_ geometryType: GeometryType) -> String {
        switch geometryType {
        case .NONE:
            return "NONE"
        case .POINT:
            return "POINT"
        case .LINESTRING:
            return "LINESTRING"
        case .POLYGON:
            return "POLYGON"
        case .MULTIPOINT:
            return "MULTIPOINT"
        case .MULTILINESTRING:
            return "MULTILINESTRING"
        case .MULTIPOLYGON:
            return "MULTIPOLYGON"
        }
    }
    
    /// Envelope of geometry.
    public var envelope: Envelope {
        get {
            return Envelope(envelope: ngsGeometryGetEnvelope(handle))
        }
    }
    
    /// Is empty geometry.
    public var isEmpty: Bool {
        get {
            return ngsGeometryIsEmpty(handle) == 1
        }
    }
    
    /// Geometry type.
    public var type: GeometryType {
        get {
            return Geometry.GeometryType(rawValue:
                Int32(ngsGeometryGetType(handle))) ?? .NONE
        }
    }
    
    init(handle: GeometryH) {
        self.handle = handle
    }
    
    deinit {
        ngsGeometryFree(handle)
    }
    
    /// Transform geometry from one spatial reference to another.
    ///
    /// - Parameter epsg: Destination spatial reference.
    /// - Returns: True on success.
    public func transform(to epsg: Int32) -> Bool {
        return ngsGeometryTransformTo(handle, epsg) == Int32(COD_SUCCESS.rawValue)
    }
    
    /// Transform geometry from one spatial reference to another.
    ///
    /// - Parameter transformation: CoordinateTransformation class instance.
    /// - Returns: True on success.
    public func transform(_ transformation: CoordinateTransformation) -> Bool {
        return ngsGeometryTransform(handle, transformation.handle) ==
            Int32(COD_SUCCESS.rawValue)
    }
    
    /// Transform geometry to GeoJson string.
    ///
    /// - Returns: GeoJson string.
    public func asJson() -> String {
        return String(cString: ngsGeometryToJson(handle))
    }
}


/// Geometry point class.
public class GeoPoint : Geometry {
    
    /// Set the point location
    ///
    /// - Parameters:
    ///   - x: input X coordinate
    ///   - y: input Y coordinate
    ///   - z: input Z coordinate
    ///   - m: input M coordinate
    public func setCoordinates(x: Double, y: Double, z: Double = 0, m: Double = 0) {
        ngsGeometrySetPoint(handle, 0, x, y, z, m)
    }
    
    /// Set the point location
    ///
    /// - Parameters:
    ///   - point: input raw point struct
    ///   - z: input Z coordinate
    ///   - m: input M coordinate
    public func setCoordinates(point: Point, z: Double = 0, m: Double = 0) {
        ngsGeometrySetPoint(handle, 0, point.x, point.y, z, m)
    }
}
