//
//  UIImage + RGBInit.swift
//
//  Created by Michaël Azevedo on 16/10/2014.
//

import Foundation
import UIKit

extension UIColor{
    
    class func initRGBA(_ r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) ->UIColor
    {
        return UIColor(red:r/255, green: g/255, blue: b/255, alpha: a)
    }
    
    class func initRGB(_ r:CGFloat, g:CGFloat, b:CGFloat) ->UIColor
    {
        return UIColor.initRGBA(r, g:g, b:b, a:1)
    }
    
    class func initRGBGRAY(_ gray:CGFloat) ->UIColor
    {
        return UIColor.initRGBA(gray, g:gray, b:gray, a:1)
    }
}
