//
//  ComboBoxControl.swift
//  Project: NextGIS Mobile SDK
//  Author:  Dmitry Baryshnikov, dmitry.baryshnikov@nextgis.com
//
//  Created by Dmitry Baryshnikov on 19.08.17.
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


/// Combobox control.
@IBDesignable open class ComboBoxControl: UIButton {
    
    /// List of combobox values.
    public var selection: [String] = []
    var currentValue: String = ""
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupControls()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupControls()
    }
    
    override open var bounds: CGRect {
        didSet {
            // Do stuff here
            let pos: CGFloat = bounds.width
            let imageSize: CGFloat = 28.0
            imageEdgeInsets = UIEdgeInsetsMake(0.0, pos - imageSize, 0.0, 0.0);
            titleEdgeInsets = UIEdgeInsetsMake(0.0, -20.0, 0.0, imageSize)
        }
    }
    
    func setupControls() {
        contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        let pos: CGFloat = frame.size.width
        let imageSize: CGFloat = 28.0
        imageEdgeInsets = UIEdgeInsetsMake(0.0, pos - imageSize, 0.0, 0.0);
        titleEdgeInsets = UIEdgeInsetsMake(0.0, -20.0, 0.0, imageSize)
        
        addTarget(self, action: #selector(onListAction), for: .touchUpInside)
    }
    
    /// Set current value. Overrides UIButton function.
    ///
    /// - Parameters:
    ///   - title: Value
    ///   - state: UIButton state
    override open func setTitle(_ title: String?, for state: UIControlState) {
        super.setTitle(title, for: state)
        if title != nil {
            currentValue = title!
        }
    }
    
    /// Set selection.
    ///
    /// - Parameter value: Value to select. If value is not from selection nothing will be changed.
    public func setSelection(value: String) {
        if selection.contains(value) {
            self.setTitle(value, for: .normal)
        }
    }
    
    /// Get selection.
    ///
    /// - Returns: Selection string. May be empty string.
    public func getSelection() -> String {
        return currentValue
    }
    
    func onListAction(sender: ComboBoxControl) {
        let alert = UIAlertController(title: NSLocalizedString("Select value", tableName: nil, bundle: Bundle(identifier: Constants.bandleId)!, value: "", comment: ""),
                                      message: "",
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        for value in sender.selection {
            alert.addAction(UIAlertAction(title: value, style: .default, handler: { (action) in
                //execute some code when this option is selected
                sender.setTitle(value, for: .normal)
            }))
        }
        viewController?.present(alert, animated: true, completion: nil)
    }
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}

