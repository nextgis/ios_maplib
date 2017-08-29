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
import ngstore

public protocol AttachmentTapDelegate: class {
    func onAttachmentTap(attachment: Attachment?)
}

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
    public var attachmentDelegate: AttachmentTapDelegate? = nil

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
    
    class UIButtonWithAttachment: UIButton {
        var attachment: Attachment? = nil
    }
    
    func onAttachmentTap(sender: UIButtonWithAttachment) {
        attachmentDelegate?.onAttachmentTap(attachment: sender.attachment)
    }
    
    
    
    public func addAttachment(_ attachment: Attachment) {
        
        let lb = UIButtonWithAttachment()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.setTitle(attachment.name, for: .normal)
        lb.setTitleColor(textColor, for: .normal)
        
        lb.titleLabel?.numberOfLines = 2
        lb.titleLabel?.font = UIFont.systemFont(ofSize: textSize)
        lb.backgroundColor = UIColor.clear
        lb.contentHorizontalAlignment = .left
        
        
        
        if attachment.path.isEmpty ||
            !FileManager.default.fileExists(atPath: attachment.path) {
            // Add download alert
            lb.setImage(attachmentRemoteImage, for: .normal)
        } else {
            // Add preview
            lb.setImage(attachmentImage, for: .normal)
        }
        
        lb.attachment = attachment
        lb.addTarget(self, action: #selector(onAttachmentTap), for: .touchUpInside)
        
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
        
        let vl: UIView
        
        let value = feature.getField(asString: pos)
        if value.hasPrefix("http") {
            let tv = UITextView()
            tv.isEditable = false;
            tv.dataDetectorTypes = UIDataDetectorTypes.all;
            tv.translatesAutoresizingMaskIntoConstraints = false
            tv.textAlignment = .left
            tv.textColor = textColor
            tv.text = feature.getField(asString: pos)
            tv.font = UIFont.systemFont(ofSize: textSize)
            tv.textContainerInset = UIEdgeInsets.zero
            tv.contentInset = UIEdgeInsets.zero
            tv.textContainer.lineFragmentPadding = 0
            tv.isScrollEnabled = false
            tv.backgroundColor = UIColor.clear
            
            vl = tv
        } else {
            let vl1 = UILabel()
            vl1.translatesAutoresizingMaskIntoConstraints = false
            vl1.textAlignment = .left
            vl1.numberOfLines = 0
            vl1.textColor = textColor
            vl1.text = feature.getField(asString: pos)
            vl1.font = UIFont.systemFont(ofSize: textSize)
            
            vl = vl1
        }
        
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
