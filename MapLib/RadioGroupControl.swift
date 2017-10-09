//
//  ColorControl.swift
//  Project: NextGIS Mobile SDK
//  Author:  Dmitry Baryshnikov, dmitry.baryshnikov@nextgis.com
//
//  Created by Dmitry Baryshnikov on 27.09.17.
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

@IBDesignable open class RadioGroupControl: UIControl {
    
    weak var prevView: UIView? = nil
    var bottomCt: NSLayoutConstraint? = nil
    
    @IBInspectable open var onImage: UIImage? {
        didSet {
            var itemIndex = 0
            for button in radioButtons {
                if selectedItem == itemIndex {
                    button.setImage(onImage, for: .normal)
                }
                itemIndex = itemIndex + 1
            }
        }
    }
    
    @IBInspectable open var offImage: UIImage? {
        didSet {
            var itemIndex = 0
            for button in radioButtons {
                if selectedItem != itemIndex {
                    button.setImage(offImage, for: .normal)
                }
                itemIndex = itemIndex + 1
            }
        }
    }
    
    @IBInspectable open var textSize: CGFloat = 17.0 {
        didSet {
            for button in radioButtons {
                button.titleLabel?.font = UIFont.systemFont(ofSize: textSize)
            }
        }
    }
    
    @IBInspectable open var textColor: UIColor? = UIColor.black {
        didSet {
            for button in radioButtons {
                button.setTitleColor(textColor, for: .normal)
            }
        }
    }
    
    @IBInspectable open var items: String = "" {
        didSet {
            clear()
            let buttonNames: [String] = NSLocalizedString(items, comment: "").components(separatedBy: "|")
            for buttonName in buttonNames {
                printMessage("Add radio button with name: \(buttonName)")
                addRadioButton(with: buttonName)
            }
        }
    }
    
    var radioButtons: [UIButton] = []
    
    open var selectedItem: Int = 0
       
    public func select(item index: Int) {
        if index < 0 || index >= radioButtons.count {
            return
        }
        deselect(selectedItem)
        selectedItem = index
        radioButtons[index].setImage(onImage, for: .normal)
    }
    
    func deselect(_ index: Int) {
        if index < 0 || index >= radioButtons.count {
            return
        }
        radioButtons[index].setImage(offImage, for: .normal)
    }
    
    func onClick(sender: UIButton) {
        select(item: sender.tag)
    }
    
    func clear() {
        prevView = nil
        subviews.forEach({ $0.removeFromSuperview() })
        selectedItem = 0
    }
    
    func addRadioButton(with name: String) {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .left
        if radioButtons.isEmpty {
            button.setImage(onImage, for: .normal)
        }
        else {
            button.setImage(offImage, for: .normal)
        }
        button.backgroundColor = UIColor.clear
        button.titleLabel?.font = UIFont.systemFont(ofSize: textSize)
        button.setTitle(name, for: .normal)
        button.setTitleColor(textColor, for: .normal)
        button.addTarget(self, action: #selector(onClick), for: .touchUpInside)
        button.tag = radioButtons.count
        
        radioButtons.append(button)
        addSubview(button)
        
        var labelTopCt: NSLayoutConstraint
        if prevView == nil {
            labelTopCt = NSLayoutConstraint(item: button,
                                            attribute: .top,
                                            relatedBy: .equal,
                                            toItem: self,
                                            attribute: .top,
                                            multiplier: 1.0,
                                            constant: 0.0)
        }
        else {
            labelTopCt = NSLayoutConstraint(item: button,
                                            attribute: .top,
                                            relatedBy: .equal,
                                            toItem: prevView,
                                            attribute: .bottom,
                                            multiplier: 1.0,
                                            constant: 8.0)
        }
        
        let labelLeadingCt = NSLayoutConstraint(item: button,
                                                attribute: .leading,
                                                relatedBy: .equal,
                                                toItem: self,
                                                attribute: .leading,
                                                multiplier: 1.0,
                                                constant: 0.0)
        
        let labelTrailingCt = NSLayoutConstraint(item: button,
                                                 attribute: .trailing,
                                                 relatedBy: .equal,
                                                 toItem: self,
                                                 attribute: .trailing,
                                                 multiplier: 1.0,
                                                 constant: 0.0)
        
        let heightCt = NSLayoutConstraint(item: button,
                                        attribute: .height,
                                        relatedBy: .greaterThanOrEqual,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 1.0,
                                        constant: (onImage?.size.height ?? 24.0 + 8.0))
        
        if bottomCt != nil {
            NSLayoutConstraint.deactivate([bottomCt!])
        }

        bottomCt = NSLayoutConstraint(item: self,
                                      attribute: .bottom,
                                      relatedBy: .equal,
                                      toItem: button,
                                      attribute: .bottom,
                                      multiplier: 1.0,
                                      constant: 0.0)

        prevView = button
        
        NSLayoutConstraint.activate([labelTopCt, labelLeadingCt, labelTrailingCt,
                                     heightCt, bottomCt!])
    }
}
