//
//  MessageViewLoader.swift
//  WZMessageProject
//
//  Created by 范祎楠 on 2017/1/23.
//  Copyright © 2017年 范祎楠. All rights reserved.
//

import UIKit

class MessageViewLoader {
  
  private var viewCache = DictArray<String, WZMessageBaseView>()
  private var currentCountdict: [String: Int] = [:]
  private var maxCountdict: [String: Int] = [:]
  private var currentHeight: CGFloat = 0
  private var offsetNum = 0
  private var heightList: [(type: String, height: CGFloat)] = []
  
  func preload(viewType: WZMessageBaseView.Type, height: CGFloat, maxHeight: CGFloat) {
    
    guard isNeedPreloadView(viewType: viewType, height: height, maxHeight: maxHeight) else { return }
    
    let type = String(describing: viewType)
    let view = viewType.self.init()
    
    //防止出现异步创建的label文字发生重叠
    view.frame = CGRect(x: 0, y: 0, width: 0, height: 1)
    view.subviews.forEach({$0.frame = view.bounds})
    
    view.setNeedsLayout()
    view.layoutIfNeeded()
    
    viewCache.append(view, to: type)
    
//    print("preload -------------------")
//
//    for (key, value) in viewCache {
//      print("\(key), \(value.count)")
//    }
  }
  
  func fetch<T: WZMessageBaseView>(viewType: T.Type) -> T {
    
    let type = String(describing: viewType)
    
    guard let view = viewCache.removeFirst(with: type) else {
      print("have no cached messageView, create directly : \(viewType)")
      return viewType.self.init()
    }
    
//    print("fetch -------------------")
//
//    for (key, value) in viewCache {
//      print("\(key), \(value.count)")
//    }
    
    return view as! T
  }
  
  private func isNeedPreloadView<T: UIView>(viewType: T.Type, height: CGFloat, maxHeight: CGFloat) -> Bool {
    
    let typeName = String(describing: viewType)
    heightList += [(type: typeName, height: height)]
    
    var typeCount = currentCountdict[typeName] ?? 0
    typeCount += 1
    currentCountdict[typeName] = typeCount
    
    let currentTypeViewCount = typeCount
    let maxTypeViewCount = maxCountdict[typeName] ?? 0
    
    let isNeedPreload = currentTypeViewCount > maxTypeViewCount && currentTypeViewCount > (viewCache[typeName].count)
    if isNeedPreload {
      maxCountdict[typeName] = currentTypeViewCount
    }
    
    currentHeight += height
    
    while currentHeight >= maxHeight {
      
      if offsetNum == 0 {
        
        currentHeight -= heightList[offsetNum].height - 1
        
      } else {
        
        currentHeight -= heightList[offsetNum].height
        
        let type = heightList[offsetNum - 1].type
        currentCountdict[type]! -= 1
        
      }
      
      offsetNum += 1
    }
    
    return isNeedPreload
  }
  
}
