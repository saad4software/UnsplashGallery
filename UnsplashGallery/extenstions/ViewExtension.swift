//
//  ViewExtention.swift
//  UnsplashGallery
//
//  Created by Saad on 3/25/19.
//  Copyright © 2019 Saad. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    
    @IBInspectable
    var stShadow: Bool {
        get {
            return layer.shadowRadius > 0
        }
        set {
            if newValue
            {
                layer.shadowOpacity = 0.3
                layer.shadowOffset = CGSize(width: -1, height: 1)
                layer.shadowRadius = 2.5
            }
            else
            {
                layer.shadowRadius = 0
                layer.shadowOpacity = 0
                layer.shadowOffset = CGSize(width: 0, height: 0)
                
            }
        }
    }
    
    
    @IBInspectable
    var stRounded: Bool {
        get {
            return layer.masksToBounds
        }
        set {
            if newValue
            {
                layer.masksToBounds = true
                let width = frame.width < frame.height ? frame.width : frame.height
                layer.cornerRadius = width / 2
            }
            else
            {
                layer.masksToBounds = false
                layer.cornerRadius = 0
                
            }
        }
    }
    
    
    @IBInspectable
    var stHalfRounded: Bool {
        get {
            return layer.masksToBounds
        }
        set {
            if newValue
            {
                layer.masksToBounds = true
                let width = frame.width < frame.height ? frame.width : frame.height
                layer.cornerRadius = width / 2
            }
            else
            {
                layer.masksToBounds = false
                layer.cornerRadius = 0
                
            }
        }
    }
    
    
    
    @IBInspectable
    var stSoftEdges: Bool {
        get {
            return layer.cornerRadius > 0
        }
        set {
            if newValue
            {
               
                layer.cornerRadius = 5
            }
            else
            {
                layer.cornerRadius = 0
                
            }
        }
    }
    
    @IBInspectable
    var stBorder: Bool {
        get {
            return layer.borderWidth > 0
        }
        set {
            if newValue
            {
                layer.borderWidth = 0.5
                layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)

            }
            else
            {
                layer.borderWidth = 0
                layer.borderColor = nil

            }
        }
    }
    
    
    
    @IBInspectable
    var masksToBounds: Bool {
        get {
            return layer.masksToBounds
        }
        set {
            layer.masksToBounds = newValue
        }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
    
    

    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }

    

       
    func asImage() -> UIImage? {
        
            
        if #available(iOS 10.0, *) {
            
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            
            return renderer.image { rendererContext in
            
                layer.render(in: rendererContext.cgContext)
                
            }
            
        } else {
        
            UIGraphicsBeginImageContextWithOptions(self.bounds
                .size, self.isOpaque, 0.0)
            defer { UIGraphicsEndImageContext() }
            guard let currentContext =
                UIGraphicsGetCurrentContext() else {
                    return nil
            }

            self.layer.render(in: currentContext)
            return UIGraphicsGetImageFromCurrentImageContext()
            
        }
        
    }
    
    
    class func fromNib<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
    
    func setOnClickListener(action : @escaping (MyTapGestureRecognizer)->Void ){
        addTapGesture(action: action)
    }
    
    func  addTapGesture(action : @escaping (MyTapGestureRecognizer)->Void ){
        let tap = MyTapGestureRecognizer(target: self , action: #selector(self.handleTap(_:)))
        tap.action = action
        tap.numberOfTapsRequired = 1

        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true

    }
    
    @objc func handleTap(_ sender: MyTapGestureRecognizer) {
        sender.action!(sender)
    }
}

class MyTapGestureRecognizer: UITapGestureRecognizer {
    var action : ((MyTapGestureRecognizer)->Void)? = nil
}
