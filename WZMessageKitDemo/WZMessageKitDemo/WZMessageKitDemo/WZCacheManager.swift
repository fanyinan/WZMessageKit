//
//  WZSizeCacheManager.swift
//  WZMessageProject
//
//  Created by 范祎楠 on 16/3/11.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit

class WZCacheManager: NSObject {
  
  static let sharedInstance = WZCacheManager()
  
  fileprivate var sizeCache: NSCache<AnyObject, AnyObject>!
  
  fileprivate(set) var isContentDiscarded = true
  
  fileprivate override init() {
    
    super.init()
    
    sizeCache = NSCache()
    sizeCache.countLimit = 500
    
  }
  
  func saveSize(_ size: CGSize, key: Int) {
    isContentDiscarded = false
    sizeCache.setObject(NSValue(cgSize: size), forKey: key as AnyObject)
    isContentDiscarded = true
  }
  
  func fetchSize(with key: Int) -> CGSize? {
    
    isContentDiscarded = false
    
    guard let sizeValue = sizeCache.object(forKey: key as AnyObject) as? NSValue else {
      
      isContentDiscarded = true
      
      return nil
    }
    
    isContentDiscarded = true
    
    return sizeValue.cgSizeValue
  }
  
}

//extension NSValue: NSDiscardableContent {
//
//  public func isContentDiscarded() -> Bool {
//    return WZCacheManager.sharedInstance.isContentDiscarded
//  }
//
//  public func beginContentAccess() -> Bool {
//    return true
//  }
//
//  public func endContentAccess() {
//  }
//
//  public func discardContentIfPossible() {
//  }
//}
