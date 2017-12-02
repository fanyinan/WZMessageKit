//
//  Extension.swift
//  WZMessageKitDemo
//
//  Created by fanyinan on 2017/12/2.
//  Copyright © 2017年 fyn. All rights reserved.
//

import UIKit

extension UIView {
  
  func wz_setViewCornerRadius(_ radius: CGFloat? = nil) {
    var radius = radius
    if radius == nil {
      radius = self.bounds.size.height * 0.5
    }
    self.layer.cornerRadius = radius!
    self.layer.masksToBounds = true
  }
  
  func wz_setBorder(_ borderWidth: CGFloat = 1, color: UIColor) {
    self.layer.borderColor = color.cgColor
    self.layer.borderWidth = borderWidth
    
  }
}

extension UIImage {
  
  func wz_scaledImage(to size: CGSize) -> UIImage? {
    
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    
    draw(in: CGRect(origin: CGPoint.zero, size: size))
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
  }
  
  func wz_scaleImageWithoutCliped(to maxSize: CGSize) -> UIImage? {
    
    guard maxSize != CGSize.zero else { return nil }
    
    let widthScale = maxSize.width / size.width
    let heightScale = maxSize.height / size.height
    
    let targetScale = min(widthScale, heightScale)
    
    if widthScale > 1 && heightScale > 1 { return self }
    
    let displaySize = CGSize(width: ceil(size.width * targetScale), height: ceil(size.height * targetScale))
    
    return wz_scaledImage(to: displaySize)
    
  }
  
}
