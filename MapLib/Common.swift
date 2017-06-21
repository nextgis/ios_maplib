//
//  Common.swift
//  Project: NextGIS Mobile SDK
//  Author:  Dmitry Baryshnikov, dmitry.baryshnikov@nextgis.com
//
//  Created by Дмитрий Барышников on 13.06.17.
//  Copyright © 2017 NextGIS, info@nextgis.co
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

// https://stackoverflow.com/a/40189217/2901140
func toArrayOfCStrings(_ values: [String:String]!) -> UnsafeMutablePointer<UnsafeMutablePointer<Int8>?> {
    let buffer = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: values.count + 1)
    
    for (index, value) in values.enumerated() {
        let keyValue = value.key + "=" + value.value
        buffer[index] = UnsafeMutablePointer<Int8>(mutating: keyValue)
    }
    buffer[values.count] = nil
    return buffer
}
