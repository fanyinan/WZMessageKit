//
//  WZMssageCellTools.swift
//  WZMessageProject
//
//  Created by 范祎楠 on 16/2/5.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit

class WZMessageCellTools {
  
  static var bubbleCache: [String: UIImage] = [:]
  
  class func calculateSizeWithCache(with text: String, fontSize: CGFloat, maxWidth: CGFloat) -> CGSize {
    
    let key = createTextKey(with: text, fontSize: fontSize, maxWidth: maxWidth)
    
    if let cacheSize = WZCacheManager.sharedInstance.fetchSize(with: key) {
      return cacheSize
    }
    
    let textSize = calculateSize(with: text, fontSize: fontSize, maxWidth: maxWidth)
    
    WZCacheManager.sharedInstance.saveSize(textSize, key: key)
    
    return textSize
  }
  
  class func calculateSize(with text: String, fontSize: CGFloat, maxWidth: CGFloat) -> CGSize {
    
    let maxSize = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
    
    let textWidthInOneline = (text as NSString).size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize)]).width
    
    let textSize = (text as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize)], context: nil).size
    
    let finalSize = CGSize(width: textWidthInOneline > textSize.width ? textSize.width : textWidthInOneline, height: textSize.height)
    
    return finalSize
  }
  
  class func asynCalculateTextSize(with text: String, fontSize: CGFloat, maxWidth: CGFloat, completion: @escaping (_ size: CGSize) -> Void) {
    
    let key = createTextKey(with: text, fontSize: fontSize, maxWidth: maxWidth)
    
    if let cacheSize = WZCacheManager.sharedInstance.fetchSize(with: key) {
      completion(cacheSize)
      return
    }
    
    DispatchQueue.global().async {
      
      let textSize = calculateSize(with: text, fontSize: fontSize, maxWidth: maxWidth)
      
      WZCacheManager.sharedInstance.saveSize(textSize, key: key)
      
      DispatchQueue.main.async {
        completion(textSize)
      }
    }
  }
  
  class func calculateImageSize(with url: String, maxSize: CGSize) -> CGSize? {
    
    let key = url.hash
    
    if let cacheSize = WZCacheManager.sharedInstance.fetchSize(with: key) {
      return cacheSize
    }
    
    guard let image = WebImageTools.fetchLocalImage(with: url) else { return nil }
    
    let widthScale = maxSize.width / image.size.width
    let heightScale = maxSize.height / image.size.height
    
    var targetScale = min(widthScale, heightScale)
    
    if widthScale > 1 && heightScale > 1 {
      targetScale = 1
    }
    
    let displaySize = CGSize(width: ceil(image.size.width * targetScale), height: ceil(image.size.height * targetScale))
    
    WZCacheManager.sharedInstance.saveSize(displaySize, key: key)
    
    return displaySize
  }
  
  private class func createTextKey(with text: String, fontSize: CGFloat, maxWidth: CGFloat) -> Int {
    
    return text.hash + Int(fontSize * 100) + Int(maxWidth * 10000)
  }
}
