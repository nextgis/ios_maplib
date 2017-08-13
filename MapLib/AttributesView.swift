//
//  AttributesView.swift
//  ngmaplib
//
//  Created by Dmitry Baryshnikov on 10.08.17.
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

public class AttributesView: UIScrollView {
    
    weak var prevView: UIView? = nil

    public var showUnsetFields: Bool = false
    public var isSectionUppercased = true
    public var labelColor: UIColor = UIColor.black
    public var labelSize: CGFloat = 13.0
    public var textColor: UIColor = UIColor.black
    public var textSize: CGFloat = 16.0
    public var sectionTextColor: UIColor = UIColor.black
    public var sectionTextSize: CGFloat = 13.0
    public var attachmentImage: UIImage? = nil
    public var attachmentRemoteImage: UIImage? = nil

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
    public func fill(feature: Feature) {
        if let fc = feature.featureClass {
            if isSectionUppercased {
                addSection("Attributes".localized.uppercased())
            }
            else {
                addSection("Attributes".localized)
            }
            let fields = fc.fields
            var count: Int32 = 0
            for field in fields {
                if showUnsetFields {
                    addFieldLabel(feature, field, count)
                } else if feature.isFieldSet(index: count) {
                    addFieldLabel(feature, field, count)
                }
                
                count += 1
            }
            
            addSection("Attachments".localized.uppercased())
            
            for attachment in feature.getAttachments() {
                addAttachment(attachment)
            }
            
            let bottom = NSLayoutConstraint(item: prevView!,
                                            attribute: .bottom,
                                            relatedBy: .equal,
                                            toItem: self,
                                            attribute: .bottom,
                                            multiplier: 1.0,
                                            constant: 8.0)
            NSLayoutConstraint.activate([bottom])
        }
    }
    
    public func addAttachment(_ attachment: Attachment) {
        
        if attachment.path.isEmpty {
            // Add download alert
        } else {
            // Add preview
        }
        
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .left
        lb.numberOfLines = 2
        lb.textColor = textColor
        lb.text = attachment.name
        lb.font = UIFont.systemFont(ofSize: textSize)
        
        addSubview(lb)
        
        let top = NSLayoutConstraint(item: lb,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: prevView,
                                     attribute: .bottom,
                                     multiplier: 1.0,
                                     constant: 20.0)
        
        let leading = NSLayoutConstraint(item: lb,
                                         attribute: .leading,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .leading,
                                         multiplier: 1.0,
                                         constant: 8.0)
        
        let trailing = NSLayoutConstraint(item: lb,
                                          attribute: .trailing,
                                          relatedBy: .equal,
                                          toItem: self,
                                          attribute: .trailing,
                                          multiplier: 1.0,
                                          constant: 8.0)
        
        let height = NSLayoutConstraint(item: lb,
                                        attribute: .height,
                                        relatedBy: .greaterThanOrEqual,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 1.0,
                                        constant: 15.0)
        
        let width = NSLayoutConstraint(item: lb,
                                       attribute: .width,
                                       relatedBy: .lessThanOrEqual,
                                       toItem: self,
                                       attribute: .width,
                                       multiplier: 1.0,
                                       constant: 0.0)
        
        NSLayoutConstraint.activate([leading, trailing, top, height, width])
        
        prevView = lb
    }
    
