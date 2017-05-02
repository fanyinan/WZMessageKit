//
//  Utility.swift
//  Yuanfenba
//
//  Created by 范祎楠 on 16/7/4.
//  Copyright © 2016年 Juxin. All rights reserved.
//

import Foundation

func exChangeGlobalQueue(_ handle: @escaping ()->Void) {
  
  DispatchQueue.global().async {
    handle()
  }
}

func exChangeMainQueue(_ handle: @escaping ()->Void) {
  
  DispatchQueue.main.async {
    handle()
  }
}

func swiftClassFromString(_ className: String) -> AnyClass? {
  // get the project name NSClassFromString 在Swift中已经 no effect
  if let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String {
    // generate the full name of your class (take a look into your "SHCC-swift.h" file)
    let classStringName = "_TtC\(appName.utf16.count)\(appName)\(className.characters.count)\(className)"
    let  cls: AnyClass?  = NSClassFromString(classStringName)
    //     cls = NSClassFromString("\(appName).\(className)")
    return cls
    
  }
  return nil
}

extension UIImageView {
  
  func asyncSetImage(with named: String, imageSize: CGSize? = nil) {
    
    let tmpTag = (tag + 1) % 100
    tag = tmpTag
    
    exChangeGlobalQueue {
      
      guard let sourceImage = UIImage(named: named) else { return }
      
      var imageSize = imageSize ?? self.frame.size
      
      if imageSize.width == 0 || imageSize.height == 0 {
        imageSize = sourceImage.size
      }
      
      UIGraphicsBeginImageContextWithOptions(imageSize, false, UIScreen.main.scale)
      
      sourceImage.draw(in: CGRect(origin: CGPoint.zero, size: imageSize))
      
      let targetImage = UIGraphicsGetImageFromCurrentImageContext()
      
      UIGraphicsEndImageContext()
      
      exChangeMainQueue {
        
        guard tmpTag == self.tag else { return }
        
        self.image = targetImage
        
      }
    }
  }
}
