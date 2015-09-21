//
//  Extensions.swift
//  GitHub User Profile
//
//  Created by Eduardo Irías on 8/16/15.
//  Copyright (c) 2015 Estamp World. All rights reserved.
//

import UIKit

class Extension : NSObject {
    static let Edge =  UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
}

extension UIView {
    func addRoundedCorner () {
        self.layer.cornerRadius =  5
        self.layer.masksToBounds = true
    }
}

extension UIImageView {
    func addImageInsets(insets: UIEdgeInsets) {
        if let image = self.image {
            UIGraphicsBeginImageContextWithOptions(
                CGSizeMake(image.size.width + insets.left + insets.right,
                    image.size.height + insets.top + insets.bottom), false, image.scale)
            //let context = UIGraphicsGetCurrentContext()
            let origin = CGPoint(x: insets.left, y: insets.top)
            image.drawAtPoint(origin)
            let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.image = imageWithInsets
        }
    }
}

extension String {
    var removeComma:String {
        return componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: ",")).joinWithSeparator("")
    }
    var webUrl:NSURL {
        
        return NSURL(string: stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())! )!
    }
}

extension NSDictionary {
    func toURLString () -> String {
        var optionsstr = ""
        let options = self
        for option in options {
            if let key = option.key as? String, let value: AnyObject = option.value as AnyObject! {
                optionsstr = "\(optionsstr)\(key)=\(value)&"
            }
            
        }
        
        return optionsstr
    }
}