    public func addFieldLabel(_ feature: Feature, _ field: Field, _ pos: Int32) {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .left
        lb.numberOfLines = 2
        lb.textColor = labelColor
        lb.text = field.alias
        lb.font = UIFont.systemFont(ofSize: labelSize)
        
        addSubview(lb)
        
        let top = NSLayoutConstraint(item: lb,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: prevView,
                                     attribute: .bottom,
                                     multiplier: 1.0,
                                     constant: 20.0)
        
        let leading = NSLayoutConstraint(item: lb,
                                         attribute: .leading,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .leading,
                                         multiplier: 1.0,
                                         constant: 8.0)
        
        let trailing = NSLayoutConstraint(item: lb,
                                          attribute: .trailing,
                                          relatedBy: .equal,
                                          toItem: self,
                                          attribute: .trailing,
                                          multiplier: 1.0,
                                          constant: 8.0)
        
        let height = NSLayoutConstraint(item: lb,
                                        attribute: .height,
                                        relatedBy: .greaterThanOrEqual,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 1.0,
                                        constant: 15.0)
        
        let width = NSLayoutConstraint(item: lb,
                                       attribute: .width,
                                       relatedBy: .lessThanOrEqual,
                                       toItem: self,
                                       attribute: .width,
                                       multiplier: 1.0,
                                       constant: 0.0)
        
        NSLayoutConstraint.activate([leading, trailing, top, height, width])
        
        prevView = lb
        
        let vl = UILabel()
        vl.translatesAutoresizingMaskIntoConstraints = false
        vl.textAlignment = .left
        vl.numberOfLines = 0
        vl.textColor = textColor
        vl.text = feature.getField(asString: pos)
        vl.font = UIFont.systemFont(ofSize: textSize)
        
        addSubview(vl)
        
        let top1 = NSLayoutConstraint(item: vl,
                                      attribute: .top,
                                      relatedBy: .equal,
                                      toItem: prevView,
                                      attribute: .bottom,
                                      multiplier: 1.0,
                                      constant: 12.0)
        
        let leading1 = NSLayoutConstraint(item: vl,
                                          attribute: .leading,
                                          relatedBy: .equal,
                                          toItem: self,
                                          attribute: .leading,
                                          multiplier: 1.0,
                                          constant: 8.0)
        
        let trailing1 = NSLayoutConstraint(item: vl,
                                           attribute: .trailing,
                                           relatedBy: .equal,
                                           toItem: self,
                                           attribute: .trailing,
                                           multiplier: 1.0,
                                           constant: 8.0)
        
        let height1 = NSLayoutConstraint(item: vl,
                                         attribute: .height,
                                         relatedBy: .greaterThanOrEqual,
                                         toItem: nil,
                                         attribute: .notAnAttribute,
                                         multiplier: 1.0,
                                         constant: 18.0)
        
        let width1 = NSLayoutConstraint(item: vl,
                                        attribute: .width,
                                        relatedBy: .lessThanOrEqual,
                                        toItem: self,
                                        attribute: .width,
                                        multiplier: 1.0,
                                        constant: 0.0)
        
        NSLayoutConstraint.activate([leading1, trailing1, top1, height1, width1])
        
        prevView = vl
        
    }
    
    public func addSection(_ name: String) {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .left
        lb.numberOfLines = 1
        lb.textColor = sectionTextColor
        lb.text = name
        lb.font = UIFont.systemFont(ofSize: sectionTextSize)
        
        addSubview(lb)
        
        var top: NSLayoutConstraint
        if prevView == nil {
            top = NSLayoutConstraint(item: lb,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: self,
                                     attribute: .top,
                                     multiplier: 1.0,
                                     constant: 8.0)
        } else {
            top = NSLayoutConstraint(item: lb,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: prevView,
                                     attribute: .bottom,
                                     multiplier: 1.0,
                                     constant: 20.0)
        }
        
        let leading = NSLayoutConstraint(item: lb,
                                         attribute: .leading,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .leading,
                                         multiplier: 1.0,
                                         constant: 8.0)
        
        let trailing = NSLayoutConstraint(item: lb,
                                          attribute: .trailing,
                                          relatedBy: .equal,
                                          toItem: self,
                                          attribute: .trailing,
                                          multiplier: 1.0,
                                          constant: 8.0)
        
        let height = NSLayoutConstraint(item: lb,
                                        attribute: .height,
                                        relatedBy: .equal,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 1.0,
                                        constant: 14.0)
        
        NSLayoutConstraint.activate([leading, trailing, top, height])
        
        prevView = lb
    }


}